% % ���� ֻ�����Ƿ�Ϊ���̳�����˽�����һ�α�ǩ
% str = 'D:\video1';
% genstr = genpath(str);
% temp = [];
% filepath = {};
% for i = 1:length(genstr) %Ѱ�ҷָ��';'��һ���ҵ�����·��tempд��path������
%     if genstr(i) ~= ';'
%         temp = [temp genstr(i)];
%     else 
%         temp = [temp '\']; %��·���������� '\'
%         files = dir(strcat(temp,'testout?.mp4'));
% %         j=1;
% %         while files(j).name~='testout.mp4'
%         for j = 1:length(files)
%             filepath = [filepath;strcat(temp,files(j).name)];
% %             j=j+1;
%         end
%         temp = [];
%     end
% end  
% clear temp;

fds = fileDatastore(fullfile('D:\video'),'ReadFcn',@load,'FileExtensions','.mp4','IncludeSubfolders',1);
filepath = fds.Files; clear fds; % ʹ��matlab��Ƕ�����ݿ����洢��Ƶ��ȱ�����޷���dir������ʹ��ͨ���

warning = input('Have you delete all 0KB files? They would ruin your LABEL! ');
[Xall,Label,Yimage,YieldRateAll,badRates1,badRates2,badRates3] = cellfun(@(x)video3features(x,1),filepath,'UniformOutput', false);
xall = cell2mat(Xall);
lall = cell2mat(Label);
Analysis = [filepath,YieldRateAll,badRates1,badRates2,badRates3];