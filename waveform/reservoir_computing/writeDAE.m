% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
% DOI: 10.1038/s41598-022-13687-z

function writeDAE(Nn,Nm,Ni,Em,Ei,a,M0)

%%%%% Input
% Nn: Number of circuit nodes
% Nm: Number of memristors
% Ni: Number of voltage sources
% Em: Incident matrix related to memristors
% Ei: Incident matrix related to voltage sources
% a: Constant parameter
% M0: Initial memristance

%%%%% èoóÕ
% 'DAE_pre.m': DAE hundle

%%%%% Define variables
syms t phi signal real

% Node voltage and flux
vn = sym(zeros(Nn,1));
phin = sym(zeros(Nn,1));
for i=1:Nn
    vn(i,1) = feval(symengine, sprintf('vn%d',i),'t');
    phin(i,1) = feval(symengine, sprintf('phin%d',i),'t');
end

% Currents at voltage source
ji = sym(zeros(Ni,1));
for i=1:Ni
    ji(i,1) = feval(symengine, sprintf('ji%d',i),'t');
end

% Currents at memristors
jm = sym(zeros(Nm,1));
for i=1:Nm
    jm(i,1) = feval(symengine,sprintf('jm%d',i),'t');
end

% Charges (linear drift model)
q = sym(zeros(Nm,1));
for i=1:Nm
    q(i,1) = symfun((M0(i)-sqrt(M0(i)*M0(i)-2.0*a(i)*phi))/a(i), [phi]);
end

% Fluxes at edges
phim = Em'*phin;

% dq(phim)/dphim
dqdphi = sym(zeros(Nm,1));
for i=1:Nm
    dqdphi(i) = subs(diff(q(i,1),phi),phim(i));
end
dqdphim = diag(dqdphi);

%%%%% Circuit equation
eqs_original = [ Em*dqdphim*Em'*diff(phin,1) + Ei*ji;
                 diff(phin,1)-vn;
                 dqdphim*Em'*diff(phin,1)-jm;
                 Ei'*vn-signal];
vars_original = [vn; phin; jm; ji];  %  dimension: [Nn, Nn, Nm, Ni]
eqs_original_mat = formula(eqs_original);
vars_original_mat = formula(vars_original);

% Remove node 1 because it is grounded
% dimension: [Nn-1, Nn-1, Nm, Ni]
for i=1:Nn-1
    eqs(i) = eqs_original_mat(i+1);
    vars(i) = vars_original_mat(i+1);
end
for i=Nn:2*(Nn-1)+Nm+Ni
    eqs(i) = eqs_original_mat(i+2);
    vars(i) = vars_original_mat(i+2);
end 
% vn1(t)=phin1(t)=0
eqs = subs(eqs,phin(1),0);
eqs = subs(eqs,vn(1),0);

%%%% DAE hundle
isLowIndexDAE(eqs,vars);
[DAEs, DAEvars] = reduceDAEIndex(eqs,vars);
daeFunction(DAEs,DAEvars,signal,'File','DAE_pre');
