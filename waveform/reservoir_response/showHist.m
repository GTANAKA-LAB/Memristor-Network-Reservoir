% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function showHist(Ron, Roff, w0)

%%%%% Input
% Ron: Resistance of LRS
% Roff: Resistance of HRS
% w0: Initial condition of internal variable

figure(2); clf;

subplot(1,3,1);
histogram(Ron);
xlabel('Ron [Ohm]');
ylabel('Count');
title('Histogram');

subplot(1,3,2);
histogram(Roff);
xlabel('Roff [Ohm]')
ylabel('Count');
title('Histogram');

subplot(1,3,3);
histogram(w0);
xlabel('w0');
ylabel('Count');
title('Histogram');