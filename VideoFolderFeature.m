% str = 'D:\video';
% genstr = genpath(str);
% temp = [];
% filepath = {};
% for i = 1:length(genstr) %寻找分割符';'，一旦找到，则将路径temp写入path数组中
%     if genstr(i) ~= ';'
%         temp = [temp genstr(i)];
%     else 
%         temp = [temp '\']; %在路径的最后加入 '\'
%         files = dir(strcat(temp,'*.mp4'));
%         for j = 1:length(files)
%             filepath = [filepath;strcat(temp,files(j).name)];
%         end
%         temp = [];
%     end
% end  
% clear temp;

fds = fileDatastore(fullfile('D:\video'),'ReadFcn',@load,'FileExtensions','.mp4','IncludeSubfolders',1);
filepath = fds.Files; clear fds; % 使用matlab内嵌的数据库来存储视频，缺点是无法在dir中自由使用通配符
% number_files = length(filepath);
% Xall = cell(1,number_files); YieldRateAll = -ones(1,number_files);
% for i=1:number_files
%     [Xall{i},YieldRateAll(i)] = video2features( filepath{i} );
% end
[Xall,Label,Yimage,YieldRateAll,badRates1,badRates2,badRates3,badRates4] = cellfun(@(x)video3features(x,4),filepath,'UniformOutput', false);
xall = cell2mat(Xall);
lall = cell2mat(Label);
Analysis = cell2table([filepath,YieldRateAll,badRates1,badRates2,badRates3,badRates4]);