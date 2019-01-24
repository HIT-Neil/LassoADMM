volume_mean=[0.73,0.45;

                        0.42,0.43;

                        0.70,0.42];                         

volume_std=[0.65,0.17;

                     0.35,0.14;

                     0.44,0.13];

%��ͼ                     

close all;figure;

h=bar(volume_mean);

set(h,'BarWidth',0.9);        % ��״ͼ�Ĵ�ϸ

hold on;

set(h(1),'facecolor',[139 35 35]./255) % ��һ��������ͼ��ɫ

% set(h(2),'facecolor','k')        % �ڶ���������ͼ��ɫ
ngroups = size(volume_mean,1);

nbars = size(volume_mean,2);

disp('**************ngroups : ');
disp(ngroups);
disp('**************nbars : ');
disp(nbars);
groupwidth =min(0.8, nbars/(nbars+1.5));


% errorbar����ò�ͬ��ɫ����������colormap����ɫ����ѭ����ǣ��������û���õ�colormap

%colormap(flipud([0 100/255 0; 220/255 20/255 60/255; 1 215/255 0; 0 0 1]));   % blue / red

% color=[0 100/255 0; 220/255 20/255 60/255; 1 215/255 0; 0 0 1];

hold on;
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    disp('**************x : ');
    disp(x);
    errorbar(x,volume_mean(:,i),volume_std(:,i),'o','color',[.5 .5 .5],'linewidth',2);
end
set(gca,'XTickLabel',{'2014','2015','2016'},'fontsize',16,'linewidth',1.5)
ylim([0 1.5])
set(gca,'ytick',0:0.5:1.5)
xylabel(gca,' ','Volume[Sv]')
legend('data1','data2','location','NorthEast')
