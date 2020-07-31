% 以109种手动裁剪的区域109i为例，计算其尾部区域
I=imread('109i.jpg');
    [Irear2,Xrear2,Xrear2A3] = reardet(I,1920);
% 绘图以展示效果
    imshow(I)
    line([1,size(I,2),size(I,2),1],[Xrear2,Xrear2,Xrear2A3,Xrear2A3],'LineWidth',2,'Color','b')%'#87CEFA','LineStyle','--'); 同7行放大到90

% 带θ = 0 o , 4 5 o , 9 0 o , 1 3 5 o，d = 2 ，3 的特征值计算函数
allxfea=@(Irear)cellfun(@(th,d)computeXfeature(Irear,th,d),{0,45,90,135,0,45,90,135},{2,2,2,2,3,3,3,3},'UniformOutput',false);
    Xfeatures=cell2mat(allxfea(Irear2)); % 这是109i区域计算得出的1*40尾部GLCM特征向量

% 利用rangefilt计算车尾区域
function [Irear,Xrear,XrearA3] = reardet(frame,width)
% 设置默认width，即如果不输入width，设置为width1920
a=[9,5,60]; % 原文参数，依次为height of vehicle rear，rangefilt的NHOOD的大小，height of Irear
    a=round(a.*(width/768));a(2)=floor(a(2)/2)*2+1; % 原文使用的视频宽度为768*432，对1920*1080进行了压缩；a2必须是奇数区域
if ischar(frame)
    I=imread(frame);
else
    I=frame;
end
grayI=rgb2gray(I);
    J=rangefilt(grayI,ones(a(2),a(2)));
    E=rescale(sum(J,2),-1,1); % ；这一步并不会对xrear有影响；内置的normalize函数是设置均值为0、标准差为1，因此会超出[-1,1]的范围

[h,w]=size(grayI);

rearIndex=(round(h/2):h)-(0:(a(1)-1))';
    [~,Xrear]=max(range(E(rearIndex)));
    Xrear=rearIndex(1)+Xrear-1;
    
Irear=grayI(Xrear:min(Xrear+a(3),h),1:w);

XrearA3=Xrear+a(3);
end

% 利用GLCM（graycomatrix）计算其特征向量，共40个
function xfeature = computeXfeature(Irear,th,d)
% P=graycomatrix(Irear,'offset',[dth(1)*sin(dth(2)),dth(1)*cos(dth(2))]);%,'NumLevels',8); % 原文缺少numlevel参数
P=graycomatrix(Irear,'offset',[round(d*sin(th)),round(d*cos(th))]);%,'NumLevels',8); % 原文缺少numlevel参数
    Phat=rescale(P,1e-100,1); % P是一个自然数矩阵, 因此推测这里的nomalized也应该是0~1的rescale.

[i,j]=size(P);
    I=(1:i)'*ones(1,j);
    J=ones(i,1)*(1:j);

ASM=sum(Phat.^2,"all");
ENT=-sum(Phat.*log(Phat),'all');
CON=sum((I-J).^2.*Phat,'all');
    muX=sum(I.*Phat,"all");muY=sum(J.*Phat,"all");siX=sum((I-muX).^2.*Phat,'all');siY=sum((J-muY).^2.*Phat,"all");
COR=(sum(I.*J.*Phat,"all")-muX*muY)/(siX*siY);
IDM=sum(P./(1+(I-J).^2),"all");

xfeature=[ASM,ENT,CON,COR,IDM];
end
