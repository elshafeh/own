clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list       = [1:4 8:17]; % 1:21; %

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    lst_cnd     = {'CnD','RCnD','LCnD','NCnD'};
    lst_mth     = {'canolty','tort','PLV','ozkurt'};
    lst_chn     = {'aud_R','aud_L'};
    lst_tme     = {'m600m200','p600p1000'};
    
    for ntime = 1:length(lst_tme)
        
        ihi = 0 ;
        
        for nchan = 1:length(lst_chn)
            for ncue = 1:length(lst_cnd)
                for nmethod = 1:length(lst_mth)
                    
                    fname   = ['../data/paper_data/' suj '.' lst_cnd{ncue} '.prep21.AV.' lst_tme{ntime} '.low.7t20.high2step.50t110.' ...
                        lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    ihi                                             = ihi + 1;
                    
                    tmp{ihi}.freq                                   = seymour_pac.amp_freq_vec;
                    tmp{ihi}.time                                   = seymour_pac.pha_freq_vec;
                    
                    tmp{ihi}.powspctrm(1,:,:)                       = seymour_pac.mpac;
                    
                    tmp{ihi}.label{1}                               = [lst_chn{nchan} ' ' lst_cnd{ncue} ' ' lst_mth{nmethod}];
                    tmp{ihi}.dimord                                 = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                end
                
            end
        end
        
        cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
        allsuj_data{sb,ntime} = ft_appendfreq(cfg,tmp{:}); clear tmp ;
        
    end
end

clearvars -except allsuj_data lst_* ; clc ;

nsuj                    = size(allsuj_data,1); [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];

cfg.latency             = [7 15];
cfg.frequency           = [60 100];

% cfg.avgoverfreq         = 'yes';
% cfg.avgovertime         = 'yes';

cfg.dim                 = allsuj_data{1}.dimord;
cfg.method              = 'montecarlo'; cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';

cfg.correctm            = 'cluster';

if strcmp(cfg.correctm ,'cluster')
    p_limit                 = 0.05;
else
    p_limit                 = 0.05;
end

cfg.computecritval      = 'yes';
cfg.numrandomization    = 1000; cfg.alpha               = 0.025; cfg.tail                = 0;
cfg.neighbours          = neighbours; cfg.minnbchan     = 0;
cfg.design              = design;
cfg.uvar                = 1; cfg.ivar                = 2;

stat                    = ft_freqstatistics(cfg,allsuj_data{:,2}, allsuj_data{:,1});
[min_p,p_val]           = h_pValSort(stat);

close all;

figure;
i = 0 ;

for nchan = 1:length(stat.label)
    
    i = i + 1;
    
    stat.mask         = stat.prob < p_limit;
    
    subplot(4,8,i)
    
    [x_ax,y_ax,z_ax]  = size(stat.stat);
    
    if y_ax == 1
        
        plot(stat.time,squeeze(stat.mask(nchan,:,:) .* stat.stat(nchan,:,:)));
        ylim([-3 3]);
        xlim([stat.time(1) stat.time(end)])
        
    elseif z_ax == 1
        
        plot(stat.freq,squeeze(stat.mask(nchan,:,:) .* stat.stat(nchan,:,:)));
        ylim([-3 3]);
        xlim([stat.freq(1) stat.freq(end)])
        
    else
        
        cfg                             = [];
        cfg.channel                     = nchan;
        cfg.parameter                   = 'stat';
        cfg.colorbar                    = 'no';
        cfg.maskparameter               = 'mask';
        cfg.maskstyle                   = 'outline';
        cfg.zlim                        = [-2 2];
        ft_singleplotTFR(cfg,stat);
        
    end
    
    title(stat.label{nchan});
    
    xlabel('Phase (Hz)');
    ylabel('Amplitude (Hz)');
    
end

%                     tmp{nchan}.label{2}                           = [lst_chn{nchan} ' mn norm ' lst_tme{2} ' ' lst_cnd{ncue} ' ' lst_mth{nmethod}];
%                     tmp{nchan}.label{3}                           = [lst_chn{nchan} ' zs norm ' lst_tme{2} ' ' lst_cnd{ncue} ' ' lst_mth{nmethod}];



%                     tmp{nchan}.powspctrm(2,:,:)                   = seymour_pac.mpac_norm;
%                     mpac(1,:,:)                                   = seymour_pac.mpac;
%                     msur(1,:,:)                                   = seymour_pac.mpac_surr;
%                     mstd(1,:,:)                                   = seymour_pac.mpac_std;
%                     tmp{nchan}.powspctrm(3,:,:)                   = (mpac-msur) ./ mstd;