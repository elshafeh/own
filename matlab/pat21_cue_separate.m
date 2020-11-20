clear ; clc ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    fname_in = ['../data/' suj '/elan/' suj '.CnD.eeg.mat'];
    
    load(fname_in);
    
    sub_cnd = {'NCnD','LCnD','RCnD','VCnD'};
    
    load ../data/yctot/rt/rt_cond_classified
    
    big_data = data_elan ; clear data_elan
    
    for cc = 1:length(sub_cnd)
        
        if cc < 4
            sub_evnts = rt_indx{sb,cc};
        else
            sub_evnts = [rt_indx{sb,2} ;rt_indx{sb,3}];
        end
        
        cfg             = [];
        cfg.trials      = sub_evnts;
        data_elan       = ft_selectdata(cfg,big_data);
        data_elan.cfg   = [];
        
        fname_out = [suj '.' sub_cnd{cc} '.eeg'];
        
        fprintf('\n\nSaving %50s \n\n',fname_out);
        
        save(['../data/' suj '/elan/' fname_out '.mat'],'data_elan','-v7.3')
        
        clear data_elan sub_evnts
        
    end
    
    clear big_virt
    
end