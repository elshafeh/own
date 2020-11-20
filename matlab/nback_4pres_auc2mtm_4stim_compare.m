clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [0 1 2];
    list_cond                       = {'0back','1back','2Back'};
    
    for nback = 1:length(list_nback)
        
        fname_in                    = ['J:/temp/nback/data/auc2mtm/sub' num2str(suj_list(nsuj)) '.' ...
            num2str(list_nback(nback)) 'back.dwn70.auc.mtm.mat'];
        fprintf('load %s\n',fname_in);
        load(fname_in);
        
        cfg                         = [];
        cfg.baseline                = [-0.4 -0.2];
        cfg.baselinetype            = 'absolute';
        freq                        = ft_freqbaseline(cfg,freq);
        
        alldata{nsuj,nback}         = freq; clear freq;
        
    end
end

keep alldata list_*

cfg                 = [];
cfg.statistic       = 'ft_statfun_depsamplesT';
cfg.method          = 'montecarlo';
cfg.correctm        = 'cluster';
cfg.clusteralpha    = 0.05;
cfg.channel         = 2;
cfg.latency         = [-0.1 1.5];
cfg.frequency       = [5 30];
cfg.clusterstatistic= 'maxsum';
cfg.minnbchan       = 0;
cfg.tail            = 0;
cfg.clustertail     = 0;
cfg.alpha           = 0.025;
cfg.numrandomization= 1000;
cfg.uvar            = 1;
cfg.ivar            = 2;

nbsuj               = size(alldata,1);
[design,neighbours] = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design          = design;
cfg.neighbours      = neighbours;

list_test           = [1 3; 2 3; 1 2];

for nt = 1:size(list_test,1)
    stat{nt}        = ft_freqstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    list_test_name{nt}          = [list_cond{list_test(nt,1)} ' v ' list_cond{list_test(nt,2)}];
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]	= h_pValSort(stat{ntest});
    stat{ntest}              	= rmfield(stat{ntest},'negdistribution');
    stat{ntest}              	= rmfield(stat{ntest},'posdistribution');
end

figure;

i                           = 0;
nrow                        = 2;
ncol                        = 2;

plimit                      = 0.1;

for ntest = 1:length(stat)
    
    statplot                    = stat{ntest};
    statplot.mask               = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                     = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        iy                      = unique(tmp);
        iy                   	= iy(iy~=0);
        iy                      = iy(~isnan(iy));
        
        tmp                     = statplot.mask(nchan,:,:) .* statplot.stat(nchan,:,:);
        ix                    	= unique(tmp);
        ix                   	= ix(ix~=0);
        ix                   	= ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                 	= i + 1;
            
            val                 = 3;
            
            cfg                	= [];
            cfg.colormap      	= brewermap(256, '*RdBu');
            cfg.channel        	= nchan;
            cfg.parameter      	= 'stat';
            cfg.maskparameter 	= 'mask';
            cfg.maskstyle     	= 'outline';
            cfg.zlim           	= [-5 5];
            cfg.ylim            = statplot.freq([1 end]);
            cfg.xlim            = [-0.2 2];
            cfg.colorbar        = 'no';
            nme              	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            vline(0,'--k');
            
            ylabel({[list_test_name{ntest}],[' p = ' num2str(round(min(min(iy)),3))]});
            title(statplot.label{nchan});
            
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            i                   = i + 1;
            subplot(nrow,ncol,i)
            
            plot(statplot.freq,avg_over_time,'k','LineWidth',2);
            xlabel('Frequency');
            grid on;
            set(gca,'FontSize',10,'FontName', 'Calibri');
            xlim(statplot.freq([1 end]));
            %             ylim([0 val]);
            %             yticks([0 val]);
            ylabel('t values');
            
        end
    end
    
end