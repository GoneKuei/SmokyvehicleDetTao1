% 设计网络结构，把三个dense层（全连接层）按顺序排布
layers = [
    sequenceInputLayer(80)
    fullyConnectedLayer(80)
    reluLayer()
    fullyConnectedLayer(10)
    reluLayer()
    fullyConnectedLayer(2)
    softmaxLayer()
    classificationLayer()
];

% 设置相同随机数用来复现结果
rng(1)
% 生成训练数据集training data set数据集有两个维度的特征值（咱们具体用40个维度的）
% 举例：这两个维度的特征值之间的函数关系是if平均值大于 0.5, 输出的标签值label设为true, 否则就是false
% X = rand(2, 1, 1, 10000); % 这里为何使用4维矩阵，不直接用rand(2,10000)?
% Y = mean(reshape(X, 2, 10000), 1) < 0.5;
% Y = reshape(Y, 1, numel(Y));
% Y = categorical(Y, [false, true], {'false', 'true'});
X = xall;
Y = sum(0.*X); % 先设定全为0的对应X的Y矩阵
% 需要用docker做标记，只标记处黑烟车，然后给黑烟车改为1
Y([1:100,300:400])=1;%% 测试，每一段视频前100帧数设置为黑烟车
Y = categorical(Y, [0, 1], {'false', 'true'}); %将01相应改成true false

% 设置训练选项（其中并没有使用GPU），训练函数为随机梯度下降函数（SGDM）
opts = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.001, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 8, ...
    'L2Regularization', 0.004, ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 100, ...
    'Verbose', true, ...
    'Plots','training-progress');

% 训练得到的MATLAB神经网络模型对象为net
net = trainNetwork(X, Y, layers, opts);