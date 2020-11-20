clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

% [~,allsuj,~]        = xlsread('.././../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{2}        = allsuj(2:15,1);
% suj_group{1}        = allsuj(2:15,2);
%
% for ngroup = 1:length(suj_group)
%
%     suj_list = suj_group{ngroup};
%
%     for sb = 1:length(suj_list)
%
%         list_ix_cue    = {''};
%
%         for cnd = 1:length(list_ix_cue)
%
%             suj                                 = suj_list{sb};
%             ext_data                            = 'CnD.waveletPOW.1t50Hz.m3000p3000.50Mstep.AvgTrials.MinEvoked.mat';
%
%             fname_in                            = ['../../data/alpha_emergence/' suj '.' list_ix_cue{cnd} ext_data];
%
%             fprintf('\nLoading %s\n',fname_in);
%
%             load(fname_in)
%
%             if isfield(freq,'check_trialinfo')
%                 freq = rmfield(freq,'check_trialinfo');
%             end
%
%             [tmp{1},tmp{2}]                     = h_prepareBaseline(freq,[-0.6 -0.2],[5 45],[0 1.2],'no');
%
%             allsuj_activation{ngroup}{sb,cnd}   = tmp{1};
%             allsuj_baselineRep{ngroup}{sb,cnd}  = tmp{2}; clear tmp;
%
%         end
%     end
%
% end
%
% clearvars -except allsuj_*
%
% for ngroup = 1:length(allsuj_activation)
%
%     nsuj                        = size(allsuj_activation{ngroup},1);
%     [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'meg','t'); clc;
%
%     for ncue = 1:size(allsuj_activation{ngroup},2)
%
%         cfg                     = [];
%         cfg.clusterstatistic    = 'maxsum';
%         cfg.method              = 'montecarlo';
%         cfg.statistic           = 'depsamplesT';
%         cfg.correctm            = 'cluster';
%
%         cfg.neighbours          = neighbours;
%
%         cfg.clusteralpha        = 0.05; % !!
%
%         cfg.alpha               = 0.025;
%
%         cfg.tail                = 0;
%         cfg.clustertail         = 0;
%
%         cfg.numrandomization    = 1000;
%         cfg.design              = design;
%         cfg.uvar                = 1;
%         cfg.ivar                = 2;
%
%         cfg.minnbchan           = 4; % !!
%         stat{ngroup,1}          = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
%
%         stat{ngroup,1}          = rmfield(stat{ngroup,1},'cfg');
%
%     end
% end

% !!! %

load('../../data/stat/alpha_emergence_sens_stat.mat')

% !!! %

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val;

%

i                               = 0 ;

frq_list                        = [7 11;11 15];
chan_list{1}                    = {'MLP11', 'MLP12', 'MLP21', 'MLP22', 'MLP23' , ...
    'MLP56', 'MLP57', 'MLT11', 'MLT12', 'MLT13', 'MLT14' , ...
    'MLT26', 'MLT27', 'MLT34', 'MLT35', 'MLT36', 'MLT45'};

chan_list{2}                    = {'MRO12', 'MRO13', 'MRO14', 'MRO21', 'MRO22', 'MRO23', 'MRO24', 'MRO34'};

name_gp_list                    = {'young','old'};
name_fr_list                    = {'low','high'};
name_ch_list                    = {'TP sensors','Occ sensors'};

for nf = 1:2
    for ng = 1:2
        
        plimit                  = 0.1;
        data_to_plot            = h_plotStat(stat{ng,1},10e-20,plimit);
        zlim                    = 4;
        
        i                       = i+1;
        rw_plot                 = 2;
        cl_plot                 = 6;
        
        subplot(rw_plot,cl_plot,i)
        
        cfg                     = [];
        cfg.layout              = 'CTF275.lay';
        cfg.comment             = 'no';
        cfg.marker              = 'off';
        cfg.xlim                = [0.6 1];
        cfg.ylim                = frq_list(nf,:);
        cfg.zlim                = [-zlim zlim];
        ft_topoplotER(cfg,data_to_plot);
        
        title(upper([name_gp_list{ng} ' ' name_fr_list{nf}]));
        
        i                       = i + 1;
        subplot(rw_plot,cl_plot,i:i+1);
        hold on;
        
        cfg                     = [];
        cfg.channel             = chan_list{nf};
        cfg.parameter           = 'powspctrm';
        cfg.ylim                = [5 45];
        cfg.xlim                = [0 1.2];
        cfg.zlim                = [-zlim zlim];
        
        if i == 5 || i == 11
            cfg.colorbar        = 'yes';
        else
            cfg.colorbar        = 'no';
        end
        
        ft_singleplotTFR(cfg,data_to_plot);
        
        rectangle('Position',[0.6 frq_list(nf,1) 0.4 4],'Curvature',0.2,'LineWidth',3); % [x y w h]
        
        title(upper([name_gp_list{ng} ' ' name_ch_list{nf}]));
        
        i                       = i+1;
        
    end
end