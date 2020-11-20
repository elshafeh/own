clear ; close all;

suj_list    = [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    suj_name                                = ['sub' num2str(suj_list(ns))];
    
    for nback = [0 1 2]
        
        i                                   = 0;
        for nsess = 1:2
        
            fname                           = ['K:/nback/response/sub' num2str(suj_list(ns)) '.sess' num2str(nsess) '.' num2str(nback) 'back.dwn60.excl.match.auc.mat'];
            if exist(fname)
                i                         	= i +1;
                fprintf('Loading %s\n',fname);
                load(fname);
                
                tmp(i,:)                    = scores; clear scores;
            end
        end
        
        avg                              	= [];
        avg.dimord                          = 'chan_time';
        avg.label                           = {'auc'};
        avg.time                          	= time_axis;
        avg.avg                         	= squeeze(mean(tmp,1));
        
        alldata{ns,nback+1}               	= avg; clear avg pow ;
        
    end
end

keep alldata

keep alldata

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;

cfg.latency                                 = [-0.5 2];

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
    stat{nt}                                = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]                	= h_pValSort(stat{ns});
    stat{ns}                              	= rmfield(stat{ns},'negdistribution');
    stat{ns}                              	= rmfield(stat{ns},'posdistribution');
end

i                                           = 0;
nrow                                        = 2;
ncol                                        = 2;
z_limit                                     = [0.5 0.8];
plimit                                      = 0.3;

for ns = 1:length(stat) 
    
    stat{ns}.mask                           = stat{ns}.prob < plimit;
    
    for nchan = 1:length(stat{ns}.label)
        
        tmp                                 = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            nme                             = stat{ns}.label{nchan};
            
            cfg                             = [];
            cfg.channel                     = stat{ns}.label{nchan};
            cfg.p_threshold               	= plimit;
            
            list_color                      = 'rgb';
            cfg.z_limit                     = z_limit;
            cfg.time_limit                  = [-0.2 2];
            
            ix1                             = list_test(ns,1);
            ix2                             = list_test(ns,2);
            
            cfg.color                      	= list_color([ix1 ix2]);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{ns},squeeze(alldata(:,[ix1 ix2])));
            
            list_cond                       = {'0back','1back','2back'};
            
            legend({list_cond{ix1},'',list_cond{ix2},''});
            
            title([' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',16,'FontName', 'Calibri');
            
            %             hline(0.5,'--k');
            vline(0,'--k');
            
        end
    end
end