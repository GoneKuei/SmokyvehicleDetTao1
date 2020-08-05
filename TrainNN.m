% �������ṹ��������dense�㣨ȫ���Ӳ㣩��˳���Ų�
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

% ������ͬ������������ֽ��
rng(1)
% ����ѵ�����ݼ�training data set���ݼ�������ά�ȵ�����ֵ�����Ǿ�����40��ά�ȵģ�
% ������������ά�ȵ�����ֵ֮��ĺ�����ϵ��ifƽ��ֵ���� 0.5, ����ı�ǩֵlabel��Ϊtrue, �������false
% X = rand(2, 1, 1, 10000); % ����Ϊ��ʹ��4ά���󣬲�ֱ����rand(2,10000)?
% Y = mean(reshape(X, 2, 10000), 1) < 0.5;
% Y = reshape(Y, 1, numel(Y));
% Y = categorical(Y, [false, true], {'false', 'true'});
X = xall;
Y = sum(0.*X); % ���趨ȫΪ0�Ķ�ӦX��Y����
% ��Ҫ��docker����ǣ�ֻ��Ǵ����̳���Ȼ������̳���Ϊ1
Y([1:100,300:400])=1;%% ���ԣ�ÿһ����Ƶǰ100֡������Ϊ���̳�
Y = categorical(Y, [0, 1], {'false', 'true'}); %��01��Ӧ�ĳ�true false

% ����ѵ��ѡ����в�û��ʹ��GPU����ѵ������Ϊ����ݶ��½�������SGDM��
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

% ѵ���õ���MATLAB������ģ�Ͷ���Ϊnet
net = trainNetwork(X, Y, layers, opts);