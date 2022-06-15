% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function readout()

global folder_rs
global n_phase
global n_class
global n_sample
global Smask

%%%%% Parameter values
n_class = 2;
postprocess_case = 1;  %  1 or 2 (see paper)
Ny = n_class;  % Number of output units

if postprocess_case == 1
    scm_col = Smask;  % column size of state collection matrix
    Nx = 1;
else
    scm_col = 1;  % column size of state collection matrix
    Nx = 50;
end

ACC_train = [];
ACC_test = [];

%%%%% State collection matrix and teacher collection matrix
ACC_train = [];
ACC_test = [];
X_train = [];
D_train = [];
blockLen_train = [];
X_test = [];
D_test = [];
blockLen_test = [];
blockLen = zeros(1,n_phase*n_sample);

for p = 1:n_phase
    name_phase = ['p',num2str(p)];
        
    load(['../data/ECG200_divided/',name_phase,'_class.mat']);
    if p == 1
        class = p1_class;
    else
        class = p2_class;
    end
        
    for n = 1:n_sample
        if n < 10
            name_sample = ['n00', num2str(n)];
        elseif n < 100
            name_sample = ['n0', num2str(n)];
        else
            name_sample = ['n', num2str(n)];
        end

        index = (p-1)*n_sample+n;

        % Read reservoir state from files
        f_in = [folder_rs,'/',name_phase,'_',name_sample,'.mat'];
        load(f_in);
        edgeI_all = transpose(edgeI_all);  % data stored in struct 'edgeI_all'
        [~,col] = size(edgeI_all);
            
        X_block = [];
        for k = 1:scm_col
            X = [];
            for j = 1:Nx
                X = [X;edgeI_all(:,(k-1)*(col/scm_col)+j)];
            end
            X_block = [X_block,X];
        end
        blockLen(1,index) = scm_col;
    
        % Teacher data
        D_block = zeros(Ny,blockLen(1,index));
        D_block(class(1,n),:) = 1;

        if p == 1
            X_train = [X_train,X_block];
            D_train = [D_train,D_block];
            blockLen_train = [blockLen_train,blockLen(1,index)];
        else
            X_test = [X_test,X_block];
            D_test = [D_test,D_block];
            blockLen_test = [blockLen_test,blockLen(1,index)];
        end
    end
end

%%%%% Training
[match_train,Wout] = train(X_train,D_train,blockLen_train);
[~,block_col_train] = size(blockLen_train);
ACC_train = [ACC_train,match_train/block_col_train];
disp(['Training: Accuracy = ',num2str(ACC_train)]);

%%%%% Testing
[match_test] = test(X_test,D_test,blockLen_test,Wout);
[~,block_col_test] = size(blockLen_test);
ACC_test = [ACC_test,match_test/block_col_test];
disp(['Testing: Accuracy = ',num2str(ACC_test)]);
