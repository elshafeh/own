clear ; close all;

i                                  	= 0;
nrow                                = 4;
ncol                                = 1;

plimit                              = 0.1;

for ext_gab = {'first','second'}
    
    if isunix
        project_dir = '/project/3015079.01/';
    else
        project_dir = 'P:/3015079.01/';
    end
    
    load ../data/bil_goodsubjectlist.27feb20.mat
    
    for nsuj = 1:length(suj_list)
        
        subjectName                         = suj_list{nsuj};
        dir_data                            = [project_dir 'data/' subjectName '/decode/'];
        
        list_cond                           = {'cue.pre.ori','cue.retro.ori','cue.pre.freq','cue.retro.freq'};
        list_feature                        = {'gab.ori','gab.freq'};
        
        for n_con = 1:length(list_cond)
            
            tmp                           	= [];
            
            for nfeat = 1:length(list_feature)
                ext_feature               	= list_feature{nfeat};
                fname                    	= [dir_data subjectName '.' ext_gab{:} 'gab.lock.' list_cond{n_con} '.' ...
                    ext_feature '.correct.bsl.auc.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp(nfeat,:)                = scores; clear scores;
                
            end
            
            avg                             = [];
            avg.label                       = list_feature;
            avg.dimord                      = 'chan_time';
            avg.time                        = time_axis;
            avg.avg                         = tmp; clear tmp;
            alldata{nsuj,n_con}         	= avg; clear avg;
            
        end
        
    end
    
    list_color                          = 'rgbk';
    
    nbsuj                               = size(alldata,1);
    [~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg                                 = [];
    cfg.statistic                       = 'ft_statfun_depsamplesT';
    cfg.method                          = 'montecarlo';
    cfg.correctm                        = 'cluster';
    cfg.clusteralpha                    = 0.05;
    
    if strcmp(ext_gab{:},'first')
        cfg.latency                     = [-0.1 1];
    else
        cfg.latency                 	= [-0.1 1];
    end
    
    cfg.clusterstatistic                = 'maxsum';
    cfg.minnbchan                       = 0;
    cfg.tail                            = 0;
    cfg.clustertail                     = 0;
    cfg.alpha                           = 0.025;
    cfg.numrandomization                = 1000;
    cfg.uvar                            = 1;
    cfg.ivar                            = 2;
    
    nbsuj                               = size(alldata,1);
    [design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                          = design;
    cfg.neighbours                      = neighbours;
    
    
    list_test                           = [1 2; 1 3; 3 4; 2 3; 2 4; 3 4];
    
    for nt = 1:size(list_test,1)
        stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    end
    
    for ns = 1:length(stat)
        [min_p(ns),p_val{ns}]        	= h_pValSort(stat{ns});
        stat{ns}                        = rmfield(stat{ns},'cfg');
    end
    
    
    for ns = 1:length(stat)
        
        stat{ns}.mask                   = stat{ns}.prob < plimit;
        
        for nchan = 1:length(stat{ns}.label)
            
            tmp                         = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
            ix                          = unique(tmp);
            ix                          = ix(ix~=0);
            
            if nchan == 1
                z_limit             	= [0.47 0.6];
            else
                z_limit             	= [0.47 0.8];
            end
            
            if ~isempty(ix)
                
                i = i + 1;
                subplot(nrow,ncol,i)
                
                cfg                     = [];
                cfg.channel             = stat{ns}.label{nchan};
                cfg.p_threshold        	= plimit;
                
                
                cfg.z_limit             = z_limit;
                cfg.time_limit          = stat{ns}.time([1 end]);
                
                ix1                     = list_test(ns,1);
                ix2                     = list_test(ns,2);
                
                cfg.color            	= list_color([ix1 ix2]);
                
                h_plotSingleERFstat_selectChannel(cfg,stat{ns},squeeze(alldata(:,[ix1 ix2])));
                
                legend({list_cond{ix1},'',list_cond{ix2},''});
                ylim([z_limit]);
                yticks([z_limit]);
                xlim([cfg.time_limit]);
                hline(0.5,'--k');
                vline(0,'--k');
                ax = gca();ax.TickDir  = 'out';box off;
                
                xticks([0 0.5 1]);
                xticklabels({[ext_gab{:} ' gab onset'],'0.5','1'});
                
                title([ext_gab{:} ' ' stat{ns}.label{nchan}]);
                
                %             i = i +1;
                %             subplot(nrow,ncol,i);
                %             plot_vct        = -log(tmp);
                %             plot_vct(isinf(plot_vct)) = 0;
                %             plot(stat{ns}.time,plot_vct,'-k','LineWidth',2);
                %             xlim([cfg.time_limit]);
                %             hline(-log(0.05),'--k','p=0.05');
                %             ylabel('-log10 p values');
                
            end
        end
    end
    
end