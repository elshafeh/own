clear ; clc ;

load ../data/yctot/rt/rt_cond_classified.mat

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   'AudViz.VirtTimeCourse.all.wav' ;
    ext2        =   '1t90Hz.m2000p2000.mat';
    
    fname_in    = ['../data/tfr/' suj '.nDT.' ext1 '.' ext2];
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq        = rmfield(freq,'hidden_trialinfo');
    end
    
    nw_chn      = [4 6];nw_lst      = {'audR'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];cfg.channel     = nw_chn(l,:);cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg                     = [];cfg.parameter           = 'powspctrm';cfg.appenddim           = 'chan';
    freq                    = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    ftap                    = 5 ;
    flist                   = 40:ftap:85;
    
    bsl_period              = [-1.4 -1.3];
    
    cfg                     = [];
    cfg.baseline            = bsl_period;
    cfg.baselinetype        = 'relchange';
    freq                    = ft_freqbaseline(cfg,freq);
    
    
    for chn = 1:length(freq.label)
        for sub_f = 1:length(flist)
            
            lmt1 = find(round(freq.time,3) == round(0.2,3));
            lmt2 = find(round(freq.time,3) == round(0.4,3));
            
            lmf1 = find(round(freq.freq) == round(flist(sub_f)));
            lmf2 = find(round(freq.freq) == round(flist(sub_f)+ftap));
            
            data2permute{chn}(sb,sub_f) =  mean(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2)));
            
        end
    end
    
    
    rt2permute(sb,1) = mean(rt_all{sb});
    rt2permute(sb,2) = median(rt_all{sb});
    
end

clearvars -except *2permute

for rt = 1:2
    for sub_f = 1:size(data2permute{1},2)
        [rho(rt,sub_f),p(rt,sub_f)] = corr(data2permute{1}(:,sub_f), rt2permute(:,rt), 'type', 'Spearman');      
    end
end

mask    = p < 0.1 ;
nwRho   = mask .* rho ;

clc ;