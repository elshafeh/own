clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                        = [1:4 8:17] ;
data_list                       = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                         = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        dir_data                = 'P:/3015079.01/com/erf/';
        fname_in                = [dir_data suj '.all.nDT.brain1vox.dwn60.' data_list{ndata} '.erf.mat'];
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        
        avg.avg                 = abs(avg.avg);
        
        lm1                  	= 144;%find(round(avg.time,1) == round(-0.1,1));
        lm2                  	= 151;%find(round(avg.time,1) == round(0,1));
        
        bsl                     = mean(avg.avg(:,lm1:lm2),2);
        avg.avg                 = (avg.avg - bsl) ./ bsl;
        
        alldata{nsuj,ndata}     = avg; clear avg;
        
    end
    
    %     hold on;nchn=1;plot(alldata{1,1}.avg(nchn,:),'-b');plot(alldata{1,2}.avg(nchn,:),'-r')
    
end

keep alldata *list list*;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [-0.2 1];
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
[min_p,p_val]                               = h_pValSort(stat);

i                                           = 0;
nrow                                        = 3;
ncol                                        = 2;
zlimit                                      = [-1 10];   
plimit                                      = 0.05;
    
for n_con = 1:length(stat)
    
    stat.mask                               = stat.prob < plimit;
    stat2plot                               = h_plotStat(stat,10e-13,plimit,'stat');
    
    for nchan = 1:length(stat.label)
        
        tmp                                 = stat.mask(nchan,:,:) .* stat.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                               = i + 1;
            
            subplot(nrow,ncol,i)

            cfg                       	= [];
            cfg.channel              	= stat.label{nchan};
            cfg.p_threshold           	= plimit;
            cfg.time_limit             	= stat.time([1 end]);
            cfg.z_limit                 = zlimit;
            cfg.color                  	= 'br';
            h_plotSingleERFstat_selectChannel(cfg,stat,alldata);
                
            
            nme                             = stat.label{nchan};
            
            title([upper(nme) ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',14,'FontName', 'Calibri');
            vline(0,'--k'); vline(1.2,'--k');
            
            legend({data_list{1},'',data_list{2},''});
            
        end
    end
end