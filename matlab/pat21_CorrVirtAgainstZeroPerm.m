clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.postConn.TimeCourse.kt.wav.5t18Hz.m3p3.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                 = [];
    cfg.channel         = 1:6;
    freq_temp           = ft_selectdata(cfg,freq);
    
    clear freq ; 
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.Motor.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg             = [];
    cfg.latency     = [-3 3];
    freq            = ft_selectdata(cfg,freq);
    
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.appenddim       = 'chan';
    freq                = ft_appendfreq(cfg,freq,freq_temp);
    
    clear freq_temp
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    big_data{1}                 = ft_freqbaseline(cfg,freq);
    big_data{2}                 = freq;
    
    clear freq
    
    fprintf('Calculating Correlation\n');
    
    for cnd_bsl = 1:2
        
        data_sub = big_data{cnd_bsl} ; 
        
        clear freq fname suj
        
        load ../data/yctot/rt/rt_CnD_adapt.mat
        
        frq_list = 7:15;
        tim_win  = 0.2;
        tm_list  = 0.9;
        
        for t = 1:length(tm_list)
            
            for f = 1:length(frq_list)
                
                x1 = find(round(data_sub.time,2) == round(tm_list(t),2)) ;
                x2 = find(round(data_sub.time,2) == round(tm_list(t)+tim_win,2)) ;
                x3 = find(round(data_sub.freq)   == round(frq_list(f)));
                
                data = nanmean(data_sub.powspctrm(:,:,x3,x1:x2),4);
                
                [rho,p]     = corr(data,rt_all{sb} , 'type', 'Spearman');
                
                rho_mask    = p < 0.05 ;
                
                rhoM        = rho .* rho_mask ;
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
                
                
                allsuj{sb,cnd_bsl,1}.powspctrm(:,f,t)   = rhoF  ;
                allsuj{sb,cnd_bsl,2}.powspctrm(:,f,t)   = rhoMF ;
                allsuj{sb,cnd_bsl,3}.powspctrm(:,f,t)   = zeros(length(data_sub.label),1) ;
                
                clear x1 x2 x3 rho*
                
            end
            
        end
        
        for cnd_rho = 1:3
            
            allsuj{sb,cnd_bsl,cnd_rho}.dimord       = 'chan_freq_time';
            allsuj{sb,cnd_bsl,cnd_rho}.freq         = frq_list;
            allsuj{sb,cnd_bsl,cnd_rho}.time         = tm_list;
            allsuj{sb,cnd_bsl,cnd_rho}.label        = data_sub.label ;
            
        end
        
        clear data_sub
        
    end
    
    fprintf('Done\n');
    
    clear big_data
    
end

clearvars -except allsuj*;

list_bsl = {'corr','ncorr'};

Summary = [] ;
ha      = 0 ;

for cnd_bsl = 1:2   
    for f = 1:length(allsuj{1,1,1}.freq)
        for chn = 1:length(allsuj{1,1,1}.label)
            
            x = []; y = [];
            
            for sb = 1:14
                x = [x;allsuj{sb,cnd_bsl,1}.powspctrm(chn,f)];
                y = [y;allsuj{sb,cnd_bsl,3}.powspctrm(chn,f)];
            end
            
            p = permutation_test([x y],1000);
            
            if p < 0.05
                ha = ha + 1;
                Summary(ha).bsl = list_bsl{cnd_bsl};
                Summary(ha).freq = allsuj{1,1,1}.freq(f);
                Summary(ha).chan = allsuj{1,1,1}.label(chn);
                Summary(ha).p = p;
                Summary(ha).data = [x y];
                
            end
        end
    end
end