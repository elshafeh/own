clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = [project_dir 'data/' subjectName '/decode/'];
    
    list_cond                           = {'iscorrect','ismatch'};
    
    for n_con = 1:length(list_cond)
        
        fname                           = [dir_data subjectName '.decodeRep.' list_cond{n_con} '.dwn100.all.auc.mat'];
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        avg                             = [];
        avg.label                       = {'auc'};
        avg.dimord                      = 'chan_time';
        avg.time                        = time_axis;
        avg.avg                         = scores; clear scores;
        alldata{nsuj,n_con}         	= avg; clear avg;
        
    end
    
    alldata{nsuj,3}                     = alldata{nsuj,1};
    vct                                 = alldata{nsuj,3}.avg;
    
    for xi = 1:size(vct,1)
        for yi = 1:size(vct,2)
            
            ln_rnd                      = [0.49:0.001:0.51];
            rnd_nb                      = randi(length(ln_rnd));
            vct(xi,yi)                  = ln_rnd(rnd_nb);
            
        end
    end
    
    alldata{nsuj,3}.avg                 = vct; clear vct;
    
end

keep alldata list_*

list_color                              = 'bbr';
list_cond{end+1}                        = 'chance';
list_test                               = [1 3; 2 3];

for nt = 1:size(list_test,1)
    
    cfg                                 = [];
    cfg.statistic                       = 'ft_statfun_depsamplesT';
    cfg.method                          = 'montecarlo';
    cfg.correctm                        = 'cluster';
    cfg.clusteralpha                    = 0.05;
    
%     cfg.latency                         = [-0.1 7];
    
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
    stat{nt}                            = rmfield(stat{nt},'negdistribution');
    stat{nt}                            = rmfield(stat{nt},'posdistribution');
    stat{nt}                            = rmfield(stat{nt},'cfg');
    
end

i                                       = 0;
nrow                                    = 2;
ncol                                    = 2;
z_limit                                 = [0.49 0.6];
plimit                                  = 0.05;

list_plot                               = [1 2 3 4 5 6];%[1 4 2 5 3 6];

for nt = 1:length(stat)
    
    stat{nt}.mask                       = stat{nt}.prob < plimit;
    
    for nchan = 1:length(stat{nt}.label)
        
        tmp                             = stat{nt}.mask(nchan,:,:) .* stat{nt}.prob(nchan,:,:);
        ix                              = unique(tmp);
        ix                              = ix(ix~=0);
        
        if ~isempty(ix)
            
            i = i +1;
            subplot(nrow,ncol,list_plot(i))
            
            cfg                         = [];
            cfg.channel                 = stat{nt}.label{nchan};
            cfg.p_threshold             = plimit;
            cfg.z_limit                 = z_limit;
            cfg.time_limit              = stat{nt}.time([1 end]);
            
            ix1                         = list_test(nt,1);
            ix2                         = list_test(nt,2);
            
            cfg.color                   = list_color([ix1 ix2]);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,[ix1 ix2])));
            
            %             legend({list_cond{ix1},'',list_cond{ix2},''});
            
            title([list_cond{ix1}  ' p = ' num2str(round(min(ix),4))]);
            set(gca,'FontSize',16,'FontName', 'Calibri');
            
            vline([0 1.5 3 4.5],'--k');
            xticks([0 1.5 3 4.5]);
            
            ylabel('accuracy');
            xlabel('time');
            
            i = i +1;
            subplot(nrow,ncol,list_plot(i));
            plot_vct        = -log(tmp);
            plot_vct(isinf(plot_vct)) = 0;
            plot(stat{nt}.time,plot_vct,'-k','LineWidth',2);
            
            xlim([cfg.time_limit]);
            
            hline(-log(0.05),'--k');%,'p=0.05');
            ylabel('-log10 p values');
            
        end
    end
end