str = 'D:\smokyvideo';
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
    frame = frame( ~all( sum( frame,3 )>700,2 ), :, : ); % 裁去下方( 横条 )白色区域，将视频中有车的部分提取出来
    frame = frame( :, ~all( sum( frame,3 )>700,1 ), : ); % 裁去右方( 竖条 )白色区域，将视频中有车的部分提取出来
    [h,w,~] = size(frame);
    if (h*w>2000)
        if w/h>1.5 % 只裁剪过宽的图像的侧面
            frame = sidedet(frame,vW);
            [h,w,~] = size(frame);
        end
        if (h*w>2000 && w/h<=1.5 && w/h>=0.3) % 
        framerear = reardet( frame, vW ); % 
            if  size(framerear,1)>=50*(vW/768)% 判断车尾后区域达到50（或60）
                med = round( size( framerear,2 )/2 );
                Video_xfeatures( frame_order,: ) = [ cell2mat( allxfea( framerear( :,1:med ) ) ), cell2mat( allxfea( framerear( :,med:end ) ) )];
                labelinput = input('TAP ENTER TO SKIP NON-SMOKE, NUMBERS TO LABEL SMOKY '); % 标记上一个有效帧
                if isempty(labelinput)
                   templabel = 1; % 直接按回车表示非黑烟车，0标记; 但标记黑烟车集中的视频时，这两项取反
                else
                   templabel = 0; % 非空输入表示黑烟车的黑烟帧，1标记
                end
                LABEL( abs(frame_order-2)+1 ) = templabel; % 连续的上一帧未必是有效帧，所以最后删除无效帧不能和feature一同删除、单独删除即可，因为指标位置不同、数量相同
                imshow(frame);% 进行标注准备
                YieldImage{frame_order} = frame;
            else % 计算因rule3导致的坏帧
                badNum(3) = badNum(3)+1; % Rule3必须在前两项为真才可使用
            end
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
% 单独进行最后一帧的标记
labelinput = input('TAP ENTER TO SKIP NON-SMOKE, NUMBERS TO LABEL SMOKY'); % 标记最后一帧
    if isempty(labelinput)
        templabel = 0; % 直接按回车表示非黑烟车，0标记
    else
        templabel = 1; % 非空输入表示黑烟车的黑烟帧，1标记
    end
    LABEL( abs(frame_order-2)+1 ) = templabel;

badrates = badNum./v.NumFrame;
badrates1=badrates(1);badrates2=badrates(2);badrates3=badrates(3);
YieldIndex = ~all( Video_xfeatures==-1,2 );% 删除无效帧
Video_xfeatures = Video_xfeatures( YieldIndex, :); % 删除
LABEL = LABEL( ~all( LABEL==-1,2 ) ); % 删除无效帧，和feature的无效帧数量相同，但是位置不同
YieldImage = YieldImage( YieldIndex ); % 删除无效帧
YieldRate = size(Video_xfeatures,2)./v.NumFrame;
end