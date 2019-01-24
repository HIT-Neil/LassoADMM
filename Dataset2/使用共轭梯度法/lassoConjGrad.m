function [w,v,W_i, V_i, history] = lassoConjGrad(dataAll, lambda, rho, patientNo)

t_start = tic;%����ʱ���
QUIET    = 0;
ABSTOL   = 1e-4;%����������̶Ⱥ�������̶�
RELTOL   = 1e-2;

%Data preprocessing
[examples,Col] = size(dataAll);

% [examples, feature] = size(dataAll);
trainingNum = floor(examples*0.7);
testExamples = dataAll(trainingNum+1:examples,:);
dataAll = dataAll(1:trainingNum,:);

data = dataAll(:, 1:Col-1);
b0 = dataAll(:, Col);
features = Col-1;

onepatientSample = floor(trainingNum/patientNo);% ÿ�������ṩ������

MAX_ITER = 10000;
%��ʼֵ��ֵ
flag = 0;
w = zeros(1,features);        % �����������ϵ��
v = 0;
W_i = zeros(patientNo,features);        % ��������
V_i = zeros(patientNo,1);

gama_w = zeros(patientNo,features);        % ��������ƽ��ֵ
gama_v = zeros(patientNo,1);

if ~QUIET
    fprintf('%3s\t%10s\t%10s\t%10s\t%10s\t%10s\n', 'iter', ...
      'r norm', 'eps pri', 's norm', 'eps dual', 'objective');
end

for k=1:MAX_ITER
    wold = w;
    vold = v;
    
    % w-update
    x = mean(W_i,1) + mean(gama_w,1)/rho;  %mean(a,1) :�������ֵ
    kappa = lambda/(rho*patientNo);        
    w = shrinkage(x, kappa);               %[x - kappa]+  - [-x - kappa]+
    v = mean(V_i,1) + mean(gama_v,1)/rho;
    
    W_iold = W_i;
    V_iold = V_i;
 
    % ʹ�ù����ݶȷ����� W_i-update  V_i-update
    for i = 1:patientNo
        A_i = data(onepatientSample*(i-1)+1:onepatientSample*i,:);
        b_i = b0(onepatientSample*(i-1)+1:onepatientSample*i,1);
        C = A_i;
        B = b_i - V_i(i,1);
        W_col = w;
        TOLERANCE = 1e-5;
        ITER = 50;
        I = eye(features);
        x = zeros(1,features);
