clear;

[NUM,TXT,RAW]   = xlsread('../../documents/ageing_tardiff.xlsx');
diff_list       = RAW(1:28,1:2); clearvars -except diff_list;

suj_group{1}    = diff_list{1:14,:};
suj_group{2}    = diff_list{15:28,:};

