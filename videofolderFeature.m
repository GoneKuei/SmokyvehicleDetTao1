str = 'D:\video3';
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
[Xall,YieldRateAll,badRates] = cellfun(@(x)video2features(x),filepath,'UniformOutput', false);
xall = cell2mat(Xall');
Analysis = [filepath,YieldRateAll,badRates];

function [Video_xfeatures,YieldRate,badrates] = video2features( VIBEtestOutVideo )
%opencv GLCM
% 5*4*2 
% Video red_rect_vertex 
allxfea=@( Irear )cellfun( @( th,d )computeXfeature( Irear,th,d ),{0,45,90,135,0,45,90,135},{2,2,2,2,3,3,3,3},'UniformOutput',false );
v = VideoReader( VIBEtestOutVideo ); 
    vW=v.Width;
    frame_order=0;
    Video_xfeatures= -ones( v.NumFrames,80 );
badNum = ones(1,3)*v.NumFrames;
badNum(3) = 0;
while hasFrame( v )
 frame_order=frame_order+1;
 frame = readFrame( v );
    frame = frame( ~all( sum( frame,3 )>700,2 ), :, : ); % ��ȥ�·�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
    frame = frame( :, ~all( sum( frame,3 )>700,1 ), : ); % ��ȥ�ҷ�( ���� )��ɫ���򣬽���Ƶ���г��Ĳ�����ȡ����
    [h,w,~] = size(frame);    
    if (h*w>2000 && w/h<=1.5 && w/h>=0.3) % 
        framerear = reardet( frame,vW );
        if  size(framerear,1)>=60*(vW/768)% �жϳ�β������ﵽ50����60��
            med = round( size( framerear,2 )/2 );
            Video_xfeatures( frame_order,: ) = [ cell2mat( allxfea( framerear( :,1:med ) ) ), cell2mat( allxfea( framerear( :,med:end ) ) )];
%             imshow(frame);
        else % ������rule3���µĻ�֡
            badNum(3) = badNum(3)+1; % Rule3������ǰ����Ϊ��ſ�ʹ��
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
badrates = badNum./v.NumFrame;
Video_xfeatures = Video_xfeatures( ~all( Video_xfeatures==-1,2 ), :)'; % ɾ��
YieldRate = size(Video_xfeatures,2)./v.NumFrame;
end