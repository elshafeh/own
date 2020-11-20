clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj     = ['yc' num2str(suj_list(sb))];
    fname   = ['../data/' suj '.seymourPAC.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    for chn = 1:2
        for nmethod = 1:4
            for ntime = 1:2
                
                ix_surr = 1;
                
                grand_avg{sb,chn,nmethod,ntime}.powspctrm(1,:,:)    = squeeze(mpac(chn,nmethod,ntime,ix_surr,:,:));
                grand_avg{sb,chn,nmethod,ntime}.freq                = mpac_index.amp_freq_vec;
                grand_avg{sb,chn,nmethod,ntime}.time                = mpac_index.pha_freq_vec;
                grand_avg{sb,chn,nmethod,ntime}.label               = {'MI'};
                grand_avg{sb,chn,nmethod,ntime}.dimord              = 'chan_freq_time';
                
            end
            
            %             cfg                                         = [];
            %             cfg.operation                               = 'x1-x2';
            %             cfg.parameter                               = 'powspctrm';
            %             new_avg{sb,chn,nmethod,2}                   = ft_math(cfg,grand_avg{sb,chn,nmethod,2},grand_avg{sb,chn,nmethod,1});
            %             new_avg{sb,chn,nmethod,1}                   = new_avg{sb,chn,nmethod,2};
            %             new_avg{sb,chn,nmethod,1}.powspctrm(:,:,:)  = 0;
            
        end
    end 
end
    
% grand_avg = new_avg;

clearvars -except grand_avg mpac_index

cfg                     = [];
cfg.dim                 = grand_avg{1}.dimord;
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.parameter           = 'powspctrm';
cfg.correctm            = 'cluster';
cfg.computecritval      = 'yes';
cfg.numrandomization    = 1000;
cfg.alpha               = 0.025; 
cfg.tail                = 0;
nsubj                   = size(grand_avg,1);
cfg.design(1,:)         = [1:nsubj 1:nsubj];
cfg.design(2,:)         = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.uvar                = 1; 
cfg.ivar                = 2;

for chn = 1:2
    for nmethod = 1:4
        %         stat{chn,nmethod}          = ft_freqstatistics(cfg,grand_avg{:,chn,nmethod,2}, grand_avg{:,chn,nmethod,1});
        stat{chn,nmethod}          = ft_freqstatistics(cfg,grand_avg{:,chn,nmethod,2}, grand_avg{:,chn,nmethod,1});
        stat{chn,nmethod}.label    = {[mpac_index.channel{chn} ' ' mpac_index.method{nmethod}]};
    end
end

for chn = 1:2
    for nmethod = 1:4
        [min_p(chn,nmethod),p_val{chn,nmethod}] = h_pValSort(stat{chn,nmethod});
    end
end

i = 0 ;

for chn = 1:2
    for nmethod = 1:4
        
        i = i + 1;
        
        stat{chn,nmethod}.mask      = stat{chn,nmethod}.prob < 0.2;
        
        subplot(2,4,i)
        cfg                         = [];
        cfg.parameter               = 'stat';
        cfg.maskparameter           = 'mask';
        cfg.maskstyle               = 'outline';
        cfg.zlim                    = [-3 3];
        ft_singleplotTFR(cfg,stat{chn,nmethod});
        xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
        
    end
end