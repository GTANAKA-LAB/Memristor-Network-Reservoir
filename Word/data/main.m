% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
% DOI: 10.1038/s41598-022-13687-z

% NOTE: The following dataset and tools should be located in the same folder.
% 1. ti46_LDC93S9 (https://catalog.ldc.upenn.edu/LDC93S9)
% 2. sap-voicebox (https://github.com/ImperialCollegeLondon/sap-voicebox)
% 3. AuditoryToolbox (https://engineering.purdue.edu/~malcolm/interval/1998-010/)

function main()

getCochleagram();
masking();
