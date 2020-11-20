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
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
        freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
                
        cfg                 = [];
        cfg.frequency       = [7 15];
        cfg.latency         = [0.6 1.1];
        %         cfg.avgovertime     = 'yes';
        fslct               = ft_selectdata(cfg,freq);
        
        toplot(sb,cnd,:,:)  = fslct.powspctrm;
        
    end
end

figure;
for chn = 1:length(fslct.label)
    subplot(2,2,chn)
    data    = squeeze(toplot(:,:,chn,:));
    data    = squeeze(mean(data,1));
    plot([7:15]',data,'LineWidth',3);xlim([7 15]);ylim([-0.2 0.2]);
    legend({'R','L','N'},'Location','southeast')
    ylim([-0.25 0.25])
    title(fslct.label{chn})
end


figure;
for chn = 1:length(fslct.label)
    subplot(2,2,chn)
    data        = squeeze(toplot(:,:,chn,:));
    data        = squeeze(mean(data,3));
    pow         = mean(data,1);
    sem         = std(data,1)/sqrt(14);
    
    for cnd = 1:3
        errorbar(pow,sem,'b','LineWidth',2)
    end
    title(fslct.label{chn})
    set(gca,'Xtick',0:4,'XTickLabel', {'','RCue','LCue','NCue',''})
    ylim([-0.2 0.2])
    clear data pow sem
end