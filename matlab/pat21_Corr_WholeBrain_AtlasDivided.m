clear;clc;

% load ../data/yctot/rt/rt_CnD_adapt.mat ;
% load ../data/yctot/elements4alpha2gamma.correlation.mat ;
% 
% for sb = 1:14
%     allsuj_behav{sb,5} = mean(rt_all{sb});
%     allsuj_behav{sb,6} = median(rt_all{sb});
% end

suj_list = [1:4 8:17];

% load ../data/yctot/index/ForCorrelation.bslcorrected.p600p100.7t11Hz.1AudL.2AudR.mat

ext_freq    = {'7t11Hz','11t15Hz'};
ext_time    = {'p200p600','p600p1000','p1400p1800'};
ext_bsl     = 'm600m200';

[cnd_freq,cnd_time] = prepare_cnd_freq_time(ext_freq,ext_time);
 
load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    source_avg{sb}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
    source_avg{sb}.pos    = template_source.pos;
    source_avg{sb}.dim    = template_source.dim;
    source_avg{sb}.freq   = cnd_freq;
    source_avg{sb}.time   = cnd_time;
    source_avg{sb}.dimord = 'pos_freq_time';
    
    for nfreq = 1:length(ext_freq)
        for ntime = 1:length(ext_time)
            
            src_carr{1} =[]; src_carr{2} =[];
            
            for npart = 1:3
                
                ext_lock    = 'CnD';
                ext_source  = '.NewSource.mat';
                
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{1} = [src_carr{1} source]; clear source ;
                
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_freq{nfreq} ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{2} = [src_carr{2} source]; clear source ;
                
            end
            
            bsl                                             = nanmean(src_carr{1},2);
            act                                             = nanmean(src_carr{2},2);
            pow                                             = (act-bsl)./bsl; clear bsl act src_carr;
            %             pow                                             = (act-bsl); clear bsl act src_carr;
            
            source_avg{sb}.pow(:,nfreq,ntime)    = pow ; clear pow;
            
        end
    end
    
    load ../data/yctot/gavg/CnD_percentage_correct_gavg.mat
    
    allsuj_behav{sb,1}          = sub_per{sb};
    
    
end

clearvars -except source_avg allsuj_behav

indxH       = h_createIndexfieldtrip; clc;
atlas       = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

for sb = 1:14
    for roi = 1:90
        inin                                        = indxH(indxH(:,2) == roi,1);
        powspctr                                    = squeeze(nanmedian(source_avg{sb}.pow(inin,:,:),1));
        
        new_source_avg{sb}.powspctrm(roi,:,:)       = powspctr;
        new_source_avg{sb}.time                     = source_avg{sb}.time;
        new_source_avg{sb}.freq                     = source_avg{sb}.freq;
        new_source_avg{sb}.dimord                   = 'chan_freq_time';

    end
    
    new_source_avg{sb}.label                    = atlas.tissuelabel(1:90);
    
end

source_avg = new_source_avg ;

clearvars -except source_avg allsuj_behav

[~,neighbours] = h_create_design_neighbours(14,source_avg{1},'e','t');

cfg                     = [];
% cfg.avgoverfreq         = 'yes';
% cfg.latency             = [0.55 1.05];
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_correlationT';
cfg.correctm            = 'cluster';
cfg.clusterstatistics   = 'maxsum';
cfg.clusteralpha        = 0.05;
cfg.minnbchan           = 0;
cfg.tail                = 0;cfg.clustertail         = 0;
cfg.alpha               = 0.025;cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;cfg.ivar                = 1;

corr_list               = {'Spearman','Pearson'}; clc;

for x = 1:length(corr_list)
    for y = 1:size(allsuj_behav,2)
        cfg.type            = corr_list{x};
        cfg.design(1:14)    = [allsuj_behav{:,y}];
        stat{x,y}           = ft_freqstatistics(cfg,source_avg{:});
    end
end

for x = 1:length(corr_list)
    for y = 1:size(allsuj_behav,2)
        [min_p(x,y),p_val{x,y}] =   h_pValSort(stat{x,y});
    end
end

for x = 1:length(corr_list)
    for y = 1:size(allsuj_behav,2)
        stat2plot{x,y}       = h_plotStat(stat{x,y},0.00000001,0.3);
    end
end

list_x = {'Spearman','Pearson'};
list_y = {'perc'}; %{'audL','audR','occL','occR','meanRT','medianRT'};

for x = 1:length(corr_list)
    for y = 1:size(allsuj_behav,2)
        for chn = 1:length(stat2plot{x,y}.label)
            cfg                    = [];
            cfg.channel            = chn;
            cfg.zlim               = [-4 4];
            if mean(mean(squeeze(stat2plot{x,y}.powspctrm(chn,:,:)))) ~= 0
                figure;
                ft_singleplotTFR(cfg,stat2plot{x,y});
                title([stat2plot{x,y}.label{chn} ' ' list_x{x} ' ' list_y{y}])
            end
        end
    end
end