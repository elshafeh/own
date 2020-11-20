clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

suj_list        = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    lst_cnd     = {'RCnD','LCnD','NCnD'};
    
    lst_mth     = {'PLV'};
    lst_chn     = {'aud_R'};
    %     lst_tme     = {'m1000m200','p200p1000'};
    lst_tme     = {'m600m200','p600p1000'};
    
    for ncue = 1:length(lst_cnd)
        for nmethod = 1:length(lst_mth)
            for nchan = 1:length(lst_chn)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../../PAT_MEG21/pat.field/data/' suj '.' lst_cnd{ncue} '.prep21.' lst_tme{ntime} '.' lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    time_temp{ntime}.powspctrm(1,:,:)                 = seymour_pac.mpac_norm;
                    time_temp{ntime}.freq                             = seymour_pac.amp_freq_vec;
                    time_temp{ntime}.time                             = seymour_pac.pha_freq_vec;
                    time_temp{ntime}.label                            = {'Right Auditory Cortex'} ; %lst_chn(nchan);
                    time_temp{ntime}.dimord                           = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                end
                
                chan_temp{nchan}               = time_temp{2};
                chan_temp{nchan}.powspctrm     = (time_temp{2}.powspctrm - time_temp{1}.powspctrm)./time_temp{1}.powspctrm;
                
                clear time_temp;
                
            end
            
            if nchan == 1
                allsuj_data{sb,ncue,nmethod} = chan_temp{1};
            else
                cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
                allsuj_data{sb,ncue,nmethod} = ft_appendfreq(cfg,chan_temp{:});
            end
            
            clear chan_temp;
            
        end
    end
end

clearvars -except allsuj_data lst_* ; clc ;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];

% cfg.latency             = [7 12];
% cfg.frequency           = [60 100];

cfg.dim                 = allsuj_data{1}.dimord;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';
cfg.correctm            = 'fdr';
cfg.computecritval      = 'yes';
cfg.numrandomization    = 1000;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.neighbours          = neighbours;
cfg.minnbchan           = 0;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

ix_test                 = [1 2; 1 3; 2 3];
list_test               = {};

for ntest = 1:size(ix_test,1)
    for nmethod = 1:length(lst_mth)
        
        stat{ntest,nmethod}         = ft_freqstatistics(cfg,allsuj_data{:,ix_test(ntest,1),nmethod}, allsuj_data{:,ix_test(ntest,2),nmethod});
        list_test{end+1}            = [lst_cnd{ix_test(ntest,1)} ' v ' lst_cnd{ix_test(ntest,2)}];
        
    end
end

for nmethod = 1:size(stat,2)
    
    figure;
    i = 0 ;
    
    for ntest = 1:size(stat,1)
        for nchan = 1:length(stat{ntest,nmethod}.label)
            
            i = i + 1;
            
            p_limit     = 0.1;
            
            stat{ntest,nmethod}.mask    = stat{ntest,nmethod}.prob < p_limit;
            
            subplot(size(stat,1),length(stat{ntest,nmethod}.label),i)
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.colorbar                    = 'no';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.zlim                        = [-2 2];
            
            ft_singleplotTFR(cfg,stat{ntest,nmethod});
            
            title([stat{ntest,nmethod}.label{nchan} ' ' list_test{ntest} ' ' lst_mth{nmethod}]);
            
            xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
            
        end
    end
end