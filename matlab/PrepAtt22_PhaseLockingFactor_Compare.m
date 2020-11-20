clear ; clc ; close all;

addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/'); % or wherever you put brewermap

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj                                 = suj_list{sb};
    
    %     cond_main{1}                        = 'nDT.BroadAud5perc.1t110Hz.m2000p800msCov.mbonPhaseLockingValue.minEvoked';
    %     cond_main{2}                        = 'nDT.BroadAud5perc.1t110Hz.m2000p800msCov.mbonPhaseLockingValue.eEvoked';
    
    cond_main{1}                        = 'DIS.BroadAud5perc.1t110Hz.m200p400msCov.mbonPhaseLockingValue.minEvoked';
    cond_main{2}                        = 'DIS.BroadAud5perc.1t110Hz.m200p400msCov.mbonPhaseLockingValue.eEvoked';
    
    
    for ncue = 1:length(cond_main)
        
        dir_data                        = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];
        fname_in                        = [dir_data suj '.' cond_main{ncue} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        % % !! % % !! % % !! % % !!
        phase_lock.powspctrm            = .5.*log((1+phase_lock.powspctrm)./(1-phase_lock.powspctrm)); % % !!
        % % !! % % !! % % !! % % !!
        
        load /Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22//data_fieldtrip/index/broadmanAuditory_Separate.mat
        
        transform_freq.index            = {};
        transform_freq.label            = {};
        
        for nolivier = 1:length(list_H)
            transform_freq.index{nolivier} = find(index_H(:,2) == nolivier);
            transform_freq.label{nolivier} = list_H{nolivier};
        end
        
        
        phase_lock                      = h_transform_freq(phase_lock,transform_freq.index,transform_freq.label);
        allsuj_data{sb,ncue}            = phase_lock; clear phase_lock;
        
    end
end


figure;
i = 0 ;

for ncue = 1:size(allsuj_data,2)
    for nchan = 1:length(allsuj_data{1,ncue}.label);
        
        i = i + 1;
        subplot(2,6,i)
        
        cfg                 = [];
        
        cfg.channel         = nchan;
        
        %         cfg.xlim            = [-0.1 0.4];
        %         cfg.ylim            = [50 110];
        
        cfg.zlim            = [0 0.2];
        ft_singleplotTFR(cfg,ft_freqgrandaverage([],allsuj_data{:,ncue}));
        title('');
        %         colormap(brewermap(256, '*RdYlBu'));
        
    end
end

% nsuj                    = size(allsuj_data,1);
% [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;
%
% cfg                     = [];
% cfg.clusterstatistic    = 'maxsum';
% cfg.method              = 'montecarlo';
% cfg.statistic           = 'depsamplesT';
%
% cfg.correctm            = 'cluster';
% cfg.neighbours          = neighbours;
%
% cfg.latency             = [-0.1 0.4];
% cfg.frequency           = [50 110];
%
% cfg.clusteralpha        = 0.01;
%
% cfg.alpha               = 0.025;
% cfg.minnbchan           = 0;
% cfg.tail                = 0;
% cfg.clustertail         = 0;
% cfg.numrandomization    = 1000;
% cfg.design              = design;
% cfg.uvar                = 1;
% cfg.ivar                = 2;
%
% stat                    = ft_freqstatistics(cfg, allsuj_data{:,1},allsuj_data{:,2});
% [min_p,p_val]           = h_pValSort(stat);
%
% stat.mask               = stat.prob < 0.05;
%
% for nchan = 1:length(stat.label);
%
%     subplot(1,2,nchan)
%
%     cfg                 = [];
%     cfg.channel         = nchan;
%
%     cfg.xlim            = [-0.1 0.4];
%     cfg.ylim            = [50 110];
%
%     cfg.parameter       = 'stat';
%     cfg.maskparameter   = 'mask';
%     cfg.maskstyle       = 'outline';
%
%     cfg.zlim            = [0 0.1];
%
%     ft_singleplotTFR(cfg,stat);
%
% end
