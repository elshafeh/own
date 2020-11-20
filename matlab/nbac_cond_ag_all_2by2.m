clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];
allpeaks                                    = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                        = apeak; clear apeak;
    allpeaks(nsuj,2)                        = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)            = nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_cond                   	= {'1back','2back'};
    list_color                    	= 'gb';
    list_name                       = {'beta'};
    
    if strcmp(list_name{:},'alpha')
        nband                       = 1;
        list_freq                   = round(allpeaks(nsuj,nband)-nband : allpeaks(nsuj,nband)+nband);
    else
        nband                       = 2;
        list_freq                   = round(allpeaks(nsuj,nband)-nband : allpeaks(nsuj,nband)+nband);
    end
    
    for nback = 1:length(list_cond)
        
        list_lock                 	= {'target.d'};% target first
        
        pow                        	= [];
        
        for nfreq = 1:length(list_freq)
            for nlock = 1:length(list_lock)
                fname                       = ['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' ...
                    list_cond{nback} '.agaisnt.all.' num2str(list_freq(nfreq)) 'Hz.lockedon.' list_lock{nlock} 'wn70.bsl.excl.auc.mat'];
                
                fprintf('loading %s\n',fname);
                load(fname);
                pow(nlock,nfreq,:)          = scores; clear scores;
            end
        end
        
        avg                         = [];
        avg.label                   = list_lock; clear list_final
        avg.avg                     = [squeeze(mean(pow,2))]'; clear pow;
        avg.dimord                  = 'chan_time';
        avg.time                    = -1.5:0.02:2;
        
        alldata{nsuj,nback}         = avg; clear avg;
        
    end
    
end

keep alldata list_*;

list_test                           = [1 2];

for nt = 1:size(list_test,1)
    cfg                         	= [];
    cfg.statistic                	= 'ft_statfun_depsamplesT';
    cfg.method                   	= 'montecarlo';
    cfg.correctm                  	= 'cluster';
    cfg.clusteralpha               	= 0.05;
    
    cfg.latency                    	= [0 1];
    
    cfg.clusterstatistic            = 'maxsum';
    cfg.minnbchan                   = 0;
    cfg.tail                        = 0;
    cfg.clustertail                 = 0;
    cfg.alpha                       = 0.025;
    cfg.numrandomization            = 1000;
    cfg.uvar                        = 1;
    cfg.ivar                        = 2;
    
    nbsuj                           = size(alldata,1);
    [design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                      = design;
    cfg.neighbours                  = neighbours;
    
    
    stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    list_test_name{nt}              = [list_cond{list_test(nt,1)} ' v ' list_cond{list_test(nt,2)}];
    
end

%%

i                                  	= 0;
nrow                                = 3;
ncol                                = 3;
z_limit                             = [0.48 0.6];
plimit                              = 0.05;

for ns = 1:length(stat)
    
    stat{ns}.mask                   = stat{ns}.prob < plimit;
    
    for nchan = 1:length(stat{ns}.label)
        
        tmp                         = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        %         if ~isempty(ix)
            
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
            xlim([-0.1 1]);
            hline(0.5,'-k');vline(0,'-k');
            ax = gca();ax.TickDir  = 'out';box off;
            
            title({stat{ns}.label{nchan},list_name{:}});
            
            %         end
    end
end