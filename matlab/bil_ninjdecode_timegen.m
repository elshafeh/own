clear ; close all;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                 = suj_list{nsuj};
    list_feature                            	= {'gab.ori','gab.freq'};
    list_cond                                   = {'cue.pre.ori','cue.retro.ori','cue.pre.freq','cue.retro.freq'};
    
    for n_con = 1:length(list_cond)
        
        tmp                                     = [];
        
        for nfeat = 1:length(list_feature)
            
            ext_gab                             = 'first';
            ext_feature                         = list_feature{nfeat};
            fname                               = ['P:/3015079.01/data/' subjectName '/decode/' subjectName '.' ... 
                ext_gab 'gab.lock.' list_cond{n_con} '.' ...
                ext_feature '.correct.bsl.timegen.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(nfeat,:,:)                      = scores; clear scores;
            
        end
        
        freq                                  	= [];
        freq.dimord                          	= 'chan_freq_time';
        freq.label                            	= list_feature;
        freq.freq                              	= time_axis;
        freq.time                             	= time_axis;
        freq.powspctrm                         	= tmp; clear tmp;
        
        alldata{nsuj,n_con}                     = freq; clear pow ;
        
    end
end

keep alldata ns pow time_axis ext_lock list_* ext_gab

list_test                                       = [1 2; 1 3; 3 4; 2 3; 2 4; 3 4];
i                                               = 0;

for ntest = 1:size(list_test,1)
    
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    
    cfg.latency                                 = [-0.1 5];
    cfg.frequency                               = cfg.latency;
    
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
    
    for nchan = 1:length(alldata{1,1}.label)
        
        cfg.channel                             = nchan;
        i                                       = i + 1;
        stat{i}                                 = ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
        
        [min_p(i),p_val{i}]                     = h_pValSort(stat{i});
        
        if isfield(stat{i},'negdistribution')
            stat{i}                             = rmfield(stat{i},'negdistribution');
        end
        if isfield(stat{i},'posdistribution')
            stat{i}                             = rmfield(stat{i},'posdistribution');
        end
        
        list_test_name{i}                       = [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)} ' ' stat{i}.label{1}];
        
    end
end

i                                         	= 0;
nrow                                    	= 3;
ncol                                     	= 1;

plimit                                      = 0.11;

for ntest = 1:length(stat)
    for nchan = 1:length(stat{ntest}.label)
        
        stat{ntest}.mask                    = stat{ntest}.prob < plimit;
        
        tmp                               	= stat{ntest}.mask(nchan,:,:) .* stat{ntest}.prob(nchan,:,:);
        ix                                	= unique(tmp);
        ix                                	= ix(ix~=0);
        
        if ~isempty(ix)
            
            i                           	= i + 1;
            
            cfg                          	= [];
            cfg.colormap                	= brewermap(256, '*RdBu');
            cfg.channel                 	= nchan;
            cfg.parameter               	= 'stat';
            cfg.maskparameter             	= 'mask';
            cfg.maskstyle               	= 'outline';
            cfg.zlim                      	= [-5 5];
            cfg.colorbar                  	='yes';
            
            nme                           	= stat{ntest}.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,stat{ntest});
            
            title([list_test_name{ntest} ' p = ' num2str(round(min(ix),3))]);
            
            c = colorbar;
            c.Ticks = cfg.zlim;
            
            ylabel('Training Time');
            xlabel('Testing Time');
            
            if strcmp(ext_gab,'first')
                xticks([0 1.5 3]);
                yticks([0 1.5 3]);
                xticklabels({'1st gabor','2nd cue','2nd gabor'});
                yticklabels({'1st gabor','2nd cue','2nd gabor'});
                vline([0 1.5 3],'--k');
                hline([0 1.5 3],'--k');
            end
            
            set(gca,'FontSize',10,'FontName', 'Calibri','FontWeight','normal');
            
            
        end
    end
end