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
                    
                    %                     pow(:,ntime)                                = (act-bsl)./bsl;
                    pow(:,ntime)                                = act-bsl;

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

for ncue = 1:size(allsuj_data,2)
    for nmethod = 1:size(allsuj_data,3)
        
        grand_average{ncue,nmethod} = ft_freqgrandaverage([],allsuj_data{:,ncue,nmethod});
        
    end
end

clearvars -except allsuj_data lst_* grand_average; clc ;

for nmethod = 1:size(grand_average,2)
    
    subplot(1,3,nmethod)
    hold on;
    
    for ncue = 1:size(grand_average,1)
        
        cfg             = [];
        cfg.frequency   = [13 13];
        cfg.avgoverfreq = 'yes';
        data_plot       = ft_selectdata(cfg,grand_average{ncue,nmethod});
        
        plot(data_plot.time,squeeze(data_plot.powspctrm));
        ylim([-0.02 0.02]);
        xlim([-0.2 1.2])
        title(lst_mth{nmethod});
    end
    
    legend(lst_cnd);
    
end