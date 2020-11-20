clear ; clc ; close ; dleiftrip_addpath ;

load ../data/yctot/RevComeOnExtWav;

tmpl_struct = allsuj{1,1};
tmpl_struct = rmfield(tmpl_struct,'cfg');
clear allsuj ;

load ../data/yctot/RevComeOnKeepTrialsExtWav.mat;

for sb = 1:size(allsuj,1)
    
    ts = -0.7:0.1:1.2;
    
    for cnd = 5 % 1:size(allsuj,2)
        
        data            = tmpl_struct ;
        data.powspctrm  = allsuj{sb,cnd};
        data.dimord     = 'rpt_chan_freq_time';
        
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        data                = ft_freqbaseline(cfg,data);
        
        for chn = 1:6
            
            for t = 1:length(ts)
                
                frq_list = [9 13];
                
                for f = 1:2
                    
                    tap = 2;
                    
                    cfg             = [];
                    cfg.latency     = [ts(t) ts(t)+0.1];
                    cfg.frequency   = [frq_list(f)-tap frq_list(f)+tap];
                    cfg.avgoverfreq = 'yes';
                    cfg.avgovertime = 'yes';
                    cfg.channel     = chn;
                    
                    dslct                           = ft_selectdata(cfg,data);
                    source_avg{sb,cnd,chn}(f,t,:)   = dslct.powspctrm ; clc ;
                    
                end
                
            end
            
        end
        
    end
    
end

clearvars -except source_avg

save('../data/yctot/NewArsenalVirtualKT2taper');