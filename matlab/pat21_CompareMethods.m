clear ; clc ;

lst_mat = {'1t20Hz.m3000p3000..mat', ...
    'NewEvoked.1t20Hz.m3000p3000.mat'};

for cnd = 1:length(lst_mat);
    figure;
    for cue = 1:3
        for sb = 1:14
            
            suj_list    = [1:4 8:17];
            suj         = ['yc' num2str(suj_list(sb))];
            lst_cue = 'RLN';
            
            load(['../data/tfr/' suj '.' lst_cue(cue) 'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.all.wav.'  lst_mat{cnd}]);
            
            if isfield(freq,'hidden_trialinfo')
                freq    = rmfield(freq,'hidden_trialinfo');
            end
            
            nw_chn  = [3 5; 4 6];
            nw_lst  = {'aud.L','aud.R'};
            
            for l = 1:size(nw_chn,1)
                cfg             = [];
                cfg.channel     = nw_chn(l,:);
                cfg.avgoverchan = 'yes';
                nwfrq{l}        = ft_selectdata(cfg,freq);
                nwfrq{l}.label  = nw_lst(l);
            end
            
            cfg             = [];
            cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
            freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
            
            tmp{sb}  = freq; clear freq ;
            
        end
        
        gavg{cue}           = ft_freqgrandaverage([],tmp{:}); clear tmp ;
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        gavg{cue}           = ft_freqbaseline(cfg,gavg{cue} );
        cfg                 = [];
        cfg.frequency       = [8 11];
        cfg.avgoverfreq     = 'yes';
        gavg{cue}           = ft_selectdata(cfg,gavg{cue} );
        toPlot(cue,:,:)     = gavg{cue}.powspctrm;
        
    end
    
    for chn = 1:2
        subplot(1,2,chn);
        plot(gavg{1}.time,squeeze(toPlot(:,chn,:)),'LineWidth',5);
        xlim([-0.2 2]);
        ylim([-0.5 0.5]);
        legend({'R','L','N'});
        title(gavg{1}.label{chn});
    end
    
    clear toPlot gavg
end