%         f = @(w) (1/(2*patientNo*onepatientSample)*sum((C*w' - B).^2) + (rho/2)*(w*(w-2*W_col + 2/rho*gama_w(i,:))') + (rho/2)*V_i(i,1)*(V_i(i,1) - 2*v + 2/rho *gama_v(i,1)) );
        f = @(w) (1/(2)*sum((C*w' - B).^2) + (rho/2)*(w*(w-2*W_col + 2/rho*gama_w(i,:))') + (rho/2)*V_i(i,1)*(V_i(i,1) - 2*v + 2/rho *gama_v(i,1)) );
        
        fx = f(x);
%         g = 1/(patientNo*onepatientSample)*(x*C'*C - B'*C) + rho*x - rho*W_col + gama_w(i,:);
        g = (x*C'*C - B'*C) + rho*x - rho*W_col + gama_w(i,:);
        pk = -g;
        epsW = 2;
        if norm(g,2) > TOLERANCE
           for iter = 1:ITER
%                 cvx_begin quiet
%                     variable lambdak
%                     minimize( f(x + lambdak*pk) )
%                 cvx_end
                lambdak = 0.01;
                for t = -1:2:1
                    if f(x + lambdak*pk) > f(x + epsW*t*pk)
                        lambdak = t;
                    end;
                end;
                xold = x;
                gold = g;
                x = x + lambdak*pk;
%                 g = 1/(patientNo*onepatientSample)*(x*C'*C - B'*C) + rho*x - rho*W_col + gama_w(i,:);
                g = (x*C'*C - B'*C) + rho*x - rho*W_col + gama_w(i,:);
                betak = norm(g,2)^2/norm(gold,2)^2;
                pk = -g + betak*pk;

                if norm(g,2) < TOLERANCE
                    break;
                end
            end
        end
        W_i(i,:) = x;
    end;
    for i = 1:patientNo
        A_i = data(onepatientSample*(i-1)+1:onepatientSample*i,:);
        b_i = b0(onepatientSample*(i-1)+1:onepatientSample*i,1);
        C = A_i*W_i(i,:)'-b_i;
        W_col = w;
        V_col = v;
        wi = W_i(i,:);
        TOLERANCE = 1e-5;
        ITER = 50;
        x = 0;
%         f = @(v) ( 1/(2*patientNo*onepatientSample)*sum((C + v).^2) + (rho/2)*((wi*(wi-2*W_col + 2/rho*gama_w(i,:))')) + (rho/2)*v*(v - 2*V_col + 2/rho *gama_v(i,1)) );
        f = @(v) ( 1/(2)*sum((C + v).^2) + (rho/2)*((wi*(wi-2*W_col + 2/rho*gama_w(i,:))')) + (rho/2)*v*(v - 2*V_col + 2/rho *gama_v(i,1)) );

        fx = f(x);
%         g = 1/(patientNo*onepatientSample)*(x + sum(C)) + rho*x - rho*V_col + gama_v(i,1);
        g = (x*onepatientSample + sum(C)) + rho*x - rho*V_col + gama_v(i,1);
        pk = -g;
        eps = 2000;
        if norm(g,2) > TOLERANCE
           for iter = 1:ITER
%                 cvx_begin quiet
%                     variable lambdak
%                     minimize( f(x + lambdak*pk) )
%                 cvx_end
                lambdak = 0.01;
                for t = -1:2:1
                    if f(x + lambdak*pk) > f(x + eps*t*pk)
                        lambdak = t;
                        
                    end;
                end;
%                 A = (rho + onepatientSample)/2;
%                 lambda = -g*pk/(pk'*A*pk);
                xold = x;
                gold = g;
                x = x + lambdak*pk;
%                 disp( [ '   g     =  ', sprintf( '%d ', g ) ] );
%                 g = 1/(patientNo*onepatientSample)*(x + sum(C)) + rho*x - rho*V_col + gama_v(i,1);
                g = (x*onepatientSample + sum(C)) + rho*x - rho*V_col + gama_v(i,1);
                betak = norm(g,2)^2/norm(gold,2)^2;
                
                
                pk = -g + betak*pk;

                if norm(g,2) < TOLERANCE
                    break;
                end
            end
        end
        V_i(i,:) = x;
        
    end;
    
    % gama_w gama_v-update
    for i = 1:patientNo
        gama_w(i,:) = gama_w(i,:) + rho*(W_i(i,:) - w);
        gama_v(i) = gama_v(i) + rho*(V_i(i) - v);
    end;
    
    dualObjective = 0;           % �����ż��ʧ����
    primObjective = 0;           % ����ԭʼ��ʧ����
    for i=1:patientNo
        A_i = data(onepatientSample*(i-1)+1:onepatientSample*i,:);
        b_i = b0(onepatientSample*(i-1)+1:onepatientSample*i,1);
        dualObjective = dualObjective + 1/(2)*sum((A_i*W_i(i,:)' + V_i(i) - b_i).^2) + (W_i(i,:) - w)*gama_w(i,:)'+gama_v(i)*(V_i(i)-v) + 0.5*rho*((W_i(i,:) - w)*(W_i(i,:) - w)'+(V_i(i)-v)^2);
        primObjective = primObjective + 1/(2)*sum((A_i*W_i(i,:)' + V_i(i) - b_i).^2);
    end;
    history.dualObjective(k) = dualObjective + lambda*norm(w,1);
    history.primObjective(k) = primObjective + lambda*norm(w,1);
    
    %���շ�ADMM��ʽ��Ŀ�꺯�����Ŀ�꺯��ֵ
    history.beforeADMMObjective(k) = 1/2*sum((data*w' + v - b0).^2) + lambda*norm(w,1);
    %% ������ѵ����
    %����R��ֵ
    fenzi = sum( (b0 - data*w'- v).^2 );
    fenmu = sum( (b0 - mean(b0)).^2 );
    history.R2(k) = 1 - fenzi/fenmu;

    %����R��У������ϵ��
    history.R2_adjusted(k) = 1 - ((1-history.R2(k))*(trainingNum-1))/(trainingNum - features - 1);
    
    %ѵ�������
    history.MSE(k) = (fenzi/trainingNum);
    
    %% ���ݼ���������
    % %�������ŵ�-��������δ�䶯�������ݼ�scikit-learn
    % optW = [-3.63398318e-02 -2.28542401e+01 5.60321490e+00 1.11677867e+00 -1.08844378e+00 7.45119512e-01 3.70046193e-01 6.52603830e+00 6.84415587e+01 2.80169578e-01];
    % optV = -334.40265547;

    % %�������ŵ�-���� ǰ 400 �е����ݼ�scikit-learn
    % optW = [  1.82670370e-02  -2.27257572e+01   5.62230387e+00   1.03262503e+00  -1.03483748e+00   6.96950350e-01   3.07409919e-01   6.84788185e+00   6.43976763e+01   3.67349853e-01]
    % optV = -321.1401196;

    %�������ŵ�-���� 7:3 �����ݼ�scikit-learn
    optW = [  -5.57184185 -266.03603283  547.301943    279.32038009 -399.11392663  123.71887507  -27.75562762  179.83460898  631.45337664  108.01870665]
    optV = 152.60353514;
    
    % optW = [6.01072426   0.94702945  -0.75799584  37.97792577   0.17932968];
    % optV  = -250.93500606;

    % optW = [5.9369  0.9087  -0.7093  43.4263  0];
    % optV  = -267.1347;

    %ʹ��������ݼ�������������10
    % optW = [ 1.16895373 -0.06000328  0.6545368   0.05133268  0.00315333  0.31657375 -0.70386262  0.02074532  1.70286224  0.05770234];
    % optV = [ 0.00071266];

%     %�Լ���ϵ�ϵ�����ϴ�����ݣ�����������10
%     optW = [  1.83105551e-02  -5.86891818e-02   2.20422572e+01  -1.00503911e+01   2.02997805e+00   7.97469664e+00  -9.02911639e+00   2.00358495e+01   4.96660931e-02   4.87844245e-03];
%     optV = [ 0.00048001];
    
%     %���²���ԭʼ���ݼ�
%     optW = [ -2.02296781e-02  -2.53589172e+01   5.89890705e+00   9.61642867e-01  -5.49184542e-01   1.93733439e-01  -1.02160292e-01   6.63612607e+00   5.75613309e+01   4.47431975e-01];
% 	optV = [-304.19911533];
    fenzi1 = sum( (b0 - data*optW'- optV).^2 );
    %����ʽ�����ѵ�������
    history.centralizeMSE(k) = (fenzi1/trainingNum);
    
    matrixPrim = zeros(1,features+1);     % �����[w,v]ֵ
    matrixPrim(1,1:features) = w;
    matrixPrim(1,features+1) = v;
    
    matrixDual = zeros(1,features+1);     % �����[W_i,V_i]ֵ
    matrixDual(1,1:features) = mean(W_i,1);
    matrixDual(1,features+1) = mean(V_i,1);
    
    matrixDualOld = zeros(1,features+1);     % �����[W_i,V_i] old ֵ
    matrixDualOld(1,1:features) = mean(W_iold,1);
    matrixDualOld(1,features+1) = mean(V_iold,1);
    
    matrixGama = zeros(1,features+1);     % �����[W_i,V_i]ֵ
    matrixGama(1,1:features) = mean(gama_w,1);
    matrixGama(1,features+1) = mean(gama_v,1);
    
    history.r_norm(k)  = norm(matrixPrim - matrixDual);     % ����ԭ����в�
    history.s_norm(k)  = norm(-rho*(matrixDual - matrixDualOld));     % ��ż������Բв�
    
    history.eps_pri(k) = sqrt(features+1)*ABSTOL + RELTOL*max(norm(matrixPrim), norm(-matrixDual));     % ԭʼ�в����̶�
    history.eps_dual(k)= sqrt(features+1)*ABSTOL + RELTOL*norm(rho*matrixGama);
    
%     fprintf(fobj,'%-5d %-5f %-5f %-5f %-5f %-5f %-5f\n',k,primObjective,dualObjective,history.r_norm(k),history.s_norm(k),history.eps_pri(k),history.eps_dual(k)); % д���ļ���k,ԭ����ֵ,��ż����ֵ��ԭ����в��ż�вԭ���̶ȣ���ż���̶ȣ�

    
    disp( [ '   iter     =  ', sprintf( '%d ', k ) ] );
    disp( [ '   w     = [ ', sprintf( '%7.4f ', w ), ']' ] );
    disp( [ '   v     = [ ', sprintf( '%7.4f ', v ), ']' ] );
    
    if ~QUIET
        fprintf('%3d\t%10.4f\t%10.4f\t%10.4f\t%10.4f\t%10.2f\n', k, ...
            history.r_norm(k), history.eps_pri(k), ...
            history.s_norm(k), history.eps_dual(k), history.dualObjective(k));
    end
    
%     if(history.r_norm(k) < history.eps_pri(k) && flag == 0)
%         history.OriginalResidualsIter = k;
%         flag = 1;
%     end
    if (history.r_norm(k) < history.eps_pri(k) && ...
       history.s_norm(k) < history.eps_dual(k))
         history.OriginalResidualsIter = k;
         flag = 1;
         break;
    end 
    
end;

history.optiobjval = 1/(2)*sum((data*optW' + optV - b0).^2) + lambda*norm(optW,1);
history.optW = optW;
history.optV = optV;
%% ���������Լ�
[testM, testN] = size(testExamples);
data1 = testExamples(:, 1:testN-1);
b1 = testExamples(:, testN);
 %����R��ֵ
fenziTest = sum( (b1 - data1*w'- v).^2 );
fenmuTest = sum( (b1 - mean(b1)).^2 );
history.testR2 = 1 - fenziTest/fenmuTest;

%����R��У������ϵ��
history.testR2_adjusted = 1 - ((1-history.R2(k))*(testM-1))/(testM - features - 1);

%ѵ�������
history.testMSE = (fenziTest/testM);

if ~QUIET
    toc(t_start);
end
end
function z = shrinkage(x, kappa)
    z = max( 0, x - kappa ) - max( 0, -x - kappa );
end