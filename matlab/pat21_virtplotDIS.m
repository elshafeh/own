clear ; clc ;

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext1        =   'AudViz.VirtTimeCourse.all.wav' ;
    ext2        =   '1t90Hz.m2000p2000.mat';
    lst         =   'RLN';
    
    for cnd_cue = 1:length(lst)
        fname_in    = ['../data/tfr/' suj '.'  lst(cnd_cue) 'nDT.' ext1 '.' ext2];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo')
            freq        = rmfield(freq,'hidden_trialinfo');
        end
        
        nw_chn      = [3 5;4 6];
        nw_lst      = {'audL','audR'};
        
        for l = 1:2
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg                     = [];
        cfg.parameter           = 'powspctrm';
        cfg.appenddim           = 'chan';
        allsuj{a,cnd_cue}       = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        cfg                     = [];
        cfg.baseline            = [-1.8 -1.4];
        cfg.baselinetype        = 'relchange';
        allsuj{a,cnd_cue}       = ft_freqbaseline(cfg,allsuj{a,cnd_cue});
    end
end

clearvars -except allsuj ;

for cnd_cue =1:3
    gavg{cnd_cue} = ft_freqgrandaverage([],allsuj{:,cnd_cue});
end

for f = 7:15
    for cnd_cue = 1:3
        cfg                 = [];
        cfg.frequency       = [f f+1];
        cfg.avgoverfreq     = 'yes';
        gavg_slct{cnd_cue}  = ft_selectdata(cfg,gavg{cnd_cue});
        toplot(cnd_cue,:,:) = squeeze(gavg_slct{cnd_cue}.powspctrm);
    end
    figure;
    for chn = 1:2
        subplot(1,2,chn)
        plot(gavg_slct{1}.time,squeeze(toplot(:,chn,:))) ;
        xlim([-0.2 1]);
        ylim([-0.6 0.6])
        title(gavg_slct{1}.label{chn});
        legend({'R','L','N'});
        vline(0,'-k');
        hline(0,'-k');
    end
end