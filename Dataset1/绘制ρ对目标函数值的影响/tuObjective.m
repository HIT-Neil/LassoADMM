% arrayResult = dlmread('hztxtResult.txt',',');

%����Ŀ�꺯��ͼ��
h2 = figure;
dirName = 'Ŀ�꺯���ļ�';
arrayResult = tu(dirName, '0.100000.txt');
[iter, col] = size(arrayResult);
Markersize = 10;
lineWidth = 1;
xAris = 1:5:200;
plot(xAris, arrayResult(xAris,2),'s--','LineWidth',1.5);
hold on;
arrayResult = tu(dirName, '0.500000.txt');
[iter, col] = size(arrayResult);
plot(xAris, arrayResult(xAris,2),'x--','LineWidth',1.5);
hold on;
arrayResult = tu(dirName, '1.000000.txt');
[iter, col] = size(arrayResult);
plot(xAris, arrayResult(xAris,2),'>:','LineWidth',1.5);
hold on;
arrayResult = tu(dirName, '2.000000.txt');
[iter, col] = size(arrayResult);
plot(xAris, arrayResult(xAris,2),'o--','LineWidth',1.5);

set(gcf,'Units','centimeters','Position',[6 6 14.5 12]);
set(gca,'Position',[.15 .15 .8 .75]);
set(get(gca,'XLabel'),'FontSize',16);
xlabel('Iteration');
ylabel('Objective Function Value');
legend( '{\it{�� = 0.1}}','{\it{�� = 0.5}}', '{\it{�� = 1.0}}','{\it{�� = 2.0}}');
grid on;set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',1);
set(gca,'FontSize',16);
%%�ҵ���ǰ·��
p = mfilename('fullpath');
i = findstr(p,'\');
saveFile = p(1:i(end));

%%����ͼ���ļ�
saveObjImg = [saveFile,'\��Objective.eps'];
saveas(gcf,saveObjImg);
saveObjImg = [saveFile,'\��Objective.pdf'];
saveas(gcf,saveObjImg);
saveObjImg = [saveFile,'\��Objective.png'];
saveas(gcf,saveObjImg);