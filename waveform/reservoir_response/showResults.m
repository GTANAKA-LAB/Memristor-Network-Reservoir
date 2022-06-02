% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
% DOI: 10.1038/s41598-022-13687-z

function showResults(t,Y,Nn,Nm,Em,samplein,st,t_relax,t_main)

%%%%% Input
% t: Time
% Y: Solution of DAE
% Em: Incidence matrix of memristors
% samplein: Input signal
% st: Sampling time

figure(3); clf;

t_start = t_relax;
t_end = t_relax + t_main;

%%%%% Input voltage
subplot(3,2,1);
input = plot(st(t_start:t_end),samplein(t_start:t_end),'-');
set(gca,'FontName','Arial');
set(gca,'FontSize',12);
xlim([3 6])
ylim([-0.6 0.6])
xlabel('Time (sec)');
ylabel('Voltage (V)');
title('Input voltage');
input.LineWidth=1;
  
%%%%% Node voltage
subplot(3,2,2);
for k=1:Nn-1
% for k=Nn:2*(Nn-1) % Ž¥‘©ƒvƒƒbƒg‚Ì‚Æ‚«
    node=plot(t(t_start:t_end),Y(t_start:t_end,k),'-');
    node.LineWidth=1;
    hold on;
end
xlim([3 6]);
ylim([-0.6 0.6]);
set(gca,'FontName','Arial');
set(gca,'FontSize',12);
xlabel('Time (sec)');
ylabel('Voltage (V)');
title('Node voltages');

%%%%% Memristor branch currents
subplot(3,2,3);
for k=2*(Nn-1)+1:2*(Nn-1)+Nm
    if Y(t_relax+t_main/2,k) > 0  % if positive
        branch = plot(t(t_start:t_end),Y(t_start:t_end,k),'-');
        branch.LineWidth=1;
        hold on;
    else  % if negative
        branch = plot(t(t_start:t_end),-Y(t_start:t_end,k),'-');
        branch.LineWidth=1;
        hold on;
    end
end
xlim([3 6]);
set(gca,'FontName','Arial');
set(gca,'FontSize',12);
xlabel('Time (sec)');
ylabel('Current (A)');
title('Currents');

%%%%% I-V curve
subplot(3,2,4);
V = Y(t_start:t_end,1:Nn-1);  % Node voltage
V0 = zeros(t_end-t_start+1,1); % Grounded node
V = [V0 V];
DV = (Em'*V')';  % Potential difference
for k=2*(Nn-1)+1:2*(Nn-1)+Nm
    IV = plot(DV(:,k-2*(Nn-1)),Y(t_start:t_end,k),'-');
    IV.LineWidth=1;
    hold on;
end
xlim([-0.6 0.6])
set(gca,'FontName','Arial');
set(gca,'FontSize',12);
xlabel('Voltage (V)');
ylabel('Current (A)');
title('I-V curve');

%%%%% I-V curve (semilog plot)
subplot(3,2,5);
V = Y(t_start:t_end,1:Nn-1);  % Node voltage
V0 = zeros(t_end-(t_start)+1,1);  % Grounded node
V = [V0 V];
DV = (Em'*V')';  % Potential difference
for k=2*(Nn-1)+1:2*(Nn-1)+Nm
    IVlog = semilogy(DV(:,k-2*(Nn-1)),abs(Y(t_start:t_end,k)),'-');
    IVlog.LineWidth = 1;
    %ylim([1.0e-10 1.0e-5]);
    hold on;
end
xlim([-0.6 0.6])
set(gca,'FontName', 'Arial');
set(gca,'FontSize',12);
xlabel('Voltage (V)');
ylabel('Current (A)');
title('I-V curve (semi-log plot)');

%%%%% Input dependency
subplot(3,2,6);
V = Y(t_start:t_end,1:Nn-1);
V0 = zeros(t_end-t_start+1,1);
V = [V0 V];
for k=2*(Nn-1)+1:2*(Nn-1)+Nm
    ind = plot(V(:,2),Y(t_start:t_end,k),'-');
    ind.LineWidth=1;
    hold on;
end
xlim([-0.6 0.6]);
set(gca,'FontName', 'Arial');
set(gca,'FontSize',12);
xlabel('Voltage (V)');
ylabel('Current (A)');
title('Input vs Currents')

% Save figure
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 5]);
% print(gcf,'-dpng','-r300','fig_response.png');
% print(gcf,'-depsc','-r300','fig_response.eps');
