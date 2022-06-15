% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function readout()

global folder_rs
global s_max
global u_max
global d_max
global Nm

Nm = 20;
Nx = 20;

% Parameter values
n_class = 10;
Ny = n_class;  % Number of output units

% Numbers of training and testing data
u_train = 9;  % fraction of training data (9/10)  
disp(['Fraction of training data: ',num2str(u_train),'/',num2str(u_max)]);
n_train = u_train*s_max*d_max;
n_test = (u_max-u_train)*s_max*d_max;

u_list = [1:u_max, 1:u_max];
cycle = 1;
u_list_train = u_list(cycle:cycle+u_train-1);
u_list_test = setdiff([1:u_max], u_list_train);

% State collection matrix and teacher collection matrix
ACC_train = [];
ACC_test = [];
X_train = [];
D_train = [];
blockLen_train = [];
X_test = [];
D_test = [];
blockLen_test = [];
blockLen = zeros(1,s_max*u_max*d_max);

s_list = [1 2 5 6 7];
for s = 1:s_max
    name_speaker = ['s',num2str(s_list(s))];
    
    for u = 1:u_max
        name_utterance = ['u',num2str(u)];
        
        for d = 0:d_max-1
            name_digit = ['d',num2str(d)];

            index = (s-1)*u_max*d_max+(u-1)*d_max+d+1;
            
            % Read reservoir states
            f_in = [folder_rs,'/',name_speaker,'_',name_utterance,'_',name_digit,'.mat'];
            load(f_in);
            [~,col] = size(edgeI_all); % data stored in struct 'edgeI_all'
            
            X_block = [];
            for k = 1:col/Nm
                X = [];
                for j = 1:Nx
                    X = [X;edgeI_all(:,(k-1)*Nm+j)];
                end
                X_block = [X_block,X];
            end
            blockLen(1,index) = col/Nm;
    
            % Teacher data
            D_block = zeros(Ny,blockLen(1,index));
            D_block(d+1,:) = 1;

            if sum(ismember(u_list_train,u)) == 1
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
