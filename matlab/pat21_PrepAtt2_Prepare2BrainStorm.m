clear; clc ; dleiftrip_addpath ;

cnd_list = {'CnD'};

for cnd = 1%:length(cnd_list)
    for sb = 1:14
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))];
        ext_essai   = 'SomaGammaNoAVG.CoV.m800p2000ms.freq.1t120Hz';
        
        fname_in = [suj '.' cnd_list{cnd} '.' ext_essai];
        fprintf('\nLoading %50s \n',fname_in);
        load(['../data/pe/' fname_in '.mat'])
        
        ft_progress('init','text',    'Please wait...');
        
        for xi = 1:length(virtsens.trialinfo)
            
            ft_progress(xi/length(virtsens.trialinfo), 'Processing trial %d from %d\n', xi, length(virtsens.trialinfo));
            
            nw_pow{xi}  = [];
            nw_lab      = {};
            
            i = 0 ;
            
            for yi = 1:2:length(virtsens.label)
                
                i = i +1;
                
                nw_pow{xi}      = [nw_pow{xi}; mean(virtsens.trial{xi}(yi:yi+1,:,:),1)];
                nw_lab{end+1}   = virtsens.label{yi};
                
            end
            
        end
        
        virtsens.trial          = nw_pow ; clear nw_pow ;
        virtsens.label          = nw_lab ; clear nw_lab ;
        
        cfg                     = [];
        cfg.channel             = [31	32	75	76];
        virtsens                = ft_selectdata(cfg,virtsens);
        
        save(['../data/4BrainStorm/' suj '.SomaAuditory.mat'],'virtsens','-v7.3')  
        
    end
end