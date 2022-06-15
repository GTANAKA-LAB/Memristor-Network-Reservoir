% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function main()

global n_class
global n_sample
global n_train
global n_test

n_class = 2;
n_sample = 100;  % each class
n_train = 50;  % each class
n_test = n_sample - n_train;  % each class

get_reservoir_states();
readout();
