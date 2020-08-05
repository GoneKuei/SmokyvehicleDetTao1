str = 'D:\video3';
genstr = genpath(str);
temp = [];
filepath = {};
for i = 1:length(genstr) %寻找分割符';'，一旦找到，则将路径temp写入path数组中
    if genstr(i) ~= ';'
        temp = [temp genstr(i)];
    else 
        temp = [temp '\']; %在路径的最后加入 '\'
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
    frame = frame( ~all( sum( frame,3 )>700,2 ), :, : ); % 裁去下方( 横条 )白色区域，将视频中有车的部分提取出来
    frame = frame( :, ~all( sum( frame,3 )>700,1 ), : ); % 裁去右方( 竖条 )白色区域，将视频中有车的部分提取出来
    [h,w,~] = size(frame);    
    if (h*w>2000 && w/h<=1.5 && w/h>=0.3) % 
        framerear = reardet( frame,vW );
        if  size(framerear,1)>=60*(vW/768)% 判断车尾后区域达到50（或60）
            med = round( size( framerear,2 )/2 );
            Video_xfeatures( frame_order,: ) = [ cell2mat( allxfea( framerear( :,1:med ) ) ), cell2mat( allxfea( framerear( :,med:end ) ) )];
%             imshow(frame);
        else % 计算因rule3导致的坏帧
            badNum(3) = badNum(3)+1; % Rule3必须在前两项为真才可使用
        end
    end
    % 计算坏帧原因
    if (h*w>2000)
        badNum(1) = badNum(1)-1;
    end
    if (w/h<=1.5 && w/h>=0.3) % 
        badNum(2) = badNum(2)-1;
    end
end
badrates = badNum./v.NumFrame;
Video_xfeatures = Video_xfeatures( ~all( Video_xfeatures==-1,2 ), :)'; % 删除
YieldRate = size(Video_xfeatures,2)./v.NumFrame;
end