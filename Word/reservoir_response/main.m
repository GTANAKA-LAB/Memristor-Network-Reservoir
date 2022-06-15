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
Vmax = 0.5;
t_relax_step = 100;
t_main_step = 100;
t_max = 0.1;
Smask = 100;

%%%%% Set network structure
[Em,Ei,Nm,Ni] = generateNet(Nn,net_type);
disp('Network structure generated ...');

%%%%% Formulate circuit equations
[a,M0] = setDAE(Nm,r,sigma);
writeDAE(Nn,Nm,Ni,Em,Ei,a,M0);  % create "DAE_pre.m"
perl('convertDAE.pl');  % convert "DAE_pre.m" to "DAE.m"
disp('Circuit equation formulated ...');

%%%%% Read sample data
d = 0;  % digit (d: 0-9)
name_digit = ['d',num2str(d)];
disp(['Digit = ', num2str(d)]);

s_list = [1 2 5 6 7]; 
s = 1;  % speaker (s: 1,2,5,6,7)
name_speaker = ['s',num2str(s)];
disp(['Speaker = ',num2str(s_list(s))]);

u = 1;  % utterance (u: 1-10)
name_utterance = ['u',num2str(u)];
disp(['Utterance = ',num2str(u)]);

% Load
dir_data = ['../data/cochleagram_mask/'];
f_in = [dir_data,'s',num2str(s_list(s)),'_u',num2str(u),'_d',num2str(d),'.mat'];
load(f_in);
[~,col] = size(data_mask)  % data stored in struct 'Pmask'

%%%%% Reservoir dynamics
for k = 1:col
    samplein = transpose(data_mask(:,k));
    
    % Interpolation
    x = 0:t_max/(Smask-1):t_max;
    xq = 0:t_max/(t_main_step-1):t_max;
    samplein = interp1(x,samplein,xq,'linear');
    
    % Normalization
    samplein = samplein - min(samplein);
    samplein = [zeros(1,t_relax_step),Vmax*samplein/max(abs(samplein))];
    
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

