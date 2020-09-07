function [Video_xfeatures,LABEL,YieldImage,YieldRate,badrates1,badrates2,badrates3,badrates4] = Copy_of_video3features( VIBEtestOutVideo, LabelType )
%  This copy delete the side detection.
    %opencv GLCM
    % 5*4*2 
    % Video red_rect_vertex 
    allxfea=@( Irear )cellfun( @( th,d )computeXfeature( Irear,th,d ),{0,45,90,135,0,45,90,135},{2,2,2,2,3,3,3,3},'UniformOutput',false );
    v = VideoReader( VIBEtestOutVideo ); 
        vW=v.Width; vN=v.NumFrames;
        frame_order=0;
        Video_xfeatures = { -ones( vN,40 ), -ones( vN,40 ) };
        YieldImage = cell(vN,3); % ��һλ��ͼ�񣬵ڶ�����λ��ʶ�����β�������½�����
    if LabelType == 4
        InputType = @(x)Input4(x); % �趨�Ʋ���x��Ĭ��ȡ1
    elseif LabelType == 1
        InputType = @(x)Input1(x);
    elseif LabelType == 2
        InputType = @(x)Input2(x);
    else % ���������ݱ�ǩ��ֻ����ʱ������������������ܣ����齫��һ�ΰ��뿪�������滻Ϊinput4
        InputType = 4; LabelType = 0;
    end
    LABEL = -ones( vN,LabelType ); % { -ones( vN,1 ), -ones( vN,1 ), -ones( vN,1 ), -ones( vN,1 ) };

    badNum = ones(1,4)*vN;
    badNum(3) = 0;
    badNum(4) = 0;
    
    while hasFrame( v )
        frame_order=frame_order+1;
        frame = readFrame( v );
        frame = frame( ~all( sum( frame,3 )>700,2 ), :, : ); % ��ȥ�·�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
        frame = frame( :, ~all( sum( frame,3 )>700,1 ), : ); % ��ȥ�ҷ�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
        [h,w,~] = size(frame);
        if (h*w>2000)
            if w/h>1.3 % ֻ�ü������ͼ��Ĳ���
                frame = sidedet(frame,vW); % ���ܶ���Ҫ�ü�������ֻ�ü��Ҳ��棬8.22����
                [h,w,~] = size(frame);
            end
            if (h*w>2000 && w/h<=1.5 && w/h>=0.3) % 
                [frame_rear,Xrear,XrearA3,~] = reardet( frame, vW ); % 
%                 frame_left = reardet( rot90(frame,1), vH ); % �����ʶ�� rotation(frame,[1,1,2],90,[1,1,1])
                if  size(frame_rear,1)>=60*(vW/768) % �жϳ�β������ﵽ50����60��
                    subplot(1,2,1);imshow(frame); % ���б�ע׼�����粻��Ҫ��ע��ɾ����������������
                    line([1,size(I,2),size(I,2),1],[Xrear2,Xrear2,Xrear2A3,XrearA3],'LineWidth',2,'Color','b')%'#87CEFA','LineStyle','--'); ͬ7�зŴ�90
                    subplot(1,2,2); YieldImage(frame_order,2:3)={Xrear,min(Xrear+60,v.Height)} ; imshow(frame(Xrear:min(Xrear+60,v.Height),:));
                    YieldImage{ frame_order } = frame; % �洢����Ч֡
                    med = round( size( frame_rear,2 )/2 );
