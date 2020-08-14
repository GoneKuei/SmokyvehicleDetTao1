% str = 'D:\video';
% genstr = genpath(str);
% temp = [];
% filepath = {};
% for i = 1:length(genstr) %Ѱ�ҷָ��';'��һ���ҵ�����·��tempд��path������
%     if genstr(i) ~= ';'
%         temp = [temp genstr(i)];
%     else 
%         temp = [temp '\']; %��·���������� '\'
%         files = dir(strcat(temp,'*.mp4'));
%         for j = 1:length(files)
%             filepath = [filepath;strcat(temp,files(j).name)];
%         end
%         temp = [];
%     end
% end  
% clear temp;

fds = fileDatastore(fullfile('D:\video'),'ReadFcn',@load,'FileExtensions','.mp4','IncludeSubfolders',1);
filepath = fds.Files; clear fds; % ʹ��matlab��Ƕ�����ݿ����洢��Ƶ��ȱ�����޷���dir������ʹ��ͨ���
% number_files = length(filepath);
% Xall = cell(1,number_files); YieldRateAll = -ones(1,number_files);
% for i=1:number_files
%     [Xall{i},YieldRateAll(i)] = video2features( filepath{i} );
% end
[Xall,Label,Yimage,YieldRateAll,badRates1,badRates2,badRates3,badRates4] = cellfun(@(x)video3features(x,4),filepath,'UniformOutput', false);
xall = cell2mat(Xall);
lall = cell2mat(Label);
Analysis = cell2table([filepath,YieldRateAll,badRates1,badRates2,badRates3,badRates4]);