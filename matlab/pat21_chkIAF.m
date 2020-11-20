clear ; clc ; 

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    i = 0 ;
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        [freq, tmp] = iafdapt(freq); clc;
        
        for mini = 1:2
            i = i +1;
            iaf(sb,i) = tmp(mini);
        end
        
    end
    
    clearvars -except sb iaf ;
end

clear sb ;

boxplot(iaf,'Labels',{'R.audL','R.audR','L.audL','L.audR','N.audL','N.audR'})
ylim([5 20]);