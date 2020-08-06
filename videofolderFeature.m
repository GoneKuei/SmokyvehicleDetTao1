str = 'D:\smokyvideo';
genstr = genpath(str);
temp = [];
filepath = {};
for i = 1:length(genstr) %Ѱ�ҷָ��';'��һ���ҵ�����·��tempд��path������
    if genstr(i) ~= ';'
        temp = [temp genstr(i)];
    else 
        temp = [temp '\']; %��·���������� '\'
        files = dir(strcat(temp,'*.mp4'));
        for j = 1:length(files)
            filepath = [filepath;strcat(temp,files(j).name)];
        end
        temp = [];
    end
end  
clear temp;
% number_files = length(filepath);
% Xall = cell(1,number_files); YieldRateAll = -ones(1,number_files);
% for i=1:number_files
%     [Xall{i},YieldRateAll(i)] = video2features( filepath{i} );
% end
[Xall,Label,Yimage,YieldRateAll,badRates1,badRates2,badRates3] = cellfun(@(x)video2features(x),filepath,'UniformOutput', false);
xall = cell2mat(Xall);
lall = cell2mat(Label);
Analysis = [filepath,YieldRateAll,badRates1,badRates2,badRates3];

function [Video_xfeatures,LABEL,YieldImage,YieldRate,badrates1,badrates2,badrates3] = video2features( VIBEtestOutVideo )
%opencv GLCM
% 5*4*2 
% Video red_rect_vertex 
allxfea=@( Irear )cellfun( @( th,d )computeXfeature( Irear,th,d ),{0,45,90,135,0,45,90,135},{2,2,2,2,3,3,3,3},'UniformOutput',false );
v = VideoReader( VIBEtestOutVideo ); 
    vW=v.Width;vN=v.NumFrames;
    frame_order=0;
    Video_xfeatures= -ones( vN,80 );
    LABEL = -ones( vN,1 );
    YieldImage = cell(vN,1);
    templabel = -1;
badNum = ones(1,3)*vN;
badNum(3) = 0;
while hasFrame( v )
 frame_order=frame_order+1;
 frame = readFrame( v );
    frame = frame( ~all( sum( frame,3 )>700,2 ), :, : ); % ��ȥ�·�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
    frame = frame( :, ~all( sum( frame,3 )>700,1 ), : ); % ��ȥ�ҷ�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
    [h,w,~] = size(frame);
    if (h*w>2000)
        if w/h>1.5 % ֻ�ü������ͼ��Ĳ���
            frame = sidedet(frame,vW);
            [h,w,~] = size(frame);
        end
        if (h*w>2000 && w/h<=1.5 && w/h>=0.3) % 
        framerear = reardet( frame, vW ); % 
            if  size(framerear,1)>=50*(vW/768)% �жϳ�β������ﵽ50����60��
                med = round( size( framerear,2 )/2 );
                Video_xfeatures( frame_order,: ) = [ cell2mat( allxfea( framerear( :,1:med ) ) ), cell2mat( allxfea( framerear( :,med:end ) ) )];
                labelinput = input('TAP ENTER TO SKIP NON-SMOKE, NUMBERS TO LABEL SMOKY '); % �����һ����Ч֡
                if isempty(labelinput)
                   templabel = 1; % ֱ�Ӱ��س���ʾ�Ǻ��̳���0���; ����Ǻ��̳����е���Ƶʱ��������ȡ��
                else
                   templabel = 0; % �ǿ������ʾ���̳��ĺ���֡��1���
                end
                LABEL( abs(frame_order-2)+1 ) = templabel; % ��������һ֡δ������Ч֡���������ɾ����Ч֡���ܺ�featureһͬɾ��������ɾ�����ɣ���Ϊָ��λ�ò�ͬ��������ͬ
                imshow(frame);% ���б�ע׼��
                YieldImage{frame_order} = frame;
            else % ������rule3���µĻ�֡
                badNum(3) = badNum(3)+1; % Rule3������ǰ����Ϊ��ſ�ʹ��
            end
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
% �����������һ֡�ı��
labelinput = input('TAP ENTER TO SKIP NON-SMOKE, NUMBERS TO LABEL SMOKY'); % ������һ֡
    if isempty(labelinput)
        templabel = 0; % ֱ�Ӱ��س���ʾ�Ǻ��̳���0���
    else
        templabel = 1; % �ǿ������ʾ���̳��ĺ���֡��1���
    end
    LABEL( abs(frame_order-2)+1 ) = templabel;

badrates = badNum./v.NumFrame;
badrates1=badrates(1);badrates2=badrates(2);badrates3=badrates(3);
YieldIndex = ~all( Video_xfeatures==-1,2 );% ɾ����Ч֡
Video_xfeatures = Video_xfeatures( YieldIndex, :); % ɾ��
LABEL = LABEL( ~all( LABEL==-1,2 ) ); % ɾ����Ч֡����feature����Ч֡������ͬ������λ�ò�ͬ
YieldImage = YieldImage( YieldIndex ); % ɾ����Ч֡
YieldRate = size(Video_xfeatures,2)./v.NumFrame;
end