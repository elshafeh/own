clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
      
    list_freq                     	= 5:30;
        
    list_lock                    	= {'1Bv2B'}; % 'all.dwn70' 'first.dwn70' 'target.dwn70'
    
    pow                           	= [];
    
    for nfreq = 1:length(list_freq)
        for nlock = 1:length(list_lock)
                        
            % '1Bv2B' '.0backagaisnt.all'
            
            fname               	= ['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.decoding.' list_lock{nlock} '.' ...
                num2str(list_freq(nfreq)) 'Hz.lockedon.target.dwn70.nobsl.excl.auc.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            pow(nlock,nfreq,:)  	= scores; clear scores;
        end
    end
    
    list_name                       = {'alpha peak ± 1Hz','beta peak ± 2Hz'};
    list_peak                       = [allpeaks(nsuj,1) allpeaks(nsuj,2)];
    list_width                      = [1 2];
    
    for nband = 1:length(list_peak)
        
        xi                          = find(round(list_freq) == round(list_peak(nband) - list_width(nband)));
        yi                          = find(round(list_freq) == round(list_peak(nband) + list_width(nband)));
        
        zi                          = pow(:,xi:yi,:); clear xi yi;
        
        avg                         = [];
        avg.label                   = list_lock; 
        avg.avg                     = squeeze(nanmean(zi,2));
        
        if size(avg.avg,1) > size(avg.avg,2)
            avg.avg = avg.avg';
        end
        
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        
        alldata{nsuj,nband}         = avg; clear avg;
        
        
    end
    
    keep alldata list_name nsuj suj_list allpeaks
    
end

keep alldata
%%

nbsuj                               = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                 = [];
cfg.statistic                       = 'ft_statfun_depsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.clusterstatistic                = 'maxsum';
cfg.minnbchan                       = 0;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.uvar                            = 1;
cfg.ivar                            = 2;
cfg.design                          = design;
cfg.neighbours                      = neighbours;

cfg.latency                         = [-0.1 2];
list_test                           = [1 2];

for nt = 1:size(list_test,1)
    stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for nt = 1:length(stat)
    [min_p(nt),p_val{nt}]           = h_pValSort(stat{nt});
    %     stat{nt}                        = rmfield(stat{nt},'negdistribution');
    %     stat{nt}                        = rmfield(stat{nt},'posdistribution');
end

%%

list_cond                           = {'alpha' 'beta'};

i                                   = 0;
nrow                                = 2;
ncol                                = 2;
z_limit                             = [0.45 0.7];
plimit                              = 0.1;

for nchan = 1:length(stat{1}.label)
    for nt = 1:length(stat)
        
        stat{nt}.mask               = stat{nt}.prob < plimit;
        
        tmp                         = stat{nt}.mask(nchan,:,:) .* stat{nt}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                       = i + 1;
            subplot(nrow,ncol,i)
            
            nme                     = stat{nt}.label{nchan};
            
            cfg                     = [];
            cfg.channel             = stat{nt}.label{nchan};
            cfg.p_threshold        	= plimit;
            
            cfg.z_limit             = z_limit;
            cfg.time_limit          = stat{nt}.time([1 end]);
            
            ix1                     = list_test(nt,1);
            ix2                     = list_test(nt,2);
            
            cfg.color            	= 'br';
            
            h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,[ix1 ix2])));
            
            legend({list_cond{ix1},'',list_cond{ix2},''});
            
            title([stat{nt}.label{nchan} ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            hline(0.5,'--k');
            vline(0,'--k');
            
        end
    end
end