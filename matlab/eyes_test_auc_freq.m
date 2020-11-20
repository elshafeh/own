clear;

freq_list                                       = [1:30 32:2:100];
dir_data                                        = 'I:/eyes/decode/';
list_suj                                        = dir([dir_data '*.cueLock.decodCorrect.' num2str(freq_list(end)) 'Hz.auc.mat']);

for nsuj = 1:length(list_suj)
    
    subjectName                                 = strsplit(list_suj(nsuj).name,'.');
    subjectName                                 = subjectName{1};
    
    
    list_cond                                   = {'cueLock','stimLock'};
    list_feature                                = {'decodCue'}; %,'decodeCorrect','decodCue','decodStim'};
    time_win                                    = 0.05;
    list_time                                   = -1:time_win:2;
    
    for n_con = 1:length(list_cond)
        
        tmp                                     = [];
        
        for nfeat = 1:length(list_feature)
            for nfreq = 1:length(freq_list)
                
                ext_feature                     = list_feature{nfeat};
                fname                           = [dir_data subjectName '.' list_cond{n_con} '.'  ...
                    ext_feature '.' num2str(freq_list(nfreq)) 'Hz.auc.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                avg_data                        = [];
                
                for nt = 1:length(list_time)
                    
                    fnd1                        = list_time(nt);
                    fnd2                        = list_time(nt)+time_win;
                    
                    dist                        = abs(time_axis - fnd1);
                    minDist                     = min(dist);
                    t1                          = find(dist == minDist);
                    
                    dist                        = abs(time_axis - fnd2);
                    minDist                     = min(dist);
                    t2                          = find(dist == minDist);
                    
                    avg_data                    = [avg_data mean(scores(:,t1:t2),2)];
                    
                end
                
                tmp(nfeat,nfreq,:)              = avg_data; clear avg_data scores;
                
            end
            
        end
        
        freq                                    = [];
        freq.label                              = list_feature;
        freq.dimord                             = 'chan_freq_time';
        freq.time                               = list_time;
        freq.freq                               = freq_list;
        freq.powspctrm                          = tmp;
        alldata{nsuj,n_con}                     = freq; clear freq tmp time_axis;
        
    end
    
    alldata{nsuj,3}                             = alldata{nsuj,1};
    alldata{nsuj,4}                             = alldata{nsuj,2};
    
    alldata{nsuj,3}.powspctrm(:)                = 0.5;
    alldata{nsuj,4}.powspctrm(:)                = 0.5;
    
end

keep alldata list_*

list_cond                                       = {'cueLock','stimLock','chance','chance'};
list_test                                       = [1 3; 2 4];

for ntest = 1:size(list_test,1)
    
    cfg                                         = [];
    cfg.statistic                               = 'ft_statfun_depsamplesT';
    cfg.method                                  = 'montecarlo';
    cfg.correctm                                = 'cluster';
    cfg.clusteralpha                            = 0.05;
    cfg.latency                                 = [-1 1];
    %     cfg.frequency                               = [1 50];
    cfg.clusterstatistic                        = 'maxsum';
    cfg.minnbchan                               = 0;
    cfg.tail                                    = 0;
    cfg.clustertail                             = 0;
    cfg.alpha                                   = 0.025;
    cfg.numrandomization                        = 1000;
    cfg.uvar                                    = 1;
    cfg.ivar                                    = 2;
    
    nbsuj                                       = size(alldata,1);
    [design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                                  = design;
    cfg.neighbours                              = neighbours;
    
    stat{ntest}                              	= ft_freqstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
    list_test_name{ntest}                     	= [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}];
    
    
    [min_p(ntest),p_val{ntest}]                 = h_pValSort(stat{ntest});
    stat{ntest}                                 = rmfield(stat{ntest},'negdistribution');
    stat{ntest}                                 = rmfield(stat{ntest},'posdistribution');
    
end

i                                               = 0;
nrow                                            = 2;
ncol                                            = 2;

plimit                                          = 0.05;
opac_lim                                        = 0.3;
z_lim                                           = 5;

for ntest = 1:length(stat)
    
    statplot                                    = stat{ntest};
    statplot.mask                               = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                                     = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        iy                                      = unique(tmp);
        iy                                      = iy(iy~=0);
        iy                                      = iy(~isnan(iy));
        
        tmp                                     = statplot.mask(nchan,:,:) .* statplot.stat(nchan,:,:);
        ix                                      = unique(tmp);
        ix                                      = ix(ix~=0);
        ix                                      = ix(~isnan(ix));
        
        if ~isempty(ix)
        
        i                                   = i + 1;
        
        cfg                                 = [];
        cfg.colormap                        = brewermap(256, '*RdBu');
        cfg.channel                         = nchan;
        cfg.parameter                       = 'stat';
        cfg.maskparameter                   = 'mask';
        cfg.maskstyle                   	= 'outline';
        cfg.maskstyle                       = 'opacity';
        cfg.maskalpha                       = opac_lim;
        
        cfg.zlim                            = 'zeromax';%[-z_lim z_lim];
        cfg.ylim                            = statplot.freq([1 end]);
        cfg.xlim                            = statplot.time([1 end]);
        nme                                 = statplot.label{nchan};
        
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg,statplot);
        
        title(statplot.label{nchan});
        ylabel({list_test_name{ntest},[' p = ' num2str(round(min(min(iy)),3))]});
        
        i                               = i + 1;
        subplot(nrow,ncol,i)
        
        avg_over_time                 	= squeeze(nanmean(tmp,3));
        avg_over_time(isnan(avg_over_time)) = 0;
        
        plot(statplot.freq,avg_over_time,'k','LineWidth',2);
        xlabel('Frequency');
        set(gca,'FontSize',14,'FontName', 'Calibri');
        
        xlim(statplot.freq([1 end]));
        
        end
    end
end