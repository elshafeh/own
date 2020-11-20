clear ; clc ; 

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   '.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat' ;
    lst_delay   =   '123';
    lst_dis     =   {'DIS','fDIS'};
    
    for cnd_delay = 1:length(lst_delay)
        for cnd_dis = 1:2
            
            fname_in    = ['../data/tfr/' suj '.' lst_dis{cnd_dis} lst_delay(cnd_delay) ext1];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'hidden_trialinfo')
                freq        = rmfield(freq,'hidden_trialinfo');
            end
            
            cfg                         = [];
            cfg.channel                 = 2;
            tf_dis{cnd_dis}             = ft_selectdata(cfg,freq); clear freq ;
            
        end
        
        cfg                     = [];
        cfg.parameter           = 'powspctrm'; cfg.operation  = 'x1-x2';
        freq                    = ft_math(cfg,tf_dis{1},tf_dis{2});
        
        twin                    = 0.07;
        tlist                   = [0.1 0.4];
        ftap                    = 40;
        flist                   = 60;
        
        for chn = 1:length(freq.label)
            for f = 1:length(flist)
                for t = 1:length(tlist)
                    
                    lmt1 = find(round(freq.time,3) == round(tlist(t),3));
                    lmt2 = find(round(freq.time,3) == round(tlist(t)+twin,3));
                    
                    lmf1 = find(round(freq.freq) == round(flist(f)));
                    lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                    
                    data = squeeze(mean(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2))));
                    
                    data2permute(sb,cnd_delay,t) = data ; clear data ;
                    
                end
            end
        end
    end
end

clearvars -except data2permute

x = squeeze(data2permute(:,2,:));
y = squeeze(data2permute(:,3,:));

for t = 1:2
    p_val(t) = permutation_test([x(:,t) y(:,t)],10000);
end