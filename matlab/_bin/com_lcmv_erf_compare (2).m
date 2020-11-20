clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                    = [1:4 8:17] ;
data_list                                   = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        dir_data                            = '../data/erf/';
        fname_in                            = [dir_data suj '.left.brain.slct.lp.' data_list{ndata} '.erf.mat'];
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        
        avg.avg                             = abs(avg.avg);
        
        lm1                                 = find(round(avg.time,2) == -0.1);
        lm2                                 = find(round(avg.time,2) == 0);
        bsl                                 = mean(avg.avg(:,lm1:lm2),2);
        avg.avg                             = (avg.avg - bsl)./ bsl;
        
        alldata{nsuj,ndata}                 = avg; clear avg;
        
    end
    
end

keep alldata ;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [-0.2 1.5];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;
cfg.clusterstatistic                        = 'maxsum';
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

cfg.channel                                 = [53:144 158:179];

cfg.neighbours                              = neighbours;
cfg.design                                  = design;

stat                                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p,p_val]                               = h_pValSort(stat);

i                                           = 0;
plimit                                      = 0.1;

for n_con = 1:length(stat)
    
    stat.mask                               = stat.prob < plimit;
    stat2plot                               = h_plotStat(stat,10e-13,plimit,'stat');
    
    for nchan = 1:length(stat.label)
        
        tmp                                 = stat.mask(nchan,:,:) .* stat.stat(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                               = i + 1;
            
            subplot(2,2,i)
            hold on;
            
            cfg                             = [];
            cfg.channel                     = stat.label{nchan};
            cfg.p_threshold               	= plimit;
            cfg.time_limit               	= stat.time([1 end]);
            cfg.color                      	= 'br';
            h_plotSingleERFstat_selectChannel(cfg,stat,alldata);
            
            nme                             = strsplit(stat.label{nchan},',');
            nme                             = nme{2};
            
            title(upper(nme));
            set(gca,'FontSize',8,'FontName', 'Calibri');
            vline(0,'--k'); vline(1.2,'--k');
            
        end
    end
end


%             for ndata = 1:2
%                 cfg                         = [];
%                 cfg.label                   = nchan;
%                 cfg.color                   = 'br';
%                 cfg.color                   = cfg.color(ndata);
%                 cfg.plot_single             = 'no';
%                 cfg.vline                   = [0 1.2];
%                 cfg.xlim                    = [-0.1 2];
%                 h_plot_erf(cfg,alldata(:,ndata));
%             end