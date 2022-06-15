% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function masking()

global folder_divided

% Make a new folder
folder_mask = ['./ECG200_mask'];
if not(exist(folder_mask, 'dir'))
    mkdir(folder_mask);
    addpath(folder_mask);
end

% Parameter values
n_sample = 100;
channel = 1;
Smask = 50;

% Binary mask
M = rand(Smask,channel);
M(M >= 0.5) = 1;
M(M < 0.5) = -1;

% Masking
for p = 1:2  % (p=1 for training data, p=2 for testing data)
    name_phase = ['p',num2str(p)];
    for n = 1:n_sample
        if n < 10
            name_sample = ['n00', num2str(n)];
        elseif n < 100
            name_sample = ['n0', num2str(n)];
        else
            name_sample = ['n', num2str(n)];
        end

        % Masking
        f_in = [folder_divided,'/',name_phase,'_',name_sample,'.mat'];
        load(f_in);      
        data_mask = M * data;
        f_out = [folder_mask,'/',name_phase,'_',name_sample,'.mat'];
        save(f_out,'data_mask');

        % show image
        %{
        figure(1);
        image(data_mask,'CDataMapping','scaled');
        title(['(p, n)=(',num2str(p),', ',num2str(n),')']);
        colorbar;
        pause(0.5);
        %}
  end % n
end % p

