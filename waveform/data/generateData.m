% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function generateData()

global folder_dataset

% Make folder
folder_dataset = ['./dataset/'];
if not(exist(folder_dataset, 'dir'))
    mkdir(folder_dataset);
    addpath(folder_dataset);
end

% Parameter values
f0 = 5.0;  % Input signal frequency [Hz] (average)
delta = 0.4;  % Variability of phase

% Sampling from [0,1] s
dataLen = 100;  % Number of sampled values
tmax = 1.0;  % Time length [s]
st = linspace(0, tmax, dataLen);

% Data generation
n_class = 2;  % Number of classes
n_sample = 100;  % Number of samples

% Random number seed
rng(1,'twister');
s=rng;
rng(s);

for c = 1:n_class
    name_class = ['c', num2str(c)];
    for n = 1:n_sample
        if n < 10
            name_sample = ['n00', num2str(n)];
        elseif n < 100
            name_sample = ['n0', num2str(n)];
        else
            name_sample = ['n', num2str(n)];
        end
        f_data = [name_class,'_',name_sample,'.mat'];

        freq = f0 * (1.0 + delta*(2.0*rand-1.0));
        omega = 2.0*pi*freq;
        if c == 1
            data = [sin(omega*st(1:dataLen))];
        elseif c == 2
            st2 = st+(2*pi/omega)*0.25;
            data = [sawtooth(omega*st2(1:dataLen),0.5)];
        end

        % save data
        save([folder_dataset,'/',f_data],'data');
    end
end

showData(n_class, n_sample, dataLen);
