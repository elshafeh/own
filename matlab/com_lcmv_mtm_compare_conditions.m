clear;

suj_list                                   = [1:4 8:17] ;
data_list                                  = {'meg','eeg'};
cond_list                                  = {'inf','unf'};

for nsuj = 1:length(suj_list)
    
    suj                                    = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        for ncon = 1:2
            ext_name                       = [suj '.' cond_list{ncon} '.CnD.brain.slct.lp.' data_list{ndata}];
            
            fname                          = ['../data/tf/' ext_name '.1t30Hz.1HzStep.KeepTrials.mat'];
            fprintf('\nLoading %50s\n',fname);
            load(fname);
            
            fname                          = ['../data/peaks/' suj '.all.CnD.brain.slct.lp.' data_list{ndata}  '.m1000m0ms.alpha.peak.mat'];
            fprintf('Loading %50s\n',fname);
            load(fname);
            
            pow                            = [];
            
            for nchan = 1:length(freq.label)
                f1                         = find(round(freq.freq,1) == round(allpeaks(nchan,1) - 1,1));
                f2                         = find(round(freq.freq,1) == round(allpeaks(nchan,1) + 1,1));
                pow(nchan,:)               = squeeze(mean(freq.powspctrm(nchan,f1:f2,:),2));
            end
            
            t1                             = find(round(freq.time,2) == round(-0.62,2));
            t2                             = find(round(freq.time,2) == round(-0.2,2));
            bsl                            = mean(pow(:,t1:t2),2);
            
            pow                            = (pow - bsl) ./ bsl;
            
            avg                            = [];
            avg.label                      = freq.label;
            avg.time                       = freq.time;
            avg.dimord                     = 'chan_time';
            avg.avg                        = pow; clear pow;
            
            alldata{nsuj,ndata,ncon}       = avg; clear avg;
            
        end
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

% cfg.channel                                 = [53:144 158:179];

cfg.neighbours                              = neighbours;
cfg.design                                  = design;

for ndata = 1:2
    stat{ndata}                          	= ft_timelockstatistics(cfg, alldata{:,ndata,1}, alldata{:,ndata,2});
    [min_p(ndata) ,p_val{ndata} ]           = h_pValSort(stat{ndata});
end

figure;
i                                           = 0;
plimit                                      = 0.1;
nrow                                        = 2;
ncol                                        = 2;

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
                cfg.z_limit                 = [-0.4 0.4];
                cfg.color                  	= 'km';
                h_plotSingleERFstat_selectChannel(cfg,stat{ndata},squeeze(alldata(:,ndata,:)));
            end
            
            nme                             = strsplit(stat{ndata}.label{nchan},',');
            nme                             = nme{2};
            
            title([upper(nme) ' ' upper(data_list{ndata}) ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',8,'FontName', 'Calibri');
            vline(0,'--k'); vline(1.2,'--k');
            
            %             i                               = i + 1;
            %             subplot(nrow,ncol,i)
            %             cfg                             = [];
            %             cfg.linewidth                   = 2;
            %             cfg.linecolor                   = 'k';
            %             cfg.channel                     = nchan;
            %             ft_singleplotER(cfg,stat2plot);
            
        end
    end
end