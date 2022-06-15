% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function showData(n_class, n_sample, dataLen)

global folder_dataset

figure(1); clf;
 
for c = 1:n_class
    name_class = ['c', num2str(c)];
    data_all = [];
    for n = 1:n_sample
        if n < 10
            name_sample = ['n00',num2str(n)];
        elseif n < 100
            name_sample = ['n0',num2str(n)];
        else
            name_sample = ['n',num2str(n)];
        end
        f_data = [folder_dataset,'/',name_class,'_',name_sample,'.mat'];
        load(f_data);
        data_all = [data_all; data];
    end

    subplot(n_class,1,c);
    for n = 1:n_sample
        plot(1:dataLen, data_all(n,1:dataLen));
        xlabel('Time step');
        if c == 1
            title('Sinusoidal');
        else
            title('Triangular');
        end
        hold on;
    end
end
