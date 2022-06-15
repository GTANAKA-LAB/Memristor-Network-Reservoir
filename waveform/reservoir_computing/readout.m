% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function readout()
global folder_rs
global n_class
global n_sample
global n_train
global n_test

Ny = n_class;  % Number of output units

ACC_train = [];
ACC_test = [];

% 10-fold cross validation (cyclic)
n_list = [1:n_sample, 1:n_sample];
for cycle = 1:10
    n_list_train = n_list(cycle:cycle+n_train-1);
    %n_list_test = setdiff([1:n_sample],n_list_train);

    %%%%% State collection matrix and teacher collection matrix
    X_train = [];
    D_train = [];
    blockLen_train = [];
    X_test = [];
    D_test = [];
    blockLen_test = [];
    blockLen = zeros(1,n_class*n_sample);

    for c = 1:n_class
        name_class = ['c',num2str(c)];
        for n = 1:n_sample
            if n < 10
                name_sample = ['n00', num2str(n)];
            elseif n < 100
               name_sample = ['n0', num2str(n)];
            else
                name_sample = ['n', num2str(n)];
            end

            index = (c-1)*n_sample+n;

            % Read reservoir state from files
            f_in = [folder_rs,'/',name_class,'_',name_sample,'.mat'];
            load(f_in);
            [~, col] = size(edgeI_all);  % stored in struct 'edgeI_all'

            X_block = abs(edgeI_all);
            blockLen(1, index) = col;
    
            % Teacher data
            D_block = zeros(Ny,blockLen(1,index));
            D_block(c,:) = 1;

            if sum(ismember(n_list_train,n)) == 1
                X_train = [X_train,X_block];
                D_train = [D_train,D_block];
                blockLen_train = [blockLen_train,blockLen(1,index)];
            else
                X_test = [X_test, X_block];
                D_test = [D_test, D_block];
                blockLen_test = [blockLen_test,blockLen(1,index)];
            end
        end
    end

    %%%%% Training
    [match_train,Wout] = train(X_train,D_train,blockLen_train);
    [~,block_col_train] = size(blockLen_train);
    ACC_train = [ACC_train,match_train/block_col_train];
    
    %%%%% Testing
    [match_test] = test(X_test,D_test,blockLen_test,Wout);
    [~,block_col_test] = size(blockLen_test);
    ACC_test = [ACC_test,match_test/block_col_test];

end % cycle

disp(['Training: Mean accuracy = ',num2str(mean(ACC_train))]);
disp(['Testing: Mean accuracy = ',num2str(mean(ACC_test))]);
