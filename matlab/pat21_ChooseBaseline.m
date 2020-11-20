clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   'AudViz.VirtTimeCourse.all.wav.1t90Hz.m2000p2000.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/tfr/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo');
            freq = rmfield(freq,'hidden_trialinfo');
        end
        
        nw_chn  = [3 5;4 6];
        nw_lst  = {'audL','audR'};
        
        for l = 1:length(nw_lst)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        clear freq
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';
        cfg.appenddim   = 'chan';
        tmp{d}          = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        
        
        clear freq;
    end
    
    cfg             = [];
    cfg.parameter   = 'powspctrm';
    cfg.operation   = 'subtract';
    allsuj{sb,1}      = ft_math(cfg,tmp{1},tmp{2});
    cfg.operation   = '(x1-x2)./x2';
    allsuj{sb,2}      = ft_math(cfg,tmp{1},tmp{2});

    
end

clearvars -except allsuj ;

for c = 1:2
    avg{c} = ft_freqgrandaverage([],allsuj{:,c});
end

i = 0 ;

for cnd = 1:2
    for chn = 1:2
        
        i = i + 1;
        subplot(2,2,i)
        cfg             = [];
        cfg.xlim        = [-0.4 1];
        cfg.ylim        = [40 90];
        cfg.channel     = chn;
        ft_singleplotTFR(cfg,avg{cnd});
        vline(0,'-k');
        vline(0.3,'-k');
    end
end