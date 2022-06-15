% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function get_reservoir_state()

global folder_rs
global n_class
global n_sample

%%%%% Parameter values
Nn = 10;  % Number of circuit nodes
net_type = 3;  % 1(Ring-UP), 2(Ring-RP), 3(Rand-UP), 4(Rand-RP)
sigma = 0.2;  % Variability
r = 1000;  % ON/OFF resistance ratio
Vmax = 0.5;  % Maximum voltagae
t_relax_step = 100;  % Time steps for relaxation
t_main_step = 100;  % Time steps for main part
t_max = 6.0;  % t_relax + t_main

%%%%% Make folder
folder_rs = ['./reservoir_states'];
if not(exist(folder_rs, 'dir'))
    mkdir(folder_rs);
    addpath(folder_rs);
end

%%%%% Set network structure
[Em,Ei,Nm,Ni] = generateNet(Nn,net_type);

%%%%% Formulate circuit equations
[a,M0] = setDAE(Nm,r,sigma);
writeDAE(Nn,Nm,Ni,Em,Ei,a,M0);  % create "DAE_pre.m"
perl('convertDAE.pl');  % convert "DAE_pre.m" to "DAE.m"

%%%%% Read sample data
for c = 1:n_class
    name_class = ['c',num2str(c)];
    
    for n = 1:n_sample
        if n < 10
            name_sample = ['n00',num2str(n)];
        elseif n < 100
            name_sample = ['n0',num2str(n)];
        else
            name_sample = ['n',num2str(n)];
        end
        
        disp(['generating reservoir states: class=',num2str(c),' sample=',num2str(n)]);
        
        % Load
        dir_data = ['../data/dataset/'];
        f_in = [dir_data, name_class,'_',name_sample,'.mat'];
        load(f_in);
        [row, ~] = size(data);  % data stored in struct 'data'

        %%%%% Numerical integration of circuit equations
        edgeI_all = [];
        for k = 1:row
            % Inputs
            samplein = [zeros(1,t_relax_step),Vmax*data(k,:)];
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
            %showResults(tq,Yq,Nn,Nm,Em,samplein,st,t_relax_step,t_main_step);
        
            % reservoir state
            edgeI = Yq(:,2*(Nn-1)+1:2*(Nn-1)+Nm);  % Edge current
            edgeI = edgeI(t_relax_step+1:t_relax_step+t_main_step,:);
            edgeI_all = [edgeI_all;edgeI'];

            clear t Y YP F edgeI
        end
        
        % file output
        fout_name = [name_class,'_',name_sample,'.mat'];
        f_edgeI = [folder_rs,'/',fout_name];
        save(f_edgeI,'edgeI_all');
    end
end