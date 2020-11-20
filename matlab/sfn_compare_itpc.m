clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

suj_list            = [1:4 8:17] ;

for sb = 1:length(suj_list)
    
    suj             = ['yc' num2str(suj_list(sb))] ;
    list_cond       = {'RCnD','LCnD'}; % {'LCnD','NLCnD'}; % {'RCnD','LCnD'}; % {'RCnD','NCnD'}; % {'LCnD','NCnD'};
    list_evoked     = {'eEvoked','mEvoked'};
    
    for nevo = 1:2
        for ncue = 1:length(list_cond)
            
            fname       = ['../data/conn/' suj '.' list_cond{ncue} '.PaperAudVisTD.1t20Hz.m800p2000msCov.fourier.' list_evoked{nevo} '.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            tmp{ncue}   = freq; clear freq;
            
        end
        
        [phi{1}, ~, ~, ~]          = obob_itc_pbi(tmp{2}, tmp{1});
        
        phi{2}                      = phi{1};
        phi{2}(:)                   = 0;
        
        for nphi = 1:2
            
            allsuj_data{sb,nevo,nphi}               = [];
            allsuj_data{sb,nevo,nphi}.powspctrm     = phi{nphi};
            allsuj_data{sb,nevo,nphi}.freq          = tmp{1}.freq;
            allsuj_data{sb,nevo,nphi}.time          = tmp{1}.time;
            allsuj_data{sb,nevo,nphi}.label         = tmp{1}.label;
            allsuj_data{sb,nevo,nphi}.dimord        = 'chan_freq_time';
            
        end
        
        clear phi tmp;
        
    end
end

clearvars -except allsuj_data;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];
cfg.neighbours          = neighbours;
cfg.frequency           = [5 15];
cfg.minnbchan           = 0;
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

for ix = 1:2
    stat{ix}            = ft_freqstatistics(cfg,allsuj_data{:,ix,1}, allsuj_data{:,ix,2});
end

clearvars -except allsuj_data stat;

for istat = 1:length(stat)
    [list_min_p(istat),list_p_val{istat}]   = h_pValSort(stat{istat});  
end

for istat = 1:length(stat)
    
    p_limit         = 0.05;
    
    if list_min_p(istat) < p_limit
        
        stat2plot               = h_plotStat(stat{istat},0.0000000000000000000001,0.05);
        figure;
        for nchan = 1:16
            
            subplot(4,4,nchan)
            cfg                 = [];
            cfg.channel         = nchan;
            cfg.xlim            = [-0.2 1.2];
            cfg.zlim            = [-5 5];
            ft_singleplotTFR(cfg,stat2plot);
            
        end
    end
end