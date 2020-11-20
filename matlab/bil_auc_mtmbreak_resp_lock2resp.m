clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat


for ns = 1:length(suj_list)
    
    subjectName                             = suj_list{ns};
    list_cond                               = {'button','correct','match'};
    
    time_width                              = 0.05;
    time_list                               = -4:time_width:1;
    freq_list                               = [1:1:30 32:2:40];
    
    for ncond = 1:length(list_cond)
        
        tmp                                     = [];
        for nfreq = 1:length(freq_list)
            
            fname                               = ['J:/temp/bil/resplock_mtm_auc/' subjectName '.resplock.decode.' list_cond{ncond} '.' ...
                num2str(freq_list(nfreq))  'Hz.auc.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            tmp(1,nfreq,:)                      = scores; clear scores;
        end
        
        
        freq                                    = [];
        freq.dimord                             = 'chan_freq_time';
        freq.label                              = {'auc'};
        freq.freq                               = freq_list;
        freq.time                               = time_list;
        freq.powspctrm                          = tmp ; clear tmp;
        alldata{ns,ncond}                       = freq; clear freq;
        
    end
    
    alldata{ns,ncond+1}                         = alldata{ns,ncond};
    alldata{ns,ncond+1}.powspctrm(:)            = 0.5;
    
    
end

keep alldata list_cond*

list_cond                                       = {'button','correct','match','chance'};

keep alldata list_*;
list_test                                       = [1 4; 2 4; 3 4];

for ntest = 1:size(list_test,1)
    
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    cfg.latency                                 = [-1.5 0.25];
    cfg.frequency                               = [1 30];
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
    
    stat{ntest}                              	= ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
    list_test_name{ntest}                     	= [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}];
    
    
    [min_p(ntest),p_val{ntest}]                 = h_pValSort(stat{ntest});
    stat{ntest}                                 = rmfield(stat{ntest},'negdistribution');
    stat{ntest}                                 = rmfield(stat{ntest},'posdistribution');
    
end

figure;

i                                               = 0;
nrow                                            = 3;
ncol                                            = 2;

plimit                                          = 0.05;
opac_lim                                        = 0.1;
z_lim                                           = 5;

list_y                                          = [0 4; 0 4; -1 1];

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
            cfg.parameter                  	= 'stat';
            cfg.maskparameter            	= 'mask';
            cfg.maskstyle                  	= 'outline';
            cfg.maskstyle                  	= 'opacity';
            cfg.maskalpha                   = opac_lim;
            
            cfg.zlim                      	= [-z_lim z_lim];%[10e-15 plimit]; %
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = statplot.time([1 end]);
            nme                           	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            
            %             xticks([0 0.2 0.4 0.8 1]);
            %             yticks([6 14 22 30]);
            
            %             ylabel({[list_test_name{ntest}],statplot.label{nchan},[' p = ' num2str(round(min(min(iy)),3))],'','Frequency'});
            xlabel('Time');
            ylabel({[list_test_name{ntest}], [' p = ' num2str(round(min(min(iy)),3))]});
            title('');
            
            c           = colorbar;
            c.Ticks     = cfg.zlim;
            c.FontSize  = 10;
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            vline([0],'--k');
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            avg_over_time(isnan(avg_over_time)) = 0;
            
            plot(statplot.freq,avg_over_time,'k','LineWidth',2);
            xlabel('Frequency');
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            xlim(statplot.freq([1 end]));
            %             ylim(list_y(ntest,:));
            %             yticks(list_y(ntest,:));
            
            hline(0,'-k');
            ylabel('t values');
            %             xticks([2 6 10 14 18 22 26 30]);
            
        end
    end
end