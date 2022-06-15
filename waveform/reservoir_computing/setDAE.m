% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function [a,M0] = setDAE(Nm,r,sigma)

%%%%% Input
% Nm: Number of memristors
% r: ON/OFF resistance ratio
% sigma: Variability

%%%%% Output
% a: Constant parameter
% M0: Initial memristance

% set seed of random number
rng(0,'twister');
s=rng;
rng(s);

% Linear drift model (Strukov et al., 2008)
D = 1.0e-8;  % [m], Device length 10nm
mu_v = 1.0e-14;  % [m^2/(sV)], Average ion mobility 
Ron_base = 1.0e+2;  % [Ohm], Low resistance state
Roff_base = Ron_base * r; % [Ohm], High resistance state

% Variability
var_Ron = sigma;
var_Roff = sigma*2.0;
var_w0 = sigma;

%%%%% set 'a' in Eq.(10) and M0 := M(w(0)) in Eq.(9)
a = zeros(Nm,1);
M0 = zeros(Nm,1);

if sigma < 1e-10  % if sigma = 0
    Ron = Ron_base * ones(Nm,1);
    Roff = Roff_base * ones(Nm,1);
    w0 = 0.1*D*ones(Nm,1);
    for i=1:Nm
        a(i,1) = mu_v*Ron(i,1)*(Roff(i,1)-Ron(i,1))/(D*D);
        M0(i,1) = Ron(i,1)*w0(i,1)/D+Roff(i,1)*(1.0-w0(i,1)/D);
    end
else  % normal distribution
    pd_Ron = makedist('Normal','mu',Ron_base,'sigma',var_Ron*Ron_base);
    trun_Ron = truncate(pd_Ron,0,inf);  % positive 
    Ron= random(trun_Ron,Nm,1); % LRS [Ohm]
    
    pd_Roff = makedist('Normal','mu',Roff_base,'sigma',var_Roff*Roff_base);
    trun_Roff = truncate(pd_Roff,0,inf);  % positive
    Roff = random(trun_Roff,Nm,1); % HRS [Ohm]
    
    pd_w0 = makedist('Normal','mu',0.1*D,'sigma',0.1*D*var_w0);
    trun_w0 = truncate(pd_w0,0,inf);  % positive
    w0 = random(trun_w0,Nm,1); % [m]

    for i=1:Nm
        a(i,1) = mu_v*Ron(i,1)*(Roff(i,1)-Ron(i,1))/(D*D);
        M0(i,1) = Ron(i,1)*w0(i,1)/D+Roff(i,1)*(1.0-w0(i,1)/D);
    end
end

%showHist(Ron, Roff, w0);

