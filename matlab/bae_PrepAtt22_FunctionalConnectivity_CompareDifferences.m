clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
suj_list     = suj_group{1};

clearvars -except *suj_list ;

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    cond_main           = 'CnD';
    list_ix_cond        = {'R','L','NR','NL'};
    
    for ncue = 1:length(list_ix_cond)
        
        fname_in               = ['../data/' suj '/field/' suj '.' list_ix_cond{ncue} cond_main '.5t15Hz.m1000p2000ms.FeFAudIPSACC.plv.mat'];
        fprintf('\nLoading %50s \n\n',fname_in);
        load(fname_in)
        
        tmp{sb,ncue}.powspctrm       = [];
        tmp{sb,ncue}.time            = freq_plv.time;
        tmp{sb,ncue}.freq            = freq_plv.freq;
        tmp{sb,ncue}.dimord          = 'chan_freq_time';
        tmp{sb,ncue}.label           = {};
        
        aud_list    = [8 9 10 11];
        chan_list   = 1:11;
        
        i           = 0;
        
        lst_done    = {};
        
        for x = 1:length(aud_list)
            for y = 1:length(chan_list)
                if aud_list(x) ~= chan_list(y)
                    
                    flg = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
                    
                    if isempty(find(strcmp(lst_done,flg)))
                        
                        lst_done{end+1}                                 = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
                        lst_done{end+1}                                 = [num2str(chan_list(y)) '.' num2str(aud_list(x))];
                        
                        i                                               = i +1;
                        tmp{sb,ncue}.powspctrm(i,:,:)             = squeeze(freq_plv.powspctrm(aud_list(x),chan_list(y),:,:));
                        tmp{sb,ncue}.label{end+1}                 = [freq_plv.label{aud_list(x)} ' ' num2str(aud_list(x)) ' ' freq_plv.label{chan_list(y)} ' ' num2str(chan_list(y))];
                        
                    end
                end
            end
        end
        
        cfg                  = [];
        cfg.baseline         = [-0.6 -0.2];
        cfg.baselinetype     = 'absolute';
        tmp{sb,ncue}         = ft_freqbaseline(cfg,tmp{sb,ncue});
        
    end
    
    ix_test                 = [1 3; 2 4];
    
    for ntest = 1:size(ix_test,1)
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.operation       = 'x1-x2';
        allsuj_GA{sb,ntest} = ft_math(cfg, tmp{sb,ix_test(ntest,1)}, tmp{sb,ix_test(ntest,2)});
    end
    
end

clearvars -except allsuj_GA

[design,neighbours]     = h_create_design_neighbours(length(allsuj_GA),allsuj_GA{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'fdr';%'fdr';
cfg.latency             = [0.2 1];
cfg.frequency           = [7 15];
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;

for ntest = 1
    stat{ntest}        = ft_freqstatistics(cfg, allsuj_GA{:,1}, allsuj_GA{:,2});
end

for ntest = 1
    [min_p(ntest),p_val{ntest}]     = h_pValSort(stat{ntest});
end

for ntest = 1
    
    figure;
    
    for chan = 1:length(stat{ntest}.label)
        
        stat{ntest}.mask     = stat{ntest}.prob < 0.11;
        
        %         if max(max(max(stat{ntest}.mask(chan,:,:)))) == 1
        
        %             i = i + 1;
        
        subplot(6,6,chan)
        
        %         figure;
        cfg                 = [];
        cfg.parameter       = 'stat';
        cfg.maskparameter   = 'mask';
        cfg.colorbar        = 'no';
        cfg.maskstyle       = 'outline';%'outline';
        cfg.channel         = chan;
        cfg.zlim            = [-5 5];
        ft_singleplotTFR(cfg,stat{ntest});
        
        title(['test no ' num2str(ntest) ' ' stat{ntest}.label{chan}]);
        colormap('jet')
        
        
        %         end
    end
end