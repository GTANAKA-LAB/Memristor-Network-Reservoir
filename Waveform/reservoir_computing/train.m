% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function [match_train,Wout] = train(X_train,D_train,blockLen_train)
   
%%%%% Input
% X_train: State collection matrix (dim x length)
% D_train: Teacher collection matrix (dim x length)
% blockLen_train: Block lengthi1~(n_class*n_train)j

%%%%% Output
% match_train: Number of correct outputs
% Wout: Trained weight matrix

%%%%% Learning
[D_row,~] = size(D_train);
[~, block_col] = size(blockLen_train);
Wout = D_train * pinv(X_train);
Y_train = Wout * X_train;

%%%%%% Accuracy
class_true = zeros(1,block_col);
class_pred = zeros(1,block_col);
id_start = 0;
match_train = 0;
for i = 1:block_col
    Y_block = Y_train(:,id_start+1:id_start+blockLen_train(1,i));
    D_block = D_train(:,id_start+1:id_start+blockLen_train(1,i));

    % True class
    winner = []; 
    for j=1:blockLen_train(1,i)
        [~,label] = max(D_block(:,j));
        winner = [winner,label];
    end
    class_true(1,i) = mode(winner);

    % Predicted class
    if D_row == 1  % Single output 
        Y_block(Y_block>=0.5) = 1;
        Y_block(Y_block<0.5) = 0;
        class_value = mode(Y_block);
    else  % Multiple outputs
        winner = [];
        for j=1:blockLen_train(1,i)
            [~,label] = max(Y_block(:,j));
            winner = [winner,label];
        end
        class_value = mode(winner);
    end
    class_pred(1,i) = class_value;

    % Count
    if class_true(1,i) == class_pred(1,i)
        match_train = match_train + 1;
    end
    id_start = id_start + blockLen_train(1,i);    
end
