clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                              = [0 1 2];
    list_cond                               = {'0back','1back','2back'};
    list_color                              = 'rgb';
    
    list_cond                               = list_cond(list_nback+1);
    list_color                              = list_color(list_nback+1);
    list_freq                               = 1:30;
    
    for nback = 1:length(list_nback)
        
        list_lock                           = {'all'};
        list_sess_name                      = {'block','concat'};
        
        list_sess                           = {[1 2],[12]};
        
        pow                                 = [];
        
        for nfreq = 1:length(list_freq)
            i                             	= 0;
            
            for nlock = 1:length(list_lock)
                
                ext_lock                    = list_lock{nlock};
                
                for nlu = 1:2
                    
                    i                       = i+1;
                    tmp                     = [];
                    
                    for nses = list_sess{nlu}
                        file_list          	= dir(['P:/3015079.01/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess' num2str(nses) '.decoding.' ...
                            num2str(list_nback(nback)) 'back.' num2str(list_freq(nfreq)) 'Hz.lockedon.' ext_lock '.bsl.excl.auc.mat']);
                        
                        %                 file_list                       = dir(['J:/temp/nback/data/stim_per_cond_mtm/sub' num2str(suj_list(nsuj)) '.sess*.' ...
                        %                     num2str(list_nback(nback)) 'back.' num2str(list_freq(nfreq)) 'Hz.' list_lock{nlock} '.auc.mat']);
                        
                        for nf = 1:length(file_list)
                            fname         	= [file_list(nf).folder '\' file_list(nf).name];
                            fprintf('loading %s\n',fname);
                            load(fname);
                            tmp           	= [tmp;scores]; clear fname scores;
                        end
                    end
                    
                    pow(i,nfreq,:)       	= nanmean(tmp,1); clear tmp;
                    list_final{i}         	= [list_lock{nlock} ' ' list_sess_name{nlu}];
                    
                end
            end
        end
        
        freq                                = [];
        freq.time                           =  -1.5:0.02:2;
        freq.label                          = list_final;
        freq.freq                           = list_freq;
        freq.powspctrm                      = pow;
        freq.dimord                         = 'chan_freq_time';
        
        alldata{nsuj,nback}                 = freq; clear freq pow;
        
    end
end

keep alldata list_*;

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;
cfg.latency                                 = [-0.1 1.5];
cfg.frequency                               = [3 30];
cfg.clusterstatistic                        = 'maxsum';
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                                  = design;
cfg.neighbours                              = neighbours;

list_test                                   = [1 2; 1 3; 2 3];

for nt = 1:size(list_test,1)
    stat{nt}                                = ft_freqstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]           	= h_pValSort(stat{ntest});
    stat{ntest}                             = rmfield(stat{ntest},'negdistribution');
    stat{ntest}                             = rmfield(stat{ntest},'posdistribution');
end

figure;

i                                           = 0;
nrow                                        = 3;
ncol                                        = 4;

plimit                                      = 0.2;

for ntest = 1:length(stat)
    
    statplot                             	= stat{ntest};
    statplot.mask                           = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        iy                               	= unique(tmp);
        iy                                 	= iy(iy~=0);
        iy                                 	= iy(~isnan(iy));
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.stat(nchan,:,:);
        ix                               	= unique(tmp);
        ix                                 	= ix(ix~=0);
        ix                                 	= ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                             	= i + 1;
            
            cfg                            	= [];
            cfg.colormap                  	= brewermap(256, '*RdBu');
            cfg.channel                   	= nchan;
            cfg.parameter                  	= 'stat';%'prob';
            cfg.maskparameter            	= 'mask';
            cfg.maskstyle                  	= 'outline';
            cfg.zlim                      	= [-5 5];%[min(min_p) plimit];%
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = statplot.time([1 end]);
            nme                           	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            vline(0,'--k');
            
            list_condition                  = {'0 v 1','0 v 2','1 v 2'};%{'0 v 1 Back','0 v 2 Back','1 v 2 Back'};
            
            ylabel({[statplot.label{nchan} ' ' list_condition{ntest}], ['p = ' num2str(round(min(min(iy)),3))]});
            title('');
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            c.FontSize = 10;
            
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            avg_over_time                           = squeeze(nanmean(tmp,3));
            i                                       = i + 1;
            subplot(nrow,ncol,i)
            
            plot(statplot.freq,avg_over_time,'--k','LineWidth',2);
            xlim(statplot.freq([1 end]));
            xlabel('Frequency');
            grid on;
            set(gca,'FontSize',10,'FontName', 'Calibri');
            ylim([-1 1]);
            yticks([-1 1]);
            hline(0,'--k');
            
            %             i                                       = i + 1;
            %             subplot(nrow,ncol,i)
            %             avg_over_time                           = squeeze(nanmean(tmp,2));
            %             plot(statplot.time,avg_over_time,'--k','LineWidth',2);
            %             xlabel('Time');
            %             grid on;
            %             set(gca,'FontSize',10,'FontName', 'Calibri');
            %             xlim(statplot.time([1 end]));
            %             ylim([-2 2]);
            %             yticks([-2 2]);
            
            hline(0,'--k');
            vline(0,'--k');
        end
    end
    
    clear statplot
    
end