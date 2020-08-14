% % 检验 只关心是否为黑烟车，因此仅仅做一次标签
% str = 'D:\video1';
% genstr = genpath(str);
% temp = [];
% filepath = {};
% for i = 1:length(genstr) %寻找分割符';'，一旦找到，则将路径temp写入path数组中
%     if genstr(i) ~= ';'
%         temp = [temp genstr(i)];
%     else 
%         temp = [temp '\']; %在路径的最后加入 '\'
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
filepath = fds.Files; clear fds; % 使用matlab内嵌的数据库来存储视频，缺点是无法在dir中自由使用通配符

warning = input('Have you delete all 0KB files? They would ruin your LABEL! ');
[Xall,Label,Yimage,YieldRateAll,badRates1,badRates2,badRates3] = cellfun(@(x)video3features(x,1),filepath,'UniformOutput', false);
xall = cell2mat(Xall);
lall = cell2mat(Label);
Analysis = [filepath,YieldRateAll,badRates1,badRates2,badRates3];