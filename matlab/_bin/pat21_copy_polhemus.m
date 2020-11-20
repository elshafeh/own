clear ; clc ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj     = ['yc' num2str(suj_list(sb))];
    
    fname_in   = ls(['/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/*/' suj '/*misc/*pos']);
    fname_out  = ['../data/polhemus/' suj '.polh.pos'];
    
    copyfile(fname_in,fname_out)
    
    clearvars -except sb
    
end