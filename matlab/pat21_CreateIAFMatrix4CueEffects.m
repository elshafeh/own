clear ; clc ; 

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    ext1        =   'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse';
    fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('\nLoading %50s \n',fname_in); load(fname_in);
    
    [freq, iaf(sb)] = iafdapt(suj,freq); clc;
    
    clearvars -except sb iaf ;
end

clear sb;

save ../data/yctot/index/iaf4cue.mat;