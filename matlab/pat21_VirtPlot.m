clear ; clc ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   '.AudFrontal4Alpha.VirtTimeCourse.all.wav.NewEvoked.1t20Hz.m3000p3000.mat';
    lst         =   {'DIS','fDIS'};
    
    lcue        = 'NLR';
    
    for cue = 1:3
        for delay = 1:3
            for cnd_dis = 1:2
                fname_in    = ['../data/tfr/' suj '.'  lcue(cue) lst{cnd_dis} num2str(delay) ext];
                fprintf('\nLoading %50s \n',fname_in);
                load(fname_in)
                
                if isfield(freq,'hidden_trialinfo');
                    freq = rmfield(freq,'hidden_trialinfo');
                end
                
                tfdis{cnd_dis} = freq; clear freq ;
                
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'powspctrm';
            cfg.operation                       = 'subtract';
            allsujGA{sb,cue,delay}              = ft_math(cfg,tfdis{1},tfdis{2}); clear tf_dis ;
            
            cfg                                 = [];
            cfg.baseline                        = [-0.4 -0.2];
            cfg.baselinetype                    = 'absolute';
            allsujGA{sb,cue,delay}              = ft_freqbaseline(cfg,allsujGA{sb,cue,delay});
            
        end
    end
end

clearvars -except allsujGA

for cue = 1:3
    for delay = 1:3
        gavg{cue,delay} = ft_freqgrandaverage([],allsujGA{:,cue,delay});
    end
end

for cue = 1:3
    for delay = 1:3
        cfg                 = [];
        cfg.channel         = 2;
        cfg.frequency       = [7 9];
        cfg.avgoverfreq     = 'yes';
        slct{cue,delay}     = ft_selectdata(cfg,gavg{cue,delay});
    end
end
figure;
for delay = 1:3
    subplot(1,3,delay)
    hold on
    for cue = 1:3
        plot(slct{cue,delay}.time,squeeze(slct{cue,delay}.powspctrm(:,:,:)));
        xlim([-2 1]);
    end
    legend({['N' num2str(delay)],['L' num2str(delay)],['R' num2str(delay)]})
end

lcue = 'NLR';
figure;
for cue = 1:3
    subplot(1,3,cue)
    for delay = 1:3
        hold on
        plot(slct{cue,delay}.time,squeeze(slct{cue,delay}.powspctrm(:,:,:)));
        xlim([-2 1]);
    end
    legend({[lcue(cue) '1'],[lcue(cue) '2'],[lcue(cue) '3']})
end