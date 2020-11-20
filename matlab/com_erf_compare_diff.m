clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                    = [1:4 8:17] ;
data_list                                   = {'meg','eeg'};
cond_list                                   = {'inf','unf'};

for nsuj = 1:length(suj_list)
    
    suj                                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        for ncon = 1:2
            
            dir_data                        = 'J:\temp\meeg\data\erf\';
            fname_in                        = [dir_data suj '.' cond_list{ncon} '.brain.slct.lp.' data_list{ndata} '.erf.mat'];
            fprintf('Loading %50s\n',fname_in);
            load(fname_in);
            
            avg.avg                         = abs(avg.avg);
            
            lm1                             = find(round(avg.time,2) == -0.1);
            lm2                             = find(round(avg.time,2) == 0);
            bsl                             = mean(avg.avg(:,lm1:lm2),2);
            avg.avg                         = (avg.avg - bsl) ./ bsl;
            
            list_unique                     = h_grouplabel(avg,'yes');
            avg                             = h_transform_avg(avg,list_unique(:,2),list_unique(:,1));
            
            tmp{ncon}                       = avg; clear avg;
            
        end
        
        alldata{nsuj,ndata}                 = tmp{1};
        alldata{nsuj,ndata}.avg            	= tmp{1}.avg-tmp{2}.avg; clear tmp;
        
        
    end
    
end

keep alldata *list;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [-0.2 1.6];
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

cfg.neighbours                              = neighbours;
cfg.design                                  = design;

stat                                        = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});
[min_p ,p_val ]                           	= h_pValSort(stat);

figure;
i                                           = 0;
plimit                                      = 0.2;
nrow                                        = 2;
ncol                                        = 2;

stat.mask                                   = stat.prob < plimit;

for nchan = 1:length(stat.label)
    
    tmp                                 = stat.mask(nchan,:,:) .* stat.prob(nchan,:,:);
    ix                                  = unique(tmp);
    ix                                  = ix(ix~=0);
    
    if ~isempty(ix)
        
        i                               = i + 1;
        subplot(nrow,ncol,i)
        hold on;
        
        for ncon = 1:2
            cfg                       	= [];
            cfg.channel              	= stat.label{nchan};
            cfg.p_threshold           	= plimit;
            cfg.time_limit             	= stat.time([1 end]);
            cfg.z_limit                 = [-10 10];
            cfg.color                  	= 'br';
            h_plotSingleERFstat_selectChannel(cfg,stat,alldata);
        end
        
        if length(stat.label) < 100
            nme                         = stat.label{nchan};
        else
            nme                             = strsplit(stat.label{nchan},',');
            nme                             = nme{2};
        end
        
        title([upper(nme) ' p = ' num2str(round(min(ix),3))]);
        set(gca,'FontSize',8,'FontName', 'Calibri');
        vline(0,'--k'); vline(1.2,'--k');
        hline(0,'--k');
        
        legend({data_list{1} '' data_list{2} ''});
        
    end
    
end