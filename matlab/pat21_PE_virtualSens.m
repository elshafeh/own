clear ; clc ; close all ;

suj_list = [1:4 8:17];

for ext = {'AudViz.VirtTimeCourse'}
    
    cond_list = {'nDT'} ;
    
    for cnd = 1:length(cond_list)
        
        for sb = 1:length(suj_list)
            
            suj = ['yc' num2str(suj_list(sb))];
            
            fname_in = dir(['../data/pe/' suj '.' cond_list{cnd} '.' ext{:} '.mat']);
            fprintf('\nLoading %50s \n',fname_in.name);
            load(['../data/pe/' fname_in.name])
            
            cfg             = [];
            cfg.bpfilter    = 'yes';
            cfg.bpfreq      = [0.5 20];
            virtsens        = ft_preprocessing(cfg,virtsens);
            
            nw_chn      = [3 5;4 6];
            nw_lst      = {'audL','audR'};
            
            for l = 1:2
                cfg             = [];
                cfg.channel     = nw_chn(l,:);
                cfg.avgoverchan = 'yes';
                nwPe{l}        = ft_selectdata(cfg,virtsens);
                nwPe{l}.label  = nw_lst(l);
            end
            
            virtsens = ft_appenddata([],nwPe{:});
            
            list_cue = {'N','L','R'};
            
            for cnd_cue = 1:3
                
                cfg                     = [];
                cfg.trials              = h_chooseTrial(virtsens,cnd_cue-1,0,1:4);
                allsuj{sb,cnd_cue}      = ft_timelockanalysis(cfg,virtsens);
                allsuj{sb,cnd_cue}      = rmfield(allsuj{sb,cnd_cue},'cfg');
                
                clear itrl
                
            end
        end
        
    end
    
    save(['../data/yctot/gavg/virtual/' cond_list{cnd} '.' ext{:} '.pe.mat'], ...
        'allsuj','-v7.3');
    
end