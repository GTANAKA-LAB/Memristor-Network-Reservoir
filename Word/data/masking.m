% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
% DOI: 10.1038/s41598-022-13687-z

function masking()

%%%%% Parameter values
Nf = 78;  % Number of channels
Smask = 100;  % Mask size

%%%%% Make a new folder
folder_mask = ['./cochleagram_mask/'];
if not(exist(folder_mask, 'dir'))
    mkdir(folder_mask);
    addpath(folder_mask);
end

%%%%% Mask
Q = rand(Smask,Nf);
Q = (Q >= 0.5); % binary random matrix

datalen_sum = [];
s_list = [1 2 5 6 7];
for s = 1:5
    for d = 0:9
        for u = 1:10
            filename = ['./cochleagram/s',num2str(s_list(s)),'_u',num2str(u),'_d',num2str(d),'.mat'];
            load(filename);
            [~,col] = size(data);  % data stored in struct 'data'
            datalen_sum = [datalen_sum, col];
  
            data_mask = Q*data;  % masking
  
            outfile = [folder_mask,'s',num2str(s_list(s)),'_u',num2str(u),'_d',num2str(d),'.mat'];
            save(outfile,'data_mask');

            disp(['Masking cochleagram: s=',num2str(s),' d=',num2str(d),' u=',num2str(u)]);
            
            % show figures
            %{
            figure(2);
            image(data_mask,'CDataMapping','scaled');
            title(['(s,d,u)=',num2str(s_list(s)),' ',num2str(d),' ',num2str(u)]);
            colorbar;
            pause(0.5);
            %}
        end
    end
end
