clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [0 1 2];
    list_cond                       = {'0Bv1B','0Bv2B','1Bv2B'};
    list_color                      = 'rgb';
    
    list_cond                       = list_cond(list_nback+1);
    list_color                      = list_color(list_nback+1);
    
    for ncond = 1:length(list_nback)
        
        list_lock                   = {'all.dwn70' 'nonrand.dwn70' 'target.dwn70' 'first.dwn70'};
        avg_data                    = [];
        i                           = 0;
        
        for nlock = 1:length(list_lock)
            
            file_list             	= dir(['J:/temp/nback/data/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' list_cond{ncond} ...
                '.' list_lock{nlock} '.bsl.excl.auc.mat']);
            
            tmp                     = [];
            
            for nf = 1:length(file_list)
                fname               = [file_list(nf).folder filesep file_list(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp                 = [tmp;scores]; clear scores;
            end
            
            avg_data(nlock,:)       = tmp; clear tmp;
            
        end
        
        avg                       	= [];
        avg.time               		= time_axis;
        avg.label                   = list_lock;
        avg.avg                   	= avg_data; clear avg_data;
        avg.dimord              	= 'chan_time';
        
        alldata{nsuj,ncond}      	= avg; clear avg pow;
        
    end
    
    alldata{nsuj,4}                	= alldata{nsuj,1};
    
    vct                             = alldata{nsuj,4}.avg;
    for xi = 1:size(vct,1)
        for yi = 1:size(vct,2)
            
            ln_rnd                  = [0.49:0.001:0.51];
            rnd_nb                  = randi(length(ln_rnd));
            vct(xi,yi)              = ln_rnd(rnd_nb);
            
        end
    end
    
    alldata{nsuj,4}.avg             = vct; clear vct;
    
end

keep alldata list_*

list_cond                           = {'0Bv1B','0Bv2B','1Bv2B','chance'};
list_color                          = 'rgbk';

list_test                           = [1 2; 1 3; 2 3]; %1 4; 2 4; 3 4;

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
    
    
    stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    list_test_name{nt}              = [list_cond{list_test(nt,1)} ' v ' list_cond{list_test(nt,2)}];
end

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]        	= h_pValSort(stat{ns});
end

save('../data/stat/nback.condition.2by2.mat','stat','list_test');

i                                  	= 0;
nrow                                = 3;
ncol                                = 3;
z_limit                             = [0.48 0.8];
plimit                              = 0.05;

for ns = 1:length(stat)
    
    stat{ns}.mask                   = stat{ns}.prob < plimit;
    
    for nchan = 1:length(stat{ns}.label)
        
        tmp                         = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
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
            
            nme_chan                = strsplit(stat{ns}.label{nchan},'.');
            
            if length(nme_chan) > 1
                nme_chan            = [nme_chan{1} ' ' nme_chan{end}];
            else
                nme_chan            = nme_chan{1};
            end
            
            %nme_chan
            
            ylim([z_limit]);
            yticks([z_limit]);
            xticks([0:0.4:2]);
            xlim([-0.1 2]);
            hline(0.5,'-k');vline(0,'-k');
            ax = gca();ax.TickDir  = 'out';box off;
            
            title(stat{ns}.label{nchan});
            
            %             subplot(nrow,ncol,nrow);
            %             plot_vct        = -log(tmp);
            %             plot_vct(isinf(plot_vct)) = 0;
            %             plot(stat{ns}.time,plot_vct,'-k','LineWidth',2);
            %
            %             xlim([cfg.time_limit]);
            %
            %             hline(-log(0.05),'--k','p=0.05');
            %             ylabel('-log10 p values');
            
        end
    end
end