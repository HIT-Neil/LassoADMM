function [w,v,history] = lassoConjGradTest(rho, lambda, yalmipFile,patientNo,dataName,dirName)


t_start = tic;%����ʱ���

dataFile = [yalmipFile,'\',dataName];
dataAll = load(dataFile);  %���ļ�������

% dataAll = dataAll(1:400,:);  % ���ݲ���������̬����������Ŀ
% dataAll(401:800,:) = dataAll(1:400,:);
% dataAll(801:1600,:) = dataAll(1:800,:);

[w,v,W_i, V_i, history] = lassoConjGrad(dataAll, lambda, rho, patientNo);

K = length(history.primObjective);
paramFile = [yalmipFile,'\',dataName,'_featureVector.txt'];
evaluateFile1 = [yalmipFile,'\',dataName,'_MSE_R2.txt'];       %��¼MSE R2 R2_Adjusted

%����Ŀ�꺯���ļ���
objectPath = [yalmipFile,'\Ŀ�꺯���ļ�'];            %% ����Ŀ�꺯���ļ���
if ~exist(objectPath)
    mkdir(objectPath)
end;    
strpatientNo = num2str(lambda,'%3f');                        %UE����ת��Ϊ�ַ���
objectFileName = [objectPath,'\',strpatientNo,'.txt'];              %Ŀ�꺯���ļ�

%�������������ļ���
iterFile = [yalmipFile,'\���������ļ�'];            %% ����Ŀ�꺯���ļ���
if ~exist(iterFile)
    mkdir(iterFile)
end;    

iterFileName = [iterFile,'\','iter.txt'];              %���������ļ�

fVector = fopen(paramFile,'a');                % �����ݱ��浽�ļ���
fevaluate1 = fopen(evaluateFile1,'a');          % �������ȴ������ļ�
fobject = fopen(objectFileName,'a');            % Ŀ�꺯���ļ�
fiter = fopen(iterFileName,'a');                % ���������ļ�

fprintf(fVector,'\r\n %-5d: ',patientNo);    %д�� UE ����ֵ
fprintf(fevaluate1,'%-5d ',patientNo);

%���������ļ���д�� UE + lambda + rho + iter
fprintf(fiter,'%-5d %-5d %-5d %-5d\r\n',patientNo, lambda, rho, history.OriginalResidualsIter);

for i = 1:K                                   %Ŀ�꺯���ļ���д��Ŀ�꺯��ֵ
    fprintf(fobject,'%-5d ',i);
    fprintf(fobject,'%-5d ',history.beforeADMMObjective(i));
    fprintf(fobject,'%-5d ',history.primObjective(i));
    fprintf(fobject,'%-5d\r\n',history.dualObjective(i));
end;

fprintf(fVector,' %-5f ',w);       %���������ļ���д���������� + �ؾ�
fprintf(fVector,' %-5f\r\n',v);

fprintf(fevaluate1,'%-5f %-5f %-5f %-5f %-5f %-5f\r\n',history.MSE(K), history.R2(K), history.R2_adjusted(K),history.testMSE, history.testR2, history.testR2_adjusted ); %�������ļ���д�� MSE + R2 + R2_Adjusted

fclose(fVector);   %�ر��ļ�
fclose(fevaluate1);
fclose(fobject);
fclose(fiter)

strlambda = num2str(lambda,'%3f');
strrho = num2str(rho,'%3f');
strpatientNo = num2str(patientNo,'%3d');                        %UE����ת��Ϊ�ַ���
saveFile = [yalmipFile,dirName,strpatientNo,'��',strlambda,'��',strrho];

if ~exist(saveFile)
    mkdir(saveFile)
end;

%����Ŀ�꺯��ֵ��ͼ��
K = length(history.primObjective);
h = figure;
plot(1:K, history.beforeADMMObjective, 'k-', 'MarkerSize', 10, 'LineWidth', 2);
hold on;
% t1 = [1, K];
optiobjvalArray = zeros(1,K) + history.optiobjval;
% t2 = [history.optiobjval, history.optiobjval];
plot(1:K, optiobjvalArray, 'r--', 'MarkerSize', 10, 'LineWidth', 2);
set(gca,'FontSize',16);
legend('ADMM-Algorithm','Centralized-Algorithm');
ylabel('Value of Objective'); xlabel('iter (k)');
saveObjImg = [saveFile,'\Objective.png'];
saveas(gcf,saveObjImg);

%����lasso�ع��ϵ��ͼ�񣺵������ܶ��ʱ���ܹ��۲쵽�ĸ��������������ñȽϴ�
h1 = figure;
plot(w,'k-','MarkerSize', 10, 'LineWidth', 2);
hold on;
plot(history.optW,'r--','MarkerSize', 10, 'LineWidth', 2);
set(gca,'FontSize',16);
legend('ADMM-Coefficient','Centralized-Coefficient');
ylabel('Coefficient'); xlabel('Feature');
saveObjImg = [saveFile,'\Coefficient.png'];
saveas(gcf,saveObjImg);

%����R��ֵ��R��У��ֵ
h2 = figure;
plot(1:K, history.R2,'k-','MarkerSize', 10, 'LineWidth', 2);
hold on;
plot(1:K, history.R2_adjusted,'r--','MarkerSize', 10, 'LineWidth', 2);
set(gca,'FontSize',16);
legend('R^2','R^2Adjusted');
xlabel('iter (k)');
ylabel('R^2 Score');
saveObjImg = [saveFile,'\R2.png'];
saveas(gcf,saveObjImg);

%����ѵ�������ֵ
h3 = figure;
plot(1:K, history.MSE,'r-','MarkerSize', 10, 'LineWidth', 2);
hold on;
plot(1:K, history.centralizeMSE,'k--','MarkerSize', 10, 'LineWidth', 2);
set(gca,'FontSize',16);
legend('ADMM-MSE','Centralized-MSE');
xlabel('iter (k)');
ylabel('Mean Squared Error');
saveObjImg = [saveFile,'\MSE.png'];
saveas(gcf,saveObjImg);

%����ԭʼ�в��ż�в��ͼ��
g = figure;
subplot(2,1,1);
semilogy(1:K, max(1e-8, history.r_norm), 'k-', ...
    1:K, history.eps_pri, 'r--',  'LineWidth', 2);
set(gca,'FontSize',16);
legend('ADMM-ԭʼ�в�','ֹͣ����');
ylabel('||r||_2');

subplot(2,1,2);
semilogy(1:K, max(1e-8, history.s_norm), 'k-', ...
    1:K, history.eps_dual, 'r--', 'LineWidth', 2);
set(gca,'FontSize',16);
legend('ADMM-��ż�в�','ֹͣ����');
ylabel('||s||_2'); xlabel('iter (k)');
saveResidualImg = [saveFile,'\Residual.png'];
saveas(gcf,saveResidualImg);
% system('shutdown -s');
