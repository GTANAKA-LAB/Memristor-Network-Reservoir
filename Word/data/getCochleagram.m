% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
% DOI: 10.1038/s41598-022-13687-z

% NOTE: The following dataset and tools are required
% 1. ti46_LDC93S9 (https://catalog.ldc.upenn.edu/LDC93S9)  
% 2. sap-voicebox (https://github.com/ImperialCollegeLondon/sap-voicebox)
% 3. AuditoryToolbox (https://engineering.purdue.edu/~malcolm/interval/1998-010/)

function getCochleagram()

%%%%% Make a new folder
folder_coch = ['./cochleagram/'];
if not(exist(folder_coch, 'dir'))
    mkdir(folder_coch);
    addpath(folder_coch);
end

s_list = [1 2 5 6 7];
for s = 1:5
    for d = 0:9
        for u = 0:9
            % read sph files
            infile = ['./ti46_LDC93S9/ti20/train/f',num2str(s_list(s)),'/0',num2str(d),'f',num2str(s_list(s)),'set',num2str(u),'.sph'];
            [signal,fs,WRD,PHN,FFX] = v_readsph(infile,'wt');  % sap-voicebox
            disp(['Reading data: s=',num2str(s),' d=',num2str(d),' u=',num2str(u)]);
            
            % silence
            [row,~] = size(signal);
            % former
            eps1 = 1.5e-2;
            i = 1;
            while signal(i) < eps1
                i = i + 1;
            end
            t_start = i;

            % latter
            eps2 = 1.0e-3;
            i = row;
            while signal(i) < eps2
                i = i - 1;
            end
            t_end = i;

            % cochleagram
            fs = 12500;  % 12.5kHz
            data = LyonPassiveEar(signal(t_start:t_end,1),fs,128);  % AuditoryToolbox
            %size(data)
            
            % file output
            outfile = [folder_coch,'/s',num2str(s_list(s)),'_u',num2str(u+1),'_d',num2str(d),'.mat'];
            save(outfile,'data');

            % show figures
            %{
            figure(1);
            image(data,'CDataMapping','scaled');
            pause(0.5);
            %}
        end
    end
end
