clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   'AudViz.VirtTimeCourse.all.wav.1t90Hz.m2000p2000.mat';
    lst         =   {'DIS','fDIS'};
    
    for d = 1:2
        fname_in    = ['../data/tfr/' suj '.'  lst{d} '.' ext];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        nw_chn  = [3 5;4 6];
        nw_lst  = {'audL','audR'};
        
        for l = 1:2
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        clear freq ;
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.appenddim       = 'chan';
        tmp{d}              = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq ;
        
        cfg                 = [];
        cfg.baseline        = [-0.2 -0.1];
        cfg.baselinetype    = 'relchange';
        tmp{d}              = ft_freqbaseline(cfg,tmp{d});
        
    end
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.operation       = 'subtract';
    freq                = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
    
    flist = 60:5:85;
    ftap  = 5;
    
    for chn = 1:2
        for sub_f = 1:length(flist)
            
            lmt1 = find(round(freq.time,3) == round(0.3,3));
            lmt2 = find(round(freq.time,3) == round(0.5,3));
            
            lmf1 = find(round(freq.freq) == round(flist(sub_f)));
            lmf2 = find(round(freq.freq) == round(flist(sub_f)+ftap));
            
            data2permute{chn}(sb,sub_f) =  mean(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2)));
            
        end
    end
    
    load ../data/yctot/rt/rt_dis_per_delay.mat
    
    rt2permute(sb,1) = mean([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    rt2permute(sb,2) = median([rt_dis{sb,1}; rt_dis{sb,2}; rt_dis{sb,3}]);
    
end

for rt = 1:2
    for chn = 1:2
        for sub_f = 1:size(data2permute{chn},2)    
            [rho(rt,chn,sub_f),p(rt,chn,sub_f)] = corr(data2permute{chn}(:,sub_f), rt2permute(:,rt), 'type', 'Spearman');
            
        end
    end
end

mask    = p < 0.1 ;
nwRho   = mask .* rho ;

clc ;

[squeeze(nwRho(1,1,:))';squeeze(nwRho(1,2,:))';squeeze(nwRho(2,1,:))';squeeze(nwRho(2,2,:))']