% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
% DOI: 10.1038/s41598-022-13687-z

function [Em,Ei,Nm,Ni] = generateNet(Nn,net_type)

%%%%% input
% Nn: Number of circuit nodes
% net_type: 1 (Ring-UP), 2 (Ring-RP), 3 (Rand-UP), 4 (Rand-RP)

%%%%% output
% Em: incidence matrix related to memristors
% Ei: incidence matrix related to voltage sources
% Nm: number of memristors
% Ni: number of voltage sources

%%%%% Incidence matrix Ei
  
% set adjacency matrix Ai
Ai = zeros(Nn,Nn);
Ai(1,2) = -1;
Ai(2,1) = 1;
Ai = sparse(Ai);
Ni = nnz(Ai)/2;
Ai_triu = triu(Ai,1); 
[Ai_row,Ai_col,Ai_value] = find(Ai_triu); % non-zero elements

% Ai -> Ei
Ei = zeros(Nn,Ni);
for k=1:Ni
    if Ai_value(k) == -1
        Ei(Ai_row(k),k) = -1;
        Ei(Ai_col(k),k) = 1;
    else
        Ei(Ai_row(k),k) = 1;
        Ei(Ai_col(k),k) = -1;
    end
end

%%%%% Incidence matrix Em

% set adjacency matrix Am
if net_type == 1  % Ring-UP
    Am = zeros(Nn,Nn);
    for i=1:Nn-1
        Am(i,i+1) = -1;
        Am(i+1,i) = 1;
    end
    Am(Nn,1) = -1;
    Am(1,Nn) = 1;
    Nm = Nn;
elseif net_type == 2  % Ring-RP
    Am = zeros(Nn,Nn);
    for i=1:Nn-1
        tmp = randi([0,1]);
        if tmp == 1
            Am(i,i+1) = 1;
            Am(i+1,i) = -1;
        elseif tmp == 0
            Am(i,i+1) = -1;
            Am(i+1,i) = 1;
        end
    end
    tmp = randi([0,1]);
    if tmp == 1
        Am(Nn,1) = 1;
        Am(1,Nn) = -1;
    elseif tmp == 0
        Am(Nn,1) = -1;
        Am(1,Nn) = 1;
    end
    Nm = Nn;
elseif net_type == 3  % Rand-UP
    Am_ring = zeros(Nn,Nn);
    for i=1:Nn-1
        Am_ring(i,i+1) = -1;
        Am_ring(i+1,i) = 1;
    end
    Am_ring(Nn,1) = -1;
    Am_ring(1,Nn) = 1;

    Am_long = zeros(Nn,Nn);
    N_long = Nn;  % <= Nn(Nn-1)/2-Nn
    count = 1;
    while count <= N_long
        tmp1 = randi(Nn);
        tmp2 = randi(Nn);
        % if not self-loop and overlap
        if (tmp1 ~= tmp2) && (abs(Am_ring(tmp1,tmp2)) ~= 1) && (abs(Am_long(tmp1,tmp2)) ~= 1)
            Am_long(tmp1,tmp2) = 1;
            Am_long(tmp2,tmp1) = -1;
            count = count + 1;
        end
    end
    
    Am = Am_ring + Am_long;
    Nm = Nn + N_long;
elseif net_type == 4  % Rand-RP
    Am_ring = zeros(Nn,Nn);
    for i=1:Nn-1
        tmp = randi([0,1]);
        if tmp == 1
            Am_ring(i,i+1) = 1;
            Am_ring(i+1,i) = -1;
        elseif tmp == 0
            Am_ring(i,i+1) = -1;
            Am_ring(i+1,i) = 1;
        end
    end

    tmp = randi([0,1]);
    if tmp == 1
        Am_ring(Nn,1) = 1;
        Am_ring(1,Nn) = -1;
    elseif tmp == 0
        Am_ring(Nn,1) = -1;
        Am_ring(1,Nn) = 1;
    end

    Am_long = zeros(Nn,Nn);
    N_long = Nn;  % <= Nn(Nn-1)/2-Nn
    count = 1;
    while count <= long_range
        tmp1 = randi(Nn);
        tmp2 = randi(Nn);
        % if not self-loop and overlap
        if (tmp1 ~= tmp2) && (abs(Am_ring(tmp1,tmp2)) ~= 1) && (abs(Am_long(tmp1,tmp2)) ~= 1)
            Am_long(tmp1,tmp2) = 1;
            Am_long(tmp2,tmp1) = -1;
            count = count + 1;
        end
    end
    Am = Am_ring + Am_long;
    Nm = Nn + N_long;
end

% Am -> Em
Am_triu = triu(Am,1);
[Am_row,Am_col,Am_value] = find(Am_triu);  % non-zero elements
Em = zeros(Nn,nnz(Am_triu));
for k=1:nnz(Am_triu)
    if Am_value(k) == -1
        Em(Am_row(k),k) = -1;
        Em(Am_col(k),k) = 1;
    else
        Em(Am_row(k),k) = 1;
        Em(Am_col(k),k) = -1;
    end
end

% Transform Em
[Ai_row,Ai_col,Ai_value] = find(Ai_triu);  % non-zero elements
for j=1:Ni
    for k=1:Nm
        if (abs(Am_row(k))==abs(Ai_row(j))) && (abs(Am_col(k))==abs(Ai_col(j)))
            Em = [Em(:,k) Em]; % move column k to the top
            Em(:,k+1) = []; % remove column k+1
        end
    end
end

%showNet(Nn,Am,Ai)