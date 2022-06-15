% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports, 12, 9868 (2022).
% DOI: 10.1038/s41598-022-13687-z

function main()

global s_max
global u_max
global d_max

s_max = 5;  % speaker
u_max = 10;  % utterance
d_max = 10;  % digit

get_reservoir_states();
readout();
