clear ; clc ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'CnD.MaxAudVizMotor.' ext_mat '.VirtTimeCourse'];
        fname_in    =   ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.'  ext1 '.all.wav.NewEvoked.1t20Hz.m3000p3000.mat'];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        if isfield(freq,'hidden_trialinfo')
            freq    = rmfield(freq,'hidden_trialinfo');
        end
        
        nw_chn  = [1 1;2 2; 3 5; 4 6];
        nw_lst  = {'Left Occipital','Right Occipital','Left Auditory','Right Auditory'};
        
        for l = 1:size(nw_chn,1)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';cfg.appenddim   = 'chan';
        freq                = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        cfg                 = [];
        cfg.frequency       = [7 15];
        cfg.avgoverfreq     = 'yes';
        fslct{sb,cnd}       = ft_selectdata(cfg,freq);
        
        clear freq
        
    end
end

clearvars -except fslct

for cnd = 1:size(fslct,2)
    gavg2plot{cnd}  = ft_freqgrandaverage([],fslct{:,cnd});
end

for chn = 1:length(gavg2plot{1}.label)
    
    subplot(2,2,chn)
    hold on
    rectangle('Position',[0.6 -0.3 0.5 0.6],'FaceColor',[0.9 0.9 0.9]);
    
    for cnd = 1:3
        
        plot(gavg2plot{cnd}.time,squeeze(gavg2plot{cnd}.powspctrm(chn,:,:)),'LineWidth',2)
        xlim([-0.2 2]);ylim([-0.3 0.3]);
        vline(0,'--k');vline(1.2,'--k');hline(0,'-k');
        xlabel('Time (ms)'); 
        ylabel('Relative Change 7-15 Hz');
    end
    
    legend({'Right Cue','Left Cue','UnInf Cue'});
    title([gavg2plot{1}.label{chn} ' ROI'])
    
end
