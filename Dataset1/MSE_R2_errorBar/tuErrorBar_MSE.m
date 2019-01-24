p1 = mfilename('fullpath');
i = findstr(p1,'\');
pPath = p1(1:i(end));

ADMMFile = 'sto.tab.v2.txt_MSE_R2.txt';
cd(pPath);
dataADMM = load(ADMMFile);
xAxis = dataADMM(:,1);

testMSE = dataADMM(:,5);
testR2 = dataADMM(:,6);
testR2Adjusted = dataADMM(:,7);

CentralizedFile = 'MSE.txt';
dataCentralized = load(CentralizedFile);
CentralizedtestMSE = dataCentralized(:,5);
CentralizedtestMSE_high = dataCentralized(:,6);
CentralizedtestR2 = dataCentralized(:,7);
CentralizedtestR2_high = dataCentralized(:,8);
CentralizedtestR2Adjusted = dataCentralized(:,9);
CentralizedtestR2Adjusted_high = dataCentralized(:,10);

CentralizedtestR21 = dataCentralized(:,11);
CentralizedtestR21_high = dataCentralized(:,12);
CentralizedtestR2Adjusted1 = dataCentralized(:,13);
CentralizedtestR2Adjusted1_high = dataCentralized(:,14);

%% �ҵ���ǰ·��
saveFile = p1(1:i(end));
%% MSE ͼ��ѡ��������Сֵ
CentralizedtestMSE_mid = (CentralizedtestMSE + CentralizedtestMSE_high)/2;
volume_std = (CentralizedtestMSE_high - CentralizedtestMSE)/2;
H1 = figure;
set(gcf,'Units','centimeters','Position',[6 6 14.5 12]);
set(gca,'Position',[.15 .15 .8 .75]);
set(get(gca,'XLabel'),'FontSize',16);
% all = [testMSE'; CentralizedtestMSE_mid'];
% h1 = bar(xAxis' , all', 'grouped');
plot(xAxis,testMSE,'s--','linewidth',1.5);
set(gca,'XTickMode','manual','XTick',[1 15 30 45 60 75 90]); 
set(gca,'FontSize',16);
xlabel('{\it{N}}');
ylabel('MSE Value');
grid on;set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',1);
axis([-5, 99,-1,50]);
hold on;
groupwidth =min(7, 7/(2+1.5));
x = xAxis + groupwidth;
errorbar(xAxis,CentralizedtestMSE_mid,volume_std,'>:','linewidth',1.5);
legend('ADMM','Independent','location','NorthWest');
set(gcf,'Units','centimeters','Position',[6 6 14.5 12]);
set(gca,'Position',[.15 .15 .8 .75]);
set(get(gca,'XLabel'),'FontSize',16);
%% ��ͷ
annotation('textarrow',[.5,.5],[.2,.3],'linewidth',1.5);
%% ������ͼ
axes('Position',[0.28,0.4,0.5,0.3]);   
%% �����ݼ�
xa = 1:4;
testMSE0 = testMSE(xa,:);
CentralizedtestMSE_mid0 = CentralizedtestMSE_mid(xa,:);
volume_std0 = volume_std(xa,:);
xAxis0 = [1 15 30 45];

plot(xAxis0,testMSE0,'s--','linewidth',1.5);
set(gca,'XTickMode','manual','XTick',[1 15 30 45],'YTick',[0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08]); 
set(gca,'FontSize',12);
grid on;set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',1);
axis([-5, 55,0,0.08]);
hold on;
errorbar(xAxis0,CentralizedtestMSE_mid0,volume_std0,'>:','linewidth',1.5);
%% ����ͼ��
saveObjImg = [saveFile,'\MSEError.pdf'];
saveas(gcf,saveObjImg);
saveObjImg = [saveFile,'\MSEError.png'];
saveas(gcf,saveObjImg);