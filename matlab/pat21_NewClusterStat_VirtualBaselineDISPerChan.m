clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    cnd_list    = {'DIS','fDIS'};
    
    for xi = 1:2
        
        ext1        =   '.RamaBigCov.all.MinusEvoked.wavPOW.4t140Hz.m3000p3000.mat';
        fname_in    =   ['../data/all_data/' suj '.'  cnd_list{xi} ext1];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo')
            freq    = rmfield(freq,'hidden_trialinfo');
        end
        
        load ../data/yctot/index/RamaAlphaFusion.mat ;
        
        freq.label     = final_rama_list(:,2);
        
        lst_new        = {{'audL'},{'audR'},freq.label([1:87 92:99])};
        lst_chn        = {[88 90],[89 91],[1:87 92:99]};
        
        for nn = 1:3
            
            cfg                 = [];
            cfg.channel         = lst_chn{nn};
            
            if length(lst_chn{nn}) <3
                cfg.avgoverchan = 'yes';
            end
            
            tmp{nn}             = ft_selectdata(cfg,freq);
            
        end
        
        tmp{1}.label    = {'audL'};
        tmp{2}.label    = {'audR'};
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';
        cfg.appenddim   = 'chan';
        freq            = ft_appendfreq(cfg,tmp{:}); clear tmp
        
        %         cfg             = [];
        %         cfg.channel     = [2 12];
        %         freq            = ft_selectdata(cfg,freq);
        
        twin            = 0.1;
        tlist           = -2:twin:2;
        pow             = [];
        
        if twin ~=0
            for t = 1:length(tlist)
                x1  = find(round(freq.time,3) == round(tlist(t),3)); x2 = find(round(freq.time,3) == round(tlist(t)+twin,3));
                tmp = squeeze(mean(freq.powspctrm(:,:,x1:x2),3));
                pow = cat(3,pow,tmp);
                clear tmp ;
            end
            
            freq.time        =  tlist;
            freq.powspctrm   =  pow; clear pow;
        end
        
        lst_bsl          = [-0.6 -0.2; -0.4 -0.2; -0.2 -0.1];
        lst_frq          = [5 15; 16 48; 50 140];
        lst_act          = [-0.2 1; -0.2 1; -0.2 1];
        
        for ncond = 1:3
            [tmp_act{ncond,xi},~]   = h_prepareBaseline(freq,lst_bsl(ncond,:),lst_frq(ncond,:),lst_act(ncond,:),'non');
        end
        
        clear freq lst_* ext1
        
    end
    
    clearvars -except tmp* sb allsuj_*
    
    cfg                    = [];
    cfg.parameter          = 'powspctrm';
    allsuj_activation{sb}  = ft_appendfreq(cfg,tmp_act{:,1});
    allsuj_baselineRep{sb} = ft_appendfreq(cfg,tmp_act{:,2});
    
    clear tmp*;
    
end

clearvars -except allsuj_* gavg_suj

[design,neighbours]     = h_create_design_neighbours(length(allsuj_activation),allsuj_activation{1,1},'virt','t');

cfg                     = [];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.latency             = [-0.2 0.6];
cfg.frequency           = [40 100];
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 500;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;

h = waitbar(0,'Permuting ..');

for chan = 1:length(allsuj_activation{1}.label)
    cfg.channel             = chan;
    waitbar(chan/length(allsuj_activation{1}.label));
    stat{chan}              = ft_freqstatistics(cfg, allsuj_activation{:}, allsuj_baselineRep{:});
end

close(h);
close all;

for i = 1:length(allsuj_activation{1}.label)
    
    [min_p(i),p_val{i}]   = h_pValSort(stat{i});
    p_lim                       = 0.2;
    stat2plot                   = h_plotStat(stat{i},0.000000000000000000000000001,p_lim);
    %     stat2plot.powspctrm         = squeeze(stat2plot.powspctrm);
        
    figure;
    cfg             = [];
    %     cfg.channel     = i;
    %     cfg.xlim        = [0 0.6];
    %     cfg.ylim        = [40 100];
    cfg.zlim        = [-4 4];
    cfg.colorbar    = 'no';
    ft_singleplotTFR(cfg,stat2plot);clc;
    vline(0,'-k');
    
end
