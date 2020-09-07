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
        YieldImage = cell(vN,3); % 第一位是图像，第二、三位是识别出的尾部的上下界坐标
    if LabelType == 4
        InputType = @(x)Input4(x); % 设定哑参数x，默认取1
    elseif LabelType == 1
        InputType = @(x)Input1(x);
    elseif LabelType == 2
        InputType = @(x)Input2(x);
    else % 不进行数据标签，只运行时的情况；如需提升性能，建议将这一段剥离开、并且替换为input4
        InputType = 4; LabelType = 0;
    end
    LABEL = -ones( vN,LabelType ); % { -ones( vN,1 ), -ones( vN,1 ), -ones( vN,1 ), -ones( vN,1 ) };

    badNum = ones(1,4)*vN;
    badNum(3) = 0;
    badNum(4) = 0;
    
    while hasFrame( v )
        frame_order=frame_order+1;
        frame = readFrame( v );
        frame = frame( ~all( sum( frame,3 )>700,2 ), :, : ); % 裁去下方( 横条 )白色区域，将视频中有车的部分提取出来
        frame = frame( :, ~all( sum( frame,3 )>700,1 ), : ); % 裁去右方( 竖条 )白色区域，将视频中有车的部分提取出来
        [h,w,~] = size(frame);
        if (h*w>2000)
            if w/h>1.3 % 只裁剪过宽的图像的侧面
                frame = sidedet(frame,vW); % 可能都需要裁剪，现在只裁剪右侧面，8.22更新
                [h,w,~] = size(frame);
            end
            if (h*w>2000 && w/h<=1.5 && w/h>=0.3) % 
                [frame_rear,Xrear,XrearA3,~] = reardet( frame, vW ); % 
%                 frame_left = reardet( rot90(frame,1), vH ); % 左侧面识别 rotation(frame,[1,1,2],90,[1,1,1])
                if  size(frame_rear,1)>=60*(vW/768) % 判断车尾后区域达到50（或60）
                    subplot(1,2,1);imshow(frame); % 进行标注准备；如不需要标注可删除此行以提升性能
                    line([1,size(I,2),size(I,2),1],[Xrear2,Xrear2,Xrear2A3,XrearA3],'LineWidth',2,'Color','b')%'#87CEFA','LineStyle','--'); 同7行放大到90
                    subplot(1,2,2); YieldImage(frame_order,2:3)={Xrear,min(Xrear+60,v.Height)} ; imshow(frame(Xrear:min(Xrear+60,v.Height),:));
                    YieldImage{ frame_order } = frame; % 存储该有效帧
                    med = round( size( frame_rear,2 )/2 );
%                     medLeft = round( size( frame_left,2 )/2 );
%                     Video_xfeatures{1}( frame_order,: ) = cell2mat( allxfea( frame_left( :,1:medLeft ) ) );
%                     Video_xfeatures{2}( frame_order,: ) = cell2mat( allxfea( frame_left( :,medLeft:end ) ) );
                    Video_xfeatures{1}( frame_order,: ) = cell2mat( allxfea( frame_rear( :,1:med ) ) );
                    Video_xfeatures{2}( frame_order,: ) = cell2mat( allxfea( frame_rear( :,med:end ) ) );
                    LABEL( frame_order, : ) = InputType(1);
                end
            else % 计算因rule3导致的坏帧
                badNum(3) = badNum(3)+1; % 
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
    % ~all( LABEL==-1 )
    % 暂时采用柔和四个位置特征值来运算，虽然手动将四个分开可能会更准确地区分有无黑烟的路面
    % 设置四个部位全为坏帧的为坏帧，否则仍然留下标记，即仅删除形如[-1, -1, -1, -1]的LABEL
    YieldIndex = (sum(LABEL,2)~=-LabelType); % 删除无效帧, 对每一行求和为-4的即为完全无效帧; 对于单个标签，求和也就是单值为-1
        % 坏帧率计算，新增第四项是手动标记的坏帧
        badNum(4) = sum(YieldIndex) - sum(badNum);
        badrates = badNum./vN;
        badrates1=badrates(1); badrates2=badrates(2); badrates3=badrates(3); badrates4=badrates(4);
    LABEL = LABEL( YieldIndex,: ); % 删除无效帧，如果不能识别向量，使用LABEL = 2.^(LABEL(:,1)).*3.^(LABEL(:,1)).*5.^(LABEL(:,1)).*7.^(LABEL(:,1))
    YieldImage = YieldImage( YieldIndex ); % 删除无效帧
    YieldRate = size(Video_xfeatures,2)./vN;
    for j=1:2
        Video_xfeatures{j} = Video_xfeatures{j}( YieldIndex, :); % 删除
    end
Video_xfeatures = cell2mat(Video_xfeatures);
    Video_xfeatures = 1./(1+exp(-Video_xfeatures));
    
function templabel = Input4(x)
Local = {'LeftUp','LeftBot','BotLeft','BotRight'}; % 
templabel = 2*ones(1,4);
for jk=1:4
    labelinput = input(['Is the ', Local{jk}, ' smoky? ']); % 按左上，左下，下左，下右，输入0表示是无效帧
    if labelinput == 0
        templabel(jk) = -1; % 标记坏帧，已经同步标签和特征值向量的指标，因此只标记标签即可去除
%                         Video_xfeatures{j}( frame_order,: ) = -1; % 输入0标记为坏帧
%                         LABEL( frame_order, j ) = -1; % 输入0标记为坏帧
    elseif isempty(labelinput)
            templabel(jk) = 0; % 空输入表示黑烟车，因为黑烟车占大多数
    else 
        templabel(jk) = 1;
    end
end
end

function templabel = Input2(x)
Local = {'BotLeft','BotRight'}; % 
templabel = 2*ones(1,4);
for jk=1:2
    labelinput = input(['Is the ', Local{jk}, ' smoky? ']); % 按下左，下右，输入0表示是无效帧
    if labelinput == 0
        templabel(jk) = -1; % 标记坏帧，已经同步标签和特征值向量的指标，因此只标记标签即可去除
%                         Video_xfeatures{j}( frame_order,: ) = -1; % 输入0标记为坏帧
%                         LABEL( frame_order, j ) = -1; % 输入0标记为坏帧
    elseif isempty(labelinput)
            templabel(jk) = 0; % 空输入表示非黑烟车，因为非黑烟车占大多数
    else 
        templabel(jk) = 1;
    end
end
end

function templabel = Input1(x)
labelinput = input('Is it smoky? '); % 
if labelinput == 0 
    templabel = -1; % 标记坏帧，已经同步标签和特征值向量的指标，因此只标记标签即可去除
elseif isempty(labelinput)
        templabel = 1; % 空输入表示黑烟车，因为黑烟车占大多数
else 
    templabel = 0;
end
end

end