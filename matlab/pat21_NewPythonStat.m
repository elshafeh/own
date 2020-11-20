clear ; clc ; dleiftrip_addpath ;

for sb = 1:21
    
    suj          = ['yc' num2str(sb)];
    
    list_cues    = {'NLCnD','NRCnD','LCnD','RCnD'};
    list_meth    = {'HR','KLD','MVL','PhaSyn','ndPAC'};
    list_time    = {'m1000m200','p200p1000'};
    list_norm    = {'NoNorm'};
    list_chan    = {'audR'};
    
    for xcue = 1:length(list_cues)
        for xmeth = 1:length(list_meth)
            for xnorm = 1:length(list_norm)
                for xtime = 1:length(list_time)
                    
                    load(['../data/python_data/' suj '.' list_cues{xcue} '.' list_time{xtime} '.' list_meth{xmeth} '.ShuAmp' '.' list_norm{xnorm} '.100perm.mat'])
                    
                    %                     if ~strcmp(list_meth{xmeth},'ndPAC')
                    %                         py_pac.xpac(py_pac.pval>0.05)           = 0;
                    %                     end
                    
                    py_pac.xpac                             = squeeze(py_pac.xpac);
                    py_pac.xpac                             = squeeze(mean(py_pac.xpac,3));
                    py_pac.xpac                             = permute(py_pac.xpac,[3 1 2]);
                    
                    for xchan = 1:length(list_chan)
                        grand_avg{sb,xcue,xmeth,xnorm,xchan,xtime}.powspctrm(1,:,:)       = squeeze(py_pac.xpac(xchan,:,:));
                        grand_avg{sb,xcue,xmeth,xnorm,xchan,xtime}.freq                   = double(py_pac.vec_amp);
                        grand_avg{sb,xcue,xmeth,xnorm,xchan,xtime}.time                   = double(py_pac.vec_pha);
                        grand_avg{sb,xcue,xmeth,xnorm,xchan,xtime}.label                  = list_chan(xchan);
                        grand_avg{sb,xcue,xmeth,xnorm,xchan,xtime}.dimord                 = 'chan_freq_time';
                    end
                    
                    clear py_pac
                    
                end
            end
        end
    end
    
    clear x* suj
    
end

clearvars -except grand_avg list_*

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

ntotal                  = length(list_cues)*length(list_norm)*length(list_chan)*length(list_meth)*length(list_time);
i                       = 0;
h_wait                  = waitbar(0,'Testing PAC');

for xcue = 1:length(list_cues)
    for xmeth = 1:length(list_meth)
        for xnorm = 1:length(list_norm)
            for xchan = 1:length(list_chan)
                
                i = i + 1;
                waitbar(i/ntotal)
                
                stat{xcue,xmeth,xnorm,xchan}         = ft_freqstatistics(cfg,grand_avg{:,xcue,xmeth,xnorm,xchan,2}, grand_avg{:,xcue,xmeth,xnorm,xchan,1});
                
                stat{xcue,xmeth,xnorm,xchan}.label   = {[list_cues{xcue} '.' list_meth{xmeth} '.' list_norm{xnorm} '.' list_chan{xchan}]};
                
                stat{xcue,xmeth,xnorm,xchan}         = rmfield(stat{xcue,xmeth,xnorm,xchan},'cfg');
                
                [min_p(xcue,xmeth,xnorm,xchan),p_val{xcue,xmeth,xnorm,xchan}] = h_pValSort(stat{xcue,xmeth,xnorm,xchan});
                
            end
        end
    end
end

close(h_wait) ; clearvars -except grand_avg stat min_p p_val list_*

close all;

for xmeth = 1:length(list_meth)
    for xnorm = 1:length(list_norm)
        figure;
        i = 0 ;
        
        for xchan = 1:length(list_chan)
            for xcue = 1:length(list_cues)
                
                stat{xcue,xmeth,xnorm,xchan}.mask     = stat{xcue,xmeth,xnorm,xchan}.prob < 0.2;
                
                i = i + 1 ;
                
                subplot(length(list_cues),length(list_chan),i)
                
                cfg                             = [];
                cfg.parameter                   = 'stat';
                cfg.maskparameter               = 'mask';
                cfg.maskstyle                   = 'outline';
                cfg.zlim                        = [-5 5];
                ft_singleplotTFR(cfg,stat{xcue,xmeth,xnorm,xchan});
                title([stat{xcue,xmeth,xnorm,xchan}.label ' ' num2str(min_p(xcue,xmeth,xnorm,xchan))]);
                
                xlabel('Phase (Hz)');
                ylabel('Amplitude (Hz)');
                colormap('jet')
                
            end
        end
    end
end