clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                    = [1:4 8:17] ;
data_list                                   = {'meg','eeg'};
cond_list                                   = {'left','right'};

for nsuj = 1:length(suj_list)
    
    suj                                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        for ncon = 1:2
            
            dir_data                        = 'P:/3015079.01/com/erf/';
            fname_in                        = [dir_data suj '.' cond_list{ncon} '.nDT.brain1vox.dwn60.' data_list{ndata} '.erf.mat'];
            fprintf('Loading %50s\n',fname_in);
            load(fname_in);
            
            avg.avg                         = abs(avg.avg);
            
            lm1                             = 144;%find(round(avg.time,1) == round(-0.1,1));
            lm2                             = 151;%find(round(avg.time,1) == round(0,1));
            
            bsl                             = mean(avg.avg(:,lm1:lm2),2);
            avg.avg                         = (avg.avg - bsl) ./ bsl;
            
            alldata{nsuj,ndata,ncon}        = avg; clear avg;
            
            
        end
    end
    
end

keep alldata *list;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [-0.1 0.6];
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

for ndata = 1:2
    stat{ndata}                          	= ft_timelockstatistics(cfg, alldata{:,ndata,1}, alldata{:,ndata,2});
    [min_p{ndata} ,p_val{ndata} ]           = h_pValSort(stat{ndata});
end

figure;
i                                           = 0;
plimit                                      = 0.1;
nrow                                        = 2;
ncol                                        = 2;
zlim                                        = [-1 15];

for ndata = 1:length(stat)
    
    stat{ndata}.mask                        = stat{ndata}.prob < plimit;
    stat2plot                               = h_plotStat(stat{ndata},10e-13,plimit,'stat');
    
    for nchan = 1:length(stat{ndata}.label)
        
        tmp                                 = stat{ndata}.mask(nchan,:,:) .* stat{ndata}.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            hold on;
            
            for ncon = 1:2
                cfg                       	= [];
                cfg.channel              	= stat{ndata}.label{nchan};
                cfg.p_threshold           	= plimit;
                cfg.time_limit             	= stat{ndata}.time([1 end]);
                cfg.z_limit                 = zlim;
                cfg.color                  	= 'km';
                h_plotSingleERFstat_selectChannel(cfg,stat{ndata},squeeze(alldata(:,ndata,:)));
            end
            
            nme                             = stat{ndata}.label{nchan};
            
            title([upper(nme) ' ' upper(data_list{ndata}) ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',12,'FontName', 'Calibri');
            vline(0,'--k'); vline(1.2,'--k');
            hline(0,'--k');
            
            legend({cond_list{1},'',cond_list{2},''});
            
        end
    end
end