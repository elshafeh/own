clear ; clc; close all;

for ext_freq            = {'7t11Hz','11t15Hz'}
    for ext_time            = {'m600m200','p600p1000'}
        
        suj_list            = [1:4 8:17];
        
        for sb = 1:length(suj_list)
            
            suj             = ['yc' num2str(suj_list(sb))];
            
            for npart = 1:3
                load(['../data/network/' suj '.pt' num2str(npart) '.CnD.' ext_freq{:} '.' ext_time{:} '.1cm.1thresholdNetwork.mat']);
                
                if sb == 1 && npart == 1
                    template_parc       = network_parc;
                end
                
                sub_parc(npart,:)                                     = network_parc.degrees;
                
            end
            
            allsub_parc(sb,:)           = mean(sub_parc,1); clear sub_parc
            
        end
        
        clearvars -except allsub_parc template_parc ext_time ext_freq;
        
        template_parc.degrees           = mean(allsub_parc,1)';
        template_parc.degrees(find(template_parc.degrees < 1)) = NaN;
        
        cfg                             = [];
        cfg.method                      = 'surface';
        cfg.funparameter                = 'degrees';
        cfg.funcolormap                 = 'jet';
        cfg.funcolorlim                 = [0 5];
        ft_sourceplot(cfg, template_parc);
        
        clear template_parc sub_parc
        
    end
end