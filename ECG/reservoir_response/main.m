% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function main()

global Vmax
global t_max

%%%%% Parameter values
Nn = 10;
net_type = 3;  % 1(Ring-UP), 2(Ring-RP), 3(Rand-UP), 4(Rand-RP)
sigma = 0.2;
r = 50;
Vmax = 0.05;
t_relax_step = 50;
t_main_step = 50;
t_max = 6.0;
n_phase = 2;
n_sample = 100;
Smask = 50;

%%%%% Set network structure
[Em,Ei,Nm,Ni] = generateNet(Nn,net_type);
disp('Network structure generated ...');

%%%%% Formulate circuit equations
[a,M0] = setDAE(Nm,r,sigma);
writeDAE(Nn,Nm,Ni,Em,Ei,a,M0);  % create "DAE_pre.m"
perl('convertDAE.pl');  % convert "DAE_pre.m" to "DAE.m"
disp('Circuit equation formulated ...');

%%%%% Find maximum absolute value in the dataset
max_train = 0.0;
for p=1:n_phase
    name_phase = ['p',num2str(p)];
    for n=1:n_sample
        if n < 10
            name_sample = ['n00',num2str(n)];
        elseif n < 100
            name_sample = ['n0',num2str(n)];
        else
            name_sample = ['n',num2str(n)];
        end
        
        dir_data = ['../data/ECG200_mask/'];
        f_in = [dir_data, name_phase,'_',name_sample,'.mat'];
        load(f_in);
        tmp = max(max(abs(data_mask)));  % data stored in struct 'data_mask'
        if max_train < tmp
            max_train = tmp;
        end
    end
end

%%%%% Read sample data
p = 1;  % choose class (p=1 for training phase; p=2 for testing phase)
name_phase = ['p',num2str(p)];
disp(['Phase index = ', num2str(p)]);

n = 1;  % choose sample index (1<=n<=100)
if n < 10
    name_sample = ['n00',num2str(n)];
elseif n < 100
    name_sample = ['n0',num2str(n)];
else
    name_sample = ['n',num2str(n)];
end
disp(['Sample index = ', num2str(n)]);

% Load
dir_data = ['../data/ECG200_mask/'];
f_in = [dir_data, name_phase,'_',name_sample,'.mat'];
load(f_in);
[~,col] = size(data_mask);  % data stored in struct 'data_mask'

%%%%% Numerical integration of circuit equations
for k = 1:col
    samplein = transpose(data_mask(:,k));
    % interpolation
    x = 0:t_max/(Smask-1):t_max;
    xq = 0:t_max/(t_main_step-1):t_max;
    samplein = interp1(x,samplein,xq,'linear');
    samplein = [zeros(1,t_relax_step),Vmax*samplein/max_train];
    
    dt = t_max/(t_relax_step + t_main_step);
    st = linspace(0,t_max,t_relax_step + t_main_step);

    % Function hundle
    F = @(t,Y,YP) DAE(t,Y,YP,st,samplein);
    y0est = zeros(2*(Nn-1)+Nm+Ni,1);
    yp0est = zeros(2*(Nn-1)+Nm+Ni,1);
    opt = odeset('RelTol',1.0e-2,'AbsTol',1.0e-2,'MaxStep',dt,'InitialStep',dt);
    [y0,yp0] = decic(F,0,y0est,[],yp0est,[],opt);
    
    % Integration and sampling
    [t,Y] = ode15i(F,[0, t_max],y0,yp0,opt);       
    [~,colY] = size(Y);
    Yq = zeros(t_relax_step+t_main_step,colY);
    tq = 0:t_max/(t_relax_step+t_main_step-1):t_max;
    for i=1:colY
        Yq(:,i) = interp1(t,Y(:,i),tq,'linear');
    end 
    
    showResults(tq,Yq,Nn,Nm,Em,samplein,st,t_relax_step,t_main_step);
    disp(['Showing responses to column ', num2str(k)]);
    clear t Y YP F
end

