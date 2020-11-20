clear ; clc ;

for sb = 1:14
    
    cnd_list = {'DIS'};
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    ext_essai   = 'Virt';
    fname_in    = ['../data/pe/' suj '.' cnd_list{:} '.' ext_essai 'TimeCourse.mat'];
    fprintf('Loading %50s\n',fname_in);
    load(fname_in);
    
    cfg                 = [];
    cfg.toilim          = [0.1 0.6];
    poi                 = ft_selectdata(cfg, virtsens);
    
    %     cfg         = [];
    %     cfg.order   = 5;
    %     cfg.toolbox = 'bsmart';
    %     mpoi        = ft_mvaranalysis(cfg, poi);
    %
    %     cfg        = [];
    %     cfg.method = 'mvar';
    %     mfreq      = ft_freqanalysis(cfg, mpoi);

    cfg                 = [];
    cfg.output          = 'fourier';
    cfg.method          = 'mtmfft';
    cfg.tapsmofrq       = 2;
    freq                = ft_freqanalysis(cfg, poi);
    
    cfg                 = [];
    cfg.method          = 'granger';
    grang               = ft_connectivityanalysis(cfg, freq);

    grangtoplot(sb,:,:,:) = grang.grangspctrm ;
    
end

grangavg = squeeze(mean(grangtoplot,1));

tmp                 = grang ;
tmp.cohspctrm       = grangavg;

cfg           = [];
cfg.parameter = 'grangspctrm';
cfg.xlim      = [5 45];
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, tmp);



%         der           =   15 ;
%         %         cfg.toolbox         =   'bsmart';
%         %         poi                 =   ft_mvaranalysis(cfg,virtsens);
%         %
%         %         cfg                 = [];
%         %         cfg.method          = 'mvar';
%         %         freq                = ft_freqanalysis(cfg, poi);
%         %
%         %         cfg                             = [];
%         %         cfg.method                      = 'granger';
%         %         coh_measures{sb,ix_t,3}         = ft_connectivityanalysis(cfg, freq);
%         %         coh_measures{sb,ix_t,3}         = rmfield(coh_measures{sb,ix_t,3},'cfg');
%         %
%         %         clear poi freq
%         %
%         %     end
%         %
%         %     clear virtsens
%         %
%         % end
%
%         load ../data/yctot/stat/granger_primer.mat
%
%         clearvars -except coh_measures
%
%         % ttest
%
%         ii = 0 ;
%
%         for chan1 = 1:length(coh_measures{1,1,1}.label)
%             for chan2 = 1:length(coh_measures{1,1}.label)
%                 if chan1 ~= chan2
%                     ii = ii + 1;
%                     tmp = [chan1 chan2];
%                     tmp = sort(tmp);
%                     chn_list{ii} =[num2str(tmp(1)) '.' num2str(tmp(2))];
%                     clear tmp
%                 end
%             end
%         end
%
%         chn_list = unique(chn_list);
%
%         chan1_list = [];
%         chan2_list = [];
%
%
%         for ii = 1:length(chn_list)
%
%             dotdot = strfind(chn_list{ii},'.');
%
%             chan1_list(end+1) = str2num(chn_list{ii}(1:dotdot-1));
%             chan2_list(end+1) = str2num(chn_list{ii}(dotdot+1:end));
%
%         end
%
%         clearvars -except coh_measures chn_list chan*
%
%         ntest_tot = 0 ;
%
%         for ix_coh = 1
%             for ix_t   = 2:3
%                 for frq = 4:9
%                     for c_c = 1:length(chan1_list)
%                         ntest_tot = ntest_tot + 1;
%                     end
%                 end
%             end
%         end
%
%         clearvars -except coh_measures chn_list chan* ntest_tot
%
%         ntest = 0 ;
%         p_bag = 0 ;
%
%         for ix_coh = 1
%
%             for ix_t   = 2:3
%
%                 tmp = coh_measures{1,1,ix_coh}.grangerspctrm;
%
%                 tres{ix_coh,ix_t-1}                 = coh_measures{1,1,ix_coh} ;
%                 tres{ix_coh,ix_t-1}.grangerspctrm   = tmp;
%
%                 for frq = 4:9
%
%                     for c_c = 1:length(chan1_list)
%
%                         for sb = 1:size(coh_measures,1)
%
%                             x(sb) = coh_measures{sb,ix_t,ix_coh}.grangerspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
%                             y(sb) = coh_measures{sb,1,ix_coh}.grangerspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
%
%                         end
%
%                         p           = permutation_test([x' y'],1000);
%                         direction   = (nanmean(x) - nanmean(y));
%
%                         if direction < 0
%                             p = p * -1 ;
%                         end
%
%                         ntest       = ntest + 1;
%
%                         p_bag(ntest) = p ;
%
%                         fprintf('Computing test %6d out of %6d\n',ntest,ntest_tot);
%
%                         tres{ix_coh,ix_t-1}.grangerspctrm(chan1_list(c_c),chan2_list(c_c),frq) = p ;
%
%
%                     end
%
%                 end
%
%             end
%
%         end
%
%         clearvars -except tres coh_measures ntest p_bag
%
%         % meas_list = {'plv','coherence','coherency'};
%         meas_list = {'granger_freq','granger_mvar5','granger_mvar15'};
%         time_list = {'early','late'};
%         chan_list = tres{1,1}.label ;
%         freq_list = [0 0 0 tres{1,1}.freq(4:9)];
%
%         ix_s = 0 ;
%
%         Summary = [];
%
%         for ix_coh = 1
%             for ix_t = 1:2
%
%                 for frq = 4:9
%
%                     for chan1 = 1:length(tres{1,1,1}.label)
%
%                         for chan2 = 1:length(tres{1,1}.label)
%
%                             p           = tres{ix_coh,ix_t}.grangerspctrm(chan1,chan2,frq);
%                             abs_p       = abs(p);
%
%                             if abs_p < 0.0001 && abs_p > 0
%
%                                 ix_s = ix_s + 1;
%
%                                 Summary(ix_s).measure   = meas_list{ix_coh};
%                                 Summary(ix_s).freq      = freq_list(frq);
%                                 Summary(ix_s).time      = time_list(ix_t);
%                                 Summary(ix_s).chan1     = chan_list{chan1};
%                                 Summary(ix_s).chan2     = chan_list{chan2};
%                                 Summary(ix_s).p         = abs_p ;
%
%                                 if p < 1
%                                     Summary(ix_s).direction = '+ve';
%                                 else
%                                     Summary(ix_s).direction = '-ve';
%                                 end
%
%                             end
%
%                         end
%                     end
%                 end
%             end
%         end
%
%         clearvars -except tres coh_measures Summary
%
%     clear poi freq
%
%     cfg                 =   [];
%     cfg.order           =   5 ;
%     cfg.toolbox         =   'bsmart';
%     poi                 =   ft_mvaranalysis(cfg,virtsens);
%
%     cfg                 = [];
%     cfg.method          = 'mvar';
%     freq                = ft_freqanalysis(cfg, poi);
%
%     cfg                             = [];
%     cfg.method                      = 'granger';
%     coh_measures{sb,ix_t,2}         = ft_connectivityanalysis(cfg, freq);
%     coh_measures{sb,ix_t,2}         = rmfield(coh_measures{sb,ix_t,2},'cfg');
%
%     cfg                 =   [];
%     cfg.or