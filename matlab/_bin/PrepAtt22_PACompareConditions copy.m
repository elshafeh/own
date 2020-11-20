clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list       = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    lst_mth     = {'canolty','tort','PLV','ozkurt'};
    
    lst_chn     = {'maxHL_1','maxHL_2','maxHL_3','maxHL_4','maxHL_5','maxSTL_1','maxSTL_2','maxSTL_3','maxSTL_4','maxSTL_5', ...
        'maxHR_1','maxHR_2','maxHR_3','maxHR_4','maxHR_5','maxSTR_1','maxSTR_2','maxSTR_3','maxSTR_4','maxSTR_5'};
    
    lst_tme     = {'m600m200','p600p1000'};
    
    
    for nmethod = 1:length(lst_mth)
        
        lst_cnd     = {'RCnD','LCnD','NCnD'};
        
        for ncue = 1:length(lst_cnd)
            for ntime = 1:length(lst_tme)
                
                for nchan = 1:length(lst_chn)
                    
                    fname   = ['../data/paper_data/' suj '.' lst_cnd{ncue} '.prep21.maxAVMsepVoxels.1t120.' lst_tme{ntime} '.low.9t13.high5step.50t110.' ...
                        lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACeEvoked.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    tempotemp.freq                               = seymour_pac.amp_freq_vec;
                    tempotemp.time                               = seymour_pac.pha_freq_vec;
                    
                    tempotemp.powspctrm(nchan,:,:)               = seymour_pac.mpac;
                    
                    tempotemp.label{nchan}                       = lst_chn{nchan}; % ['audR no norm ' lst_tme{2} ' ' lst_mth{nmethod}];
                    tempotemp.dimord                             = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                    %                     time_temp{ntime}.powspctrm(2,:,:)                   = seymour_pac.mpac_norm;
                    %                     mpac(1,:,:)                                         = seymour_pac.mpac;
                    %                     msur(1,:,:)                                         = seymour_pac.mpac_surr;
                    %                     mstd(1,:,:)                                         = seymour_pac.mpac_std;
                    %                     time_temp{ntime}.powspctrm(3,:,:)                   = (mpac-msur) ./ mstd;
                    %                     time_temp{ntime}.label{2}                           = ['audR min norm ' lst_tme{2} ' ' lst_mth{nmethod}];
                    %                     time_temp{ntime}.label{3}                           = ['audR z norm ' lst_tme{2} ' ' lst_mth{nmethod}];
                    
                    
                    
                end
                
                tempotemp                       = h_transform_freq(tempotemp,{1:10,11:20},{'audL','audR'});
                
                for nka = 1:length(tempotemp.label)
                    tempotemp.label{nka} = [tempotemp.label{nka} ' ' lst_mth{nmethod}];
                end
                
                time_temp{ntime}                = tempotemp; clear tempotemp
                
            end
                            
            tenytemp                        = time_temp{2};
            %             tenytemp.powspctrm              = (time_temp{2}.powspctrm - time_temp{1}.powspctrm)./time_temp{1}.powspctrm;
            tenytemp.powspctrm              = (time_temp{2}.powspctrm - time_temp{1}.powspctrm); % ./time_temp{1}.powspctrm;

            allsuj_data{sb,ncue,nmethod}    = tenytemp;
            
            clear time_temp;
            
        end

        
        
    end
end

clearvars -except allsuj_data lst_* ; clc ;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];

% cfg.latency             = [7 15];
% cfg.frequency           = [60 100];
% cfg.avgoverfreq         = 'yes';

cfg.dim                 = allsuj_data{1}.dimord;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';
cfg.correctm            = 'cluster';

if strcmp(cfg.correctm ,'cluster')
    p_limit                 = 0.2;
else
    p_limit                 = 0.05;
end

endcfg.computecritval      = 'yes';
cfg.numrandomization    = 1000;
cfg.alpha               = 0.025;
cfg.tail                = 0;
cfg.neighbours          = neighbours;
cfg.minnbchan           = 0;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

ix_test                 = [1 2; 1 3; 2 3];

for nmethod = 1:length(lst_mth)
    
    list_test               = {};
    
    for ntest = 1:size(ix_test,1)
        
        stat{ntest,nmethod}                         = ft_freqstatistics(cfg,allsuj_data{:,ix_test(ntest,1),nmethod}, allsuj_data{:,ix_test(ntest,2),nmethod});
        list_test{end+1}                            = [lst_cnd{ix_test(ntest,1)} 'v' lst_cnd{ix_test(ntest,2)}];
        
        [min_p(ntest,nmethod),p_val{ntest,nmethod}] = h_pValSort(stat{ntest,nmethod});
        
    end
end

        
figure;
i = 0 ;

p_limit = 0.11;

for nmethod = 1:size(stat,2)
    for ntest = 1:size(stat,1)

        
        stat{ntest,nmethod}.mask    = stat{ntest,nmethod}.prob < p_limit;
        
        for nchan = 1:length(stat{ntest,nmethod}.label)
            
            i = i + 1;
            
            
            subplot(6,4,i)
            
            %                         plot(stat{ntest,nmethod}.time,squeeze(stat{ntest,nmethod}.mask .* stat{ntest,nmethod}.stat));
            %                         ylim([-3 3]);
            %                         xlim([stat{ntest,nmethod}.time(1) stat{ntest,nmethod}.time(end)])
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.colorbar                    = 'no';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.zlim                        = [-2 2];
            ft_singleplotTFR(cfg,stat{ntest,nmethod});
            
            title([stat{ntest,nmethod}.label{nchan} ' ' list_test{ntest}]);
            
            xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
        end
    end
end