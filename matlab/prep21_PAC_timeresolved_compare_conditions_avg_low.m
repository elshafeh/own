clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list       = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst_cnd     = {'RCnD','LCnD','NCnD'};
    
    lst_mth     = {'PLV','canolty','ozkurt'};
    lst_bsl     = 'm320m200';
    lst_chn     = {'aud_R'};
    lst_tme     = {'m200m80','m80m40','p40p160','p160p280','p280p400','p400p520','p520p640','p640p760','p760p880','p880p1000', ...
        'p1000p1120','p1120p1240'}; %,'p1240p1360','p1360p1480','p1480p1600','p1600p1720'};
    
    tme_axe     = -0.2:0.12:1.2;
    
    for ncue = 1:length(lst_cnd)
        for nmethod = 1:length(lst_mth)
            for nchan = 1:length(lst_chn)
                
                pow       = zeros(9,length(lst_tme));
                bsl       = zeros(9,length(lst_tme));
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/paper_data/' suj '.' lst_cnd{ncue} '.prep21.AV.' lst_tme{ntime} '.low.7t15.high.60t100.' ...
                        lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    lmf1                                        = find(seymour_pac.amp_freq_vec == 60);
                    lmf2                                        = find(seymour_pac.amp_freq_vec == 100);
                    act                                         = squeeze(mean(seymour_pac.mpac_norm(lmf1:lmf2,:),1));
                    
                    fname   = ['../data/paper_data/' suj '.' lst_cnd{ncue} '.prep21.AV.' lst_bsl '.low.7t15.high.60t100.' ...
                        lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    bsl                                         = squeeze(mean(seymour_pac.mpac_norm(lmf1:lmf2,:),1));
                    %                     bsl                                         = squeeze(mean(seymour_pac.mpac(lmf1:lmf2,:),1));
                    
                    pow(:,ntime)                                = (act-bsl)./bsl;
                    
                    clear bsl act ;
                    
                end
                
                tmp{nchan}.powspctrm(1,:,:)                     = pow;                
                tmp{nchan}.freq                                 = seymour_pac.pha_freq_vec;
                tmp{nchan}.time                                 = tme_axe;
                tmp{nchan}.label                                = lst_chn(nchan);
                tmp{nchan}.dimord                               = 'chan_freq_time';
                
                clear seymour_pac
                
            end
            
            cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
            allsuj_data{sb,ncue,nmethod} = ft_appendfreq(cfg,tmp{:});
            
            clear tmp;
            
        end
    end
end

clearvars -except allsuj_data lst_* ; clc ;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];
% cfg.latency             = [7 12];
% cfg.frequency           = [50 100];
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

for ncue = 1:size(ix_test,1)
    for nmethod = 1:size(allsuj_data,3)
        stat{ncue,nmethod}         = ft_freqstatistics(cfg,allsuj_data{:,ix_test(ncue,1),nmethod}, allsuj_data{:,ix_test(ncue,2),nmethod,1});
    end
end

for ncue = 1:size(stat,1)
    for nmethod = 1:size(stat,2)
        [min_p(ncue,nmethod),p_val{ncue,nmethod}] = h_pValSort(stat{ncue,nmethod});
    end
end

close all;

figure;
i = 0 ;

for ncue = 1:size(stat,1)
    for nmethod = 1:size(stat,2)
        for nchan = 1:length(stat{ncue,nmethod}.label)
            
            i = i + 1;
            
            p_limit                         = 0.05;
            
            stat{ncue,nmethod}.mask         = stat{ncue,nmethod}.prob < p_limit;
            
            subplot(size(stat,1),size(stat,2),i)
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.colorbar                    = 'no';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.zlim                        = [-2 2];
            
            ft_singleplotTFR(cfg,stat{ncue,nmethod});
            
            lst_cnd                         = {'RvL','RvN','LvN'};
            
            title([stat{ncue,nmethod}.label{nchan} ' ' lst_cnd{ncue} ' ' lst_mth{nmethod}]);
            
            %             xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
            
        end
    end
end