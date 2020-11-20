clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [0 1];
    list_cond                       = {'0back','1back'};
    list_color                      = 'km';
    
    list_cond                       = list_cond(list_nback+1);
    list_color                      = list_color(list_nback+1);
    
    for nback = 1:length(list_nback)
        
        list_lock                   = {'all'};
        avg_data                    = [];
        i                           = 0;
        
        for nlock = 1:length(list_lock)
            
            fname                   = ['J:/temp/nback/data/sens_level_auc/cond/sub'  num2str(suj_list(nsuj)) '.sess' num2str(nback) '.decoding.' ...
                num2str(list_nback(nback)) 'back.lockedon.' list_lock{nlock} '.dwn70.bsl.excl.auc.mat'];
            
            fprintf('loading %s\n',fname);
            
            load(fname);
            avg_data(nlock,:)       = scores; clear scores;
            
        end
        
        avg                       	= [];
        avg.time               		= time_axis;
        avg.label                   = list_lock;
        avg.avg                   	= avg_data; clear avg_data;
        avg.dimord              	= 'chan_time';
        
        alldata{nsuj,nback}      	= avg; clear avg pow;
        
    end
end

keep alldata list_*

list_cond                           = {'decoding 0and2','decoding 1and2'};

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

list_test                           = [1 2];

for nt = 1:size(list_test,1)
    stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]        	= h_pValSort(stat{ns});
    stat{ns}                        = rmfield(stat{ns},'negdistribution');
    stat{ns}                        = rmfield(stat{ns},'posdistribution');
    stat{ns}                        = rmfield(stat{ns},'cfg');
end

save('../data/stat/nback.cond.per.stim.mat','stat','list_test');

i                                  	= 0;
nrow                                = 5;
ncol                                = 1;
z_limit                             = [0.49 0.65];
plimit                              = 0.1;

for ns = 1:length(stat)
    
    stat{ns}.mask                   = stat{ns}.prob < plimit;
    
    for nchan = 1:length(stat{ns}.label)
        
        tmp                         = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        if ~isempty(ix)
            
            
            subplot(nrow,ncol,1:nrow-2)
            
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
            
            nme_chan                = strsplit(stat{ns}.label{nchan},'.');
            
            if length(nme_chan) > 1
                nme_chan            = [nme_chan{1} ' ' nme_chan{end}];
            else
                nme_chan            = nme_chan{1};
            end
            
            %nme_chan 
            
            title('');%['p = ' num2str(round(min(ix),4))]);
            set(gca,'FontSize',16,'FontName', 'Calibri');
            vline(0,'--k');
            ylabel('accuracy');
            xlabel('time');
            
            subplot(nrow,ncol,nrow);
            plot_vct        = -log(tmp);
            plot_vct(isinf(plot_vct)) = 0;
            plot(stat{ns}.time,plot_vct,'-k','LineWidth',2);
            
            xlim([cfg.time_limit]);
            
            hline(-log(0.05),'--k','p=0.05');
            ylabel('-log10 p values');
            
        end
    end
end