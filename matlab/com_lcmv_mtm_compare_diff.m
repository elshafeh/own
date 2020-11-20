clear;

suj_list                                    = [1:4 8:17] ;
data_list                                   = {'meg','eeg'};
cond_list                                   = {'right','left'};

for nsuj = 1:length(suj_list)
    
    suj                                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        for ncon = 1:2
            ext_name                        = [suj '.' cond_list{ncon} '.CnD.brain.slct.lp.' data_list{ndata}];
            
            fname                           = ['J:\temp\meeg\data\tf\' ext_name '.1t30Hz.1HzStep.KeepTrials.mat'];
            fprintf('\nLoading %50s\n',fname);
            load(fname);
            
            fname                           = ['J:\temp\meeg\data\peaks\' suj '.all.CnD.brain.slct.lp.' data_list{ndata}  '.m1000m0ms.alpha.peak.mat'];
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            pow                             = [];
            
            for nchan = 1:length(freq.label)
                f1                          = find(round(freq.freq,1) == round(allpeaks(nchan,1) - 1,1));
                f2                          = find(round(freq.freq,1) == round(allpeaks(nchan,1) + 1,1));
                pow(nchan,:)                = squeeze(mean(freq.powspctrm(nchan,f1:f2,:),2));
            end
            
            t1                              = find(round(freq.time,2) == round(-0.62,2));
            t2                              = find(round(freq.time,2) == round(-0.2,2));
            bsl                             = mean(pow(:,t1:t2),2);
            
            pow                             = (pow - bsl) ./ bsl;
            
            avg                             = [];
            avg.label                       = freq.label;
            avg.time                        = freq.time;
            avg.dimord                      = 'chan_time';
            avg.avg                         = pow; clear pow;
            
%             list_unique                     = h_grouplabel(avg,'yes');
%             avg                             = h_transform_avg(avg,list_unique(:,2),list_unique(:,1));
            
            tmp{ncon}                       = avg; clear avg;
            
        end
        
        
        alldata{nsuj,ndata}                 = tmp{1};
        alldata{nsuj,ndata}.avg            	= tmp{1}.avg-tmp{2}.avg; clear tmp;
        
    end
end

keep alldata *list;

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
plimit                                      = min_p + 0.001;
nrow                                        = 1;
ncol                                        = 1;

zlimit                                      = [-0.3 0.3];
stat.mask                                   = stat.prob < plimit;

for nchan = 1:length(stat.label)
    
    tmp                                     = stat.mask(nchan,:,:) .* stat.prob(nchan,:,:);
    ix                                      = unique(tmp);
    ix                                      = ix(ix~=0);
    
    if ~isempty(ix)
        
        i                                   = i + 1;
        subplot(nrow,ncol,i)
        hold on;
        
        for ncon = 1:2
            cfg                             = [];
            cfg.channel                     = stat.label{nchan};
            cfg.p_threshold                 = plimit;
            cfg.time_limit                  = stat.time([1 end]);
            cfg.z_limit                     = zlimit;
            cfg.color                       = 'br';
            h_plotSingleERFstat_selectChannel(cfg,stat,alldata);
        end
        
        if length(stat.label) < 100
            nme                             = stat.label{nchan};
        else
            nme                             = strsplit(stat.label{nchan},',');
            nme                             = nme{2};
        end
        
        title([upper(nme) ' p = ' num2str(round(min(ix),3))]);
        set(gca,'FontSize',12,'FontName', 'Calibri');
        vline(0,'--k'); vline(1.2,'--k');
        hline(0,'--k');
        
        legend({data_list{1} '' data_list{2} ''});
        
    end
    
end