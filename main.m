% ��109���ֶ��ü�������109iΪ����������β������
I=imread('109i.jpg');
    [Irear2,Xrear2,Xrear2A3] = reardet(I,1920);
% ��ͼ��չʾЧ��
    imshow(I)
    line([1,size(I,2),size(I,2),1],[Xrear2,Xrear2,Xrear2A3,Xrear2A3],'LineWidth',2,'Color','b')%'#87CEFA','LineStyle','--'); ͬ7�зŴ�90

% ���� = 0 o , 4 5 o , 9 0 o , 1 3 5 o��d = 2 ��3 ������ֵ���㺯��
allxfea=@(Irear)cellfun(@(th,d)computeXfeature(Irear,th,d),{0,45,90,135,0,45,90,135},{2,2,2,2,3,3,3,3},'UniformOutput',false);
    Xfeatures=cell2mat(allxfea(Irear2)); % ����109i�������ó���1*40β��GLCM��������

% ����rangefilt���㳵β����
function [Irear,Xrear,XrearA3] = reardet(frame,width)
% ����Ĭ��width�������������width������Ϊwidth1920
a=[9,5,60]; % ԭ�Ĳ���������Ϊheight of vehicle rear��rangefilt��NHOOD�Ĵ�С��height of Irear
    a=round(a.*(width/768));a(2)=floor(a(2)/2)*2+1; % ԭ��ʹ�õ���Ƶ���Ϊ768*432����1920*1080������ѹ����a2��������������
if ischar(frame)
    I=imread(frame);
else
    I=frame;
end
grayI=rgb2gray(I);
    J=rangefilt(grayI,ones(a(2),a(2)));
    E=rescale(sum(J,2),-1,1); % ����һ���������xrear��Ӱ�죻���õ�normalize���������þ�ֵΪ0����׼��Ϊ1����˻ᳬ��[-1,1]�ķ�Χ

[h,w]=size(grayI);

rearIndex=(round(h/2):h)-(0:(a(1)-1))';
    [~,Xrear]=max(range(E(rearIndex)));
    Xrear=rearIndex(1)+Xrear-1;
    
Irear=grayI(Xrear:min(Xrear+a(3),h),1:w);

XrearA3=Xrear+a(3);
end

% ����GLCM��graycomatrix��������������������40��
function xfeature = computeXfeature(Irear,th,d)
% P=graycomatrix(Irear,'offset',[dth(1)*sin(dth(2)),dth(1)*cos(dth(2))]);%,'NumLevels',8); % ԭ��ȱ��numlevel����
P=graycomatrix(Irear,'offset',[round(d*sin(th)),round(d*cos(th))]);%,'NumLevels',8); % ԭ��ȱ��numlevel����
    Phat=rescale(P,1e-100,1); % P��һ����Ȼ������, ����Ʋ������nomalizedҲӦ����0~1��rescale.

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