%                     medLeft = round( size( frame_left,2 )/2 );
%                     Video_xfeatures{1}( frame_order,: ) = cell2mat( allxfea( frame_left( :,1:medLeft ) ) );
%                     Video_xfeatures{2}( frame_order,: ) = cell2mat( allxfea( frame_left( :,medLeft:end ) ) );
                    Video_xfeatures{1}( frame_order,: ) = cell2mat( allxfea( frame_rear( :,1:med ) ) );
                    Video_xfeatures{2}( frame_order,: ) = cell2mat( allxfea( frame_rear( :,med:end ) ) );
                    LABEL( frame_order, : ) = InputType(1);
                end
            else % ������rule3���µĻ�֡
                badNum(3) = badNum(3)+1; % 
            end
        end
            % ���㻵֡ԭ��
        if (h*w>2000)
            badNum(1) = badNum(1)-1;
        end
        if (w/h<=1.5 && w/h>=0.3) % 
            badNum(2) = badNum(2)-1;
        end
    end
    % ~all( LABEL==-1 )
    % ��ʱ��������ĸ�λ������ֵ�����㣬��Ȼ�ֶ����ĸ��ֿ����ܻ��׼ȷ���������޺��̵�·��
    % �����ĸ���λȫΪ��֡��Ϊ��֡��������Ȼ���±�ǣ�����ɾ������[-1, -1, -1, -1]��LABEL
    YieldIndex = (sum(LABEL,2)~=-LabelType); % ɾ����Ч֡, ��ÿһ�����Ϊ-4�ļ�Ϊ��ȫ��Ч֡; ���ڵ�����ǩ�����Ҳ���ǵ�ֵΪ-1
        % ��֡�ʼ��㣬�������������ֶ���ǵĻ�֡
        badNum(4) = sum(YieldIndex) - sum(badNum);
        badrates = badNum./vN;
        badrates1=badrates(1); badrates2=badrates(2); badrates3=badrates(3); badrates4=badrates(4);
    LABEL = LABEL( YieldIndex,: ); % ɾ����Ч֡���������ʶ��������ʹ��LABEL = 2.^(LABEL(:,1)).*3.^(LABEL(:,1)).*5.^(LABEL(:,1)).*7.^(LABEL(:,1))
    YieldImage = YieldImage( YieldIndex ); % ɾ����Ч֡
    YieldRate = size(Video_xfeatures,2)./vN;
    for j=1:2
        Video_xfeatures{j} = Video_xfeatures{j}( YieldIndex, :); % ɾ��
    end
Video_xfeatures = cell2mat(Video_xfeatures);
    Video_xfeatures = 1./(1+exp(-Video_xfeatures));
    
function templabel = Input4(x)
Local = {'LeftUp','LeftBot','BotLeft','BotRight'}; % 
templabel = 2*ones(1,4);
for jk=1:4
    labelinput = input(['Is the ', Local{jk}, ' smoky? ']); % �����ϣ����£��������ң�����0��ʾ����Ч֡
    if labelinput == 0
        templabel(jk) = -1; % ��ǻ�֡���Ѿ�ͬ����ǩ������ֵ������ָ�꣬���ֻ��Ǳ�ǩ����ȥ��
%                         Video_xfeatures{j}( frame_order,: ) = -1; % ����0���Ϊ��֡
%                         LABEL( frame_order, j ) = -1; % ����0���Ϊ��֡
    elseif isempty(labelinput)
            templabel(jk) = 0; % �������ʾ���̳�����Ϊ���̳�ռ�����
    else 
        templabel(jk) = 1;
    end
end
end

function templabel = Input2(x)
Local = {'BotLeft','BotRight'}; % 
templabel = 2*ones(1,4);
for jk=1:2
    labelinput = input(['Is the ', Local{jk}, ' smoky? ']); % ���������ң�����0��ʾ����Ч֡
    if labelinput == 0
        templabel(jk) = -1; % ��ǻ�֡���Ѿ�ͬ����ǩ������ֵ������ָ�꣬���ֻ��Ǳ�ǩ����ȥ��
%                         Video_xfeatures{j}( frame_order,: ) = -1; % ����0���Ϊ��֡
%                         LABEL( frame_order, j ) = -1; % ����0���Ϊ��֡
    elseif isempty(labelinput)
            templabel(jk) = 0; % �������ʾ�Ǻ��̳�����Ϊ�Ǻ��̳�ռ�����
    else 
        templabel(jk) = 1;
    end
end
end

function templabel = Input1(x)
labelinput = input('Is it smoky? '); % 
if labelinput == 0 
    templabel = -1; % ��ǻ�֡���Ѿ�ͬ����ǩ������ֵ������ָ�꣬���ֻ��Ǳ�ǩ����ȥ��
elseif isempty(labelinput)
        templabel = 1; % �������ʾ���̳�����Ϊ���̳�ռ�����
else 
    templabel = 0;
end
end

end