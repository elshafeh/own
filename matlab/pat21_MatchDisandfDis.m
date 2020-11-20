clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        
        posIN                   =   load(['/Volumes/PAT_MEG2/Fieldtripping/data/pos/' suj '.pat2.fin.fDisMirror.pos']);
        posIN                   =   posIN(posIN(:,3) == 0,1:2);
        posIN(:,3)              =   posIN(:,2) - ((floor(posIN(:,2)/1000))*1000);
        posIN(:,4)              =   floor(posIN(:,3)/100);
        posIN(:,5)              =   floor((posIN(:,3)-100*posIN(:,4))/10);
        
        chkSampleInfo{d}        = [];
        chkTrialInfo{d}         = [];
        
        for prt = 1:3
            fname_in    = ['../data/elan/' suj '.pt' num2str(prt) '.' lst{d} '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            chkSampleInfo{d} = [chkSampleInfo{d} ; data_elan.sampleinfo];
            chkTrialInfo{d}  = [chkTrialInfo{d};data_elan.trialinfo];clear data_elan;
        end
        
        ix      = [];
        
        for n = 1:length(chkSampleInfo{d})
            ix      = find(posIN(:,1) == chkSampleInfo{d}(n) + 600*4);
            cue2dis = posIN(ix,1) - posIN(ix-1,1);
            tar2dis = posIN(ix+1,1) - posIN(ix,1);
            chkTrialInfo{d}(n,2)    = cue2dis;
            chkTrialInfo{d}(n,3)    = tar2dis;

        end
    end
    
    match = [];
    
    for n = 1:length(chkTrialInfo{1})
        
        ix1 = find(chkTrialInfo{2}(:,1)-6000 == chkTrialInfo{1}(n,1)-2000);
        ix2 = find(chkTrialInfo{2}(:,2) == chkTrialInfo{1}(n,2));
        ix3 = find(chkTrialInfo{2}(:,3) == chkTrialInfo{1}(n,3));
        
    end
end