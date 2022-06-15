% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function get_reservoir_state()

global folder_rs
global s_max
global u_max
global d_max
global Nm

%%%%% Parameter values
Nn = 10;  % Number of circuit nodes
net_type = 3;  % 1(Ring-UP), 2(Ring-RP), 3(Rand-UP), 4(Rand-RP)
sigma = 0.2;  % Variability
r = 50;  % ON/OFF resistance ratio
Vmax = 0.5;  % Maximum voltagae
Smask = 100;
t_relax_step = Smask;  % Time steps for relaxation
t_main_step = Smask;  % Time steps for main part
t_max = 0.1;  % t_relax + t_main

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
s_list = [1 2 5 6 7];
for s = 1:s_max
    name_speaker = ['s',num2str(s_list(s))];
    
    for u = 1:u_max
        name_utterance = ['u',num2str(u)];
        
        for d = 0:d_max-1
            name_digit = ['d',num2str(d)];

            index = (s-1)*u_max*d_max+(u-1)*d_max+d;
        
            disp(['Generating reservoir states: s=',num2str(s),' u=',num2str(u),' d=',num2str(d),' (',num2str(index+1),'/',num2str(s_max*u_max*d_max),')']);
        
            % Load
            dir_data = ['../data/cochleagram_mask/'];
            f_in = [dir_data,name_speaker,'_',name_utterance,'_',name_digit,'.mat'];
            load(f_in);
            [~,col] = size(data_mask);  % data stored in struct 'data_mask'

            %%%%% Reservoir dynamics
            edgeI_all = [];
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
        
                % reservoir state
                edgeI = Yq(:,2*(Nn-1)+1:2*(Nn-1)+Nm);  % Edge current
                edgeI = edgeI(t_relax_step+1:t_relax_step+t_main_step,:);
                edgeI_all = [edgeI_all,edgeI];

                clear t Y YP F edgeI
            end
        
            % file output
            fout_name = [name_speaker,'_',name_utterance,'_',name_digit,'.mat'];
            f_edgeI = [folder_rs,'/',fout_name];
            save(f_edgeI,'edgeI_all');
        end
    end
end