clear;close all;

suj_list                                = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    for nback = [0 1 2]
        
        name_center                     = 'beta.peak.centered';
        
        fname                           = ['J:/temp/nback/data/sens_level_auc/rt/sub' num2str(suj_list(nsuj)) '.decoding.rt.' ...
            num2str(nback) 'back.' name_center '.bsl.auc.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        avg                             = [];
        avg.time                        = time_axis;
        avg.label                       = {name_center};
        avg.avg                         = scores; clear scores;
        avg.dimord                      = 'chan_time';
        alldata{nsuj,nback+1}         	= avg; clear avg pow;
        
    end
    
    alldata{nsuj,4}                     = alldata{nsuj,3};
    vct                                 = alldata{nsuj,3}.avg;
    
    for xi = 1:size(vct,1)
        for yi = 1:size(vct,2)
            ln_rnd                      = [0.49:0.001:0.51];
            rnd_nb                      = randi(length(ln_rnd));
            vct(xi,yi)                  = ln_rnd(rnd_nb);
            
        end
    end
    
    alldata{nsuj,4}.avg                 = vct; clear vct;
    
end

keep alldata

list_cond                               = {'0back','1back','2Back','chance'};
list_color                          	= 'rgbk';

list_test                               = [1 4; 2 4; 3 4];

for nt = 1:size(list_test,1)
    
    cfg                                 = [];
    cfg.statistic                       = 'ft_statfun_depsamplesT';
    cfg.method                          = 'montecarlo';
    cfg.correctm                        = 'cluster';
    cfg.clusteralpha                    = 0.05;
    
    cfg.latency                         = [-0.1 2];
    
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
    
    
    stat{nt}                            = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    
    [min_p(nt),p_val{nt}]               = h_pValSort(stat{nt});
    if isfield(stat{nt},'negdistribution')
        stat{nt}                            = rmfield(stat{nt},'negdistribution');
    end
    if isfield(stat{nt},'posdistribution')
        stat{nt}                            = rmfield(stat{nt},'posdistribution');
    end
    
    stat{nt}                            = rmfield(stat{nt},'cfg');
    
end

save(['../data/stat/nback.rt.accuracy.' stat{1}.label{1} '.mat'],'stat','list_test','list_cond');

i                                       = 0;
nrow                                    = 2;
ncol                                    = 2;
z_limit                                 = [0.4 0.8];
plimit                                  = 0.05;

for nt = 1:length(stat)
    
    stat{nt}.mask                       = stat{nt}.prob < plimit;
    
    for nchan = 1:length(stat{nt}.label)
        
        tmp                             = stat{nt}.mask(nchan,:,:) .* stat{nt}.prob(nchan,:,:);
        ix                              = unique(tmp);
        ix                              = ix(ix~=0);
        
        %         if ~isempty(ix)
        
        i = i + 1;
        subplot(nrow,ncol,i)
        
        cfg                         = [];
        cfg.channel                 = stat{nt}.label{nchan};
        cfg.p_threshold             = plimit;
        cfg.z_limit                 = z_limit;
        cfg.time_limit              = stat{nt}.time([1 end]);
        
        ix1                         = list_test(nt,1);
        ix2                         = list_test(nt,2);
        
        cfg.color                   = list_color([ix1 ix2]);
        
        h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,[ix1 ix2])));
        
        legend({list_cond{ix1},'',list_cond{ix2},''});
        
        nme_chan                    = stat{nt}.label{nchan};
        
        %nme_chan
        
        ylim([z_limit]);
        yticks([z_limit]);
        xticks([0:0.4:2]);
        xlim([-0.1 2]);
        hline(0.5,'--k');vline(0,'--k');
        ax = gca();ax.TickDir  = 'out';box off;
        title(nme_chan);
        
        
        %         end
    end
end