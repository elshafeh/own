clear ; clc ;

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
    
    nw_chn      = [3 5; 4 6];nw_lst      = {'audL','audR'};
    
    for l = 1:2
        cfg             = [];cfg.channel     = nw_chn(l,:);cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg                     = [];cfg.parameter           = 'powspctrm';cfg.appenddim           = 'chan';
    freq                    = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    flist{1} = 8;%:15 ;
    flist{2} = 60;%:5:85;
    
    ftap     = [0 30];
    
    bsl_period              = [-0.4 -0.2; -0.2 -0.1];
    
    for f = 1:2
        cfg                 = [];
        cfg.baseline        = bsl_period(f,:);
        cfg.baselinetype    = 'relchange';
        nw_frq{f}           = ft_freqbaseline(cfg,freq);
    end
    
    freq = nw_frq; clear nw_frq ;
    
    for chn = 1:2
        for f = 1:2
            for sub_f = 1:length(flist{f})
                
                lmt1 = find(round(freq{f}.time,3) == round(0.3,3));
                lmt2 = find(round(freq{f}.time,3) == round(0.5,3));
                
                lmf1 = find(round(freq{f}.freq) == round(flist{f}(sub_f)));
                lmf2 = find(round(freq{f}.freq) == round(flist{f}(sub_f)+ftap(f)));
                
                data2permute{chn,f}(sb,sub_f) =  mean(mean(freq{f}.powspctrm(chn,lmf1:lmf2,lmt1:lmt2)));
                
            end
        end
    end
end

clearvars -except data2permute ;

for chn = 1:2
    
    for flo = 1:size(data2permute{1,1},2)
        
        for fhigh = 1:size(data2permute{1,2},2)
            
            x   = data2permute{chn,1}(:,flo);
            y   = data2permute{chn,2}(:,fhigh);
            
            [rho{chn}(flo,fhigh) ,p{chn}(flo,fhigh)] = corr(x,y, 'type', 'Spearman');
            
            
        end
    end
end