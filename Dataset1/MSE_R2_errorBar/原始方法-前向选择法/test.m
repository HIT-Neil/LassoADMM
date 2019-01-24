clear all;
clc;
%% ��������
data = load('sto.tab.v2.txt');
x = data(:,1:10);
y = data(:,11);

%% ��������
yMean = mean(y);
yDeal = y-yMean;
xMean = mean(x);
xVar = var(x,1);
[m,n] = size(x);
xDeal = zeros(m,n);
for i = 1:m
    for j = 1:n
        xDeal(i,j) = (x(i,j)-xMean(j))/xVar(j);
    end
end
 
%% ѵ��
runtime  = 40000;%�����Ĳ���
eps = 0.001;%��������
for Block = [90]
    %% �������ݼ�
    
    [examples,Col] = size(data);
    %% Ϊģ�ͼ��Ͻؾ�
    dataTmp = zeros(examples,Col+1);
    dataTmp(:,1) = ones(examples,1);  %���õ�һ��Ϊ1��Ϊ�ؾ��������
    dataTmp(:,2:Col+1) = data(:,:);
    data = dataTmp;

    trainingNum = floor(examples*0.7);
    testExamples = data(trainingNum+1:examples,:);
    data = data(1:trainingNum,:);

    x = data(:, 1:Col);
    y = data(:, Col+1);
    features = Col;
    oneBlock = floor(trainingNum/Block);% ÿ�����ṩ������
    %% ���ѵ����ƽ��
    his.wResult = zeros(Block, features);
    his.lossResult = zeros(Block, 1);
%     myIter = 0;
%     MSE = 0;
%     R2 = 0;
%     R2Adjusted = 0;
%     testMSE = 0;
%     testR2 = 0;
%     testR2Adjusted = 0;
    myIter = zeros(Block);
    MSE = zeros(Block);
    R2 = zeros(Block);
    R2Adjusted = zeros(Block);
    testMSE= zeros(Block);
    testR2 = zeros(Block);
    testR2Adjusted = zeros(Block);
    index0 = 1;
    index1 = 1;
    R2index0 = 1;
    R2index1 = 1;
    R2Adjustedindex0 = 1;
    R2Adjustedindex1 = 1;
    for index = 1:Block
        xTrain = x((index-1)*oneBlock + 1 : index*oneBlock, :);
        yTrain = y((index-1)*oneBlock + 1 : index*oneBlock,:);
        [wResult1,lossResult1,history] = stageWise(xTrain, yTrain, eps, runtime, testExamples);
        his.wResult(index,:) = wResult1(runtime,:);
        his.lossResult(index,:) = lossResult1(runtime,:);
        myIter(index) = history.myIter;
        MSE(index) = history.MSE;
%         mse = MSE
        R2(index) = history.R2;
        R2Adjusted(index) = history.R2Adjusted;
        testMSE(index) = history.testMSE;
        testR2(index) = history.testR2;
        testR2Adjusted(index) = history.testR2Adjusted;
        %%MSE�ڲ��Ի�����С�ĵ㣬���ĵ�
        if history.testMSE < testMSE(index0)
            index0 = index;
        end
        if history.testMSE > testMSE(index1)
            index1 = index;
        end
        
        %%R2�ڲ��Ի�����С�ĵ�,���ĵ�
        if history.R2 < testR2(R2index0)
            R2index0 = index;
        end
        if history.R2 > testR2(R2index1)
            R2index1 = index;
        end
        
        %%R2Adjusted�ڲ��Ի�����С�ĵ�,���ĵ�
        if history.R2Adjusted < testR2Adjusted(R2Adjustedindex0)
            R2Adjustedindex0 = index;
        end
        if history.R2Adjusted > testR2Adjusted(R2Adjustedindex1)
            R2Adjustedindex1 = index;
        end
        
%         testmse = testMSE
        
    end
    wResult = his.wResult(index0,:);
    lossResult = his.lossResult(index0,:);
    
    myIter_now = myIter(index0);
    MSE_low = MSE(index0);
    R2_low = R2(index0);
    R2Adjusted_low = R2Adjusted(index0);
    testMSE_low = testMSE(index0);
    testMSE_high = testMSE(index1);
    testR2_low = testR2(index0);
    testR2_high = testR2(index1);
    testR2Adjusted_low = testR2Adjusted(index0);
    testR2Adjusted_high = testR2Adjusted(index1);%%����MSE�������С����R2��R2Adjusted��С
    
    my_testR2_low = testR2(R2index0);
    my_testR2_high = testR2(R2index1);
    my_testR2Adjusted_low = testR2Adjusted(R2Adjustedindex0);
    my_testR2Adjusted_high = testR2Adjusted(R2Adjustedindex1);%%����MSE�������С����R2��R2Adjusted��С
    
    
    %% �ҵ���ǰ·��
    p = mfilename('fullpath');
    i = findstr(p,'\');
    saveFile = p(1:i(end));

    %% ��������д�ļ�
    iterFileName = [saveFile, 'iter.txt'];              %Ŀ�꺯���ļ�
    fiter = fopen(iterFileName,'a');                % ���������ļ�
    fprintf(fiter,'%-5d %-5d\r\n',Block, myIter_now);
    fclose(fiter);
    %% ���д���ļ�
    evaluateFile = [saveFile,'MSE.txt'];       %��¼MSE R2 R2_Adjusted
    fevaluate1 = fopen(evaluateFile,'a');          % �������ȴ������ļ�
    fprintf(fevaluate1,'%-5d %-5f %-5f %-5f %-5f %-5f %-5f %-5f %-5f %-5f %-5f %-5f %-5f %-5f\r\n',Block, MSE_low, R2_low, R2Adjusted_low, testMSE_low ,testMSE_high,testR2_low,testR2_high,testR2Adjusted_low,testR2Adjusted_high,my_testR2_low,my_testR2_high,my_testR2Adjusted_low,my_testR2Adjusted_high ); %�������ļ���д�� MSE + R2 + R2_Adjusted
    fclose(fevaluate1);%%����������Ϊ��MSE�����Сʱѵ�����ϵ�MSE��R2��R2Adjusted;���Լ���MSE��R2��R2Adjusted�����Сֵ;������MSEʱ��R2��R2Adjustedֵ

    %% ��������ֵ
    paramFile = [saveFile,'featureVector.txt'];
    fVector = fopen(paramFile,'a');                % �����ݱ��浽�ļ���
    fprintf(fVector,'%-5d ',Block);       %���������ļ���д����������
    fprintf(fVector,'%-5f ',his.wResult(index0,:));       %���������ļ���д����������
    fprintf(fVector,'\r\n');
    fclose(fVector);

    %% ����wResult������������
    hold on 
    xAxis = 1:runtime;
    for i = 1:n
        plot(xAxis, wResult1(:,i));
    end
    %% ����ͼ���ļ�
%     saveObjImg = [saveFile,'\coefficient.png'];
%     saveas(gcf,saveObjImg);

    %%Ŀ�꺯��ͼ
    h = figure;
    plot(xAxis, lossResult1);
    %% ����ͼ���ļ�
    saveObjImg = [saveFile,'\Objective.png'];
    saveas(gcf,saveObjImg);
    
    %%MSE ͼ
    h = figure;
    plot(xAxis, history.MSEN);
    %% ����ͼ���ļ�
%     saveObjImg = [saveFile,'\MSE.png'];
%     saveas(gcf,saveObjImg);
end