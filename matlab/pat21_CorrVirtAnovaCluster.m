clear ; clc ;  dleiftrip_addpath ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    %     fname = ['../data/' suj '/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'];
    
    fname = ['../data/' suj '/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.conv.5t18Hz.m4p4.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                         = [];
    cfg.baseline                = [-0.6 -0.2];
    cfg.baselinetype            = 'relchange';
    freq                        = ft_freqbaseline(cfg,freq);
        
    cfg                         = [];
    cfg.channel                 = 1:10;
    cfg.latency                 = [0.9 1.1];
    cfg.avgovertime             = 'yes';
    cfg.frequency               = [7 15];
    freq                        = ft_selectdata(cfg,freq);

    fprintf('Calculating Correlation\n');
    
    for cnd = 1:3
        
        load  ../data/yctot/rt/rt_cond_classified.mat
        
        cfg         = [];
        cfg.trials  = rt_indx{sb,cnd};
        data_sub    = ft_selectdata(cfg,freq) ; 
        
        for t = 1:length(data_sub.time)
            
            for f = 1:length(data_sub.freq)
                
                data        = squeeze(data_sub.powspctrm(:,:,f,t));
                [rho,p]     = corr(data,rt_classified{sb,cnd} , 'type', 'Spearman');
                
                rho_mask    = p < 0.05 ;
                
                rhoM        = rho .* rho_mask ;
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
                
                allsuj{sb,cnd}.powspctrm(:,f,t)   = rhoF ;
            end
            
        end
        
        allsuj{sb,cnd}.dimord       = 'chan_freq_time';
        allsuj{sb,cnd}.freq         = data_sub.freq;
        allsuj{sb,cnd}.time         = 0.9;
        allsuj{sb,cnd}.label        = data_sub.label ;
        
        clear data_sub
    end
    
    fprintf('Done\n');
    
    clear freq
    
end

clearvars -except allsuj*; 

neighbours = [];

for a = 1:size(allsuj,1)
    for b = 1:size(allsuj,2)
        for c = 1:size(allsuj,3)
            if size(allsuj{a,b,c}.powspctrm,1) ~= 10
                fprintf('fuck!\n');
            end
        end
    end
end

for n = 1:length(allsuj{1,1}.label)
    neighbours(n).label = allsuj{1,1}.label{n};
    neighbours(n).neighblabel = [];
end