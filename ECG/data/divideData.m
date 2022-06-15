% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function divideData()
global folder_divided

%%%%% Make a new folder
folder_divided = ['./ECG200_divided'];
if not(exist(folder_divided, 'dir'))
    mkdir(folder_divided);
    addpath(folder_divided);
end

%%%%% read data
data_train = load('./ECG200/ECG200_TRAIN.txt');
[row_train, col_train] = size(data_train);

data_test = load('./ECG200/ECG200_TEST.txt');
[row_test, col_test] = size(data_test);

%%%%% training data
p1_class = zeros(1,col_train);
for n=1:row_train
    if n < 10
        name_sample = ['n00',num2str(n)];
    elseif n < 100
        name_sample = ['n0',num2str(n)];
    else
        name_sample = ['n',num2str(n)];
    end

    % class label (1st column)
    if data_train(n,1) < 0
        p1_class(1,n) = 1;
    else
        p1_class(1,n) = 2;
    end

    % ECG data (from 2nd column to the last column)
    data = data_train(n,2:col_train);

    % store divided data
    f_data = [folder_divided,'/','p1_',name_sample,'.mat'];
    save(f_data, 'data');
end

% class label information
f_info = [folder_divided,'/','p1_class.mat'];
save(f_info, 'p1_class');

%%%%% testing data
p2_class = zeros(1,col_test);
for n=1:row_test
    if n < 10
        name_sample = ['n00',num2str(n)];
    elseif n < 100
        name_sample = ['n0',num2str(n)];
    else
        name_sample = ['n',num2str(n)];
    end

    % class label (1st column)
    if data_test(n,1) < 0
        p2_class(1,n) = 1;
    else
        p2_class(1,n) = 2;
    end

    % ECG data (from 2nd column to the last column)
    data = data_test(n,2:col_test);

    % store divided data
    f_data = [folder_divided,'/','p2_',name_sample,'.mat'];
    save(f_data, 'data');
end

% class label information
f_info = [folder_divided,'/','p2_class.mat'];
save(f_info, 'p2_class');
