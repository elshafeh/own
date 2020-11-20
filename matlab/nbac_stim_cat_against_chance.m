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
    
    list_band                       = {'alpha' 'beta'};
    list_nback                   	= {'1back' '2back'};
    
    list_width                      = [1 2];
    list_band_col                   = [1 2];
    
    i                               = 0;
    
    for nband = 1:length(list_band)
        for nback = 1:length(list_nback)
            
            list_freq               = round(allpeaks(nsuj,list_band_col(nband))-list_width(nband) : allpeaks(nsuj,list_band_col(nband))+list_width(nband));
            pow                  	= [];
            
            for nfreq = 1:length(list_freq)
                
                file_list         	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess*.' list_nback{nback} ...
                    '.' num2str(list_freq(nfreq)) 'Hz.isfirst.bsl.dwn70.excl.auc.mat']);
                
                if isempty(file_list)
                    error('file not found!');
                end
                
                for nf = 1:length(file_list)
                    fname         	= [file_list(nf).folder filesep file_list(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    pow           	= [pow;scores]; clear scores;
                end
            end
            
            avg                 	= [];
            avg.label           	= {'auc'};
            avg.avg              	= nanmean(pow,1); clear pow;
            avg.dimord            	= 'chan_time';
            avg.time              	= time_axis;
            
            i                       = i+1;
            alldata{nsuj,i}         = avg; clear avg;
            
            list_cond{i}        	= [list_nback{nback} ' - ' list_band{nband}];
            fprintf('\n');
            
        end
    end
    
    flg                             = i+1;
    alldata{nsuj,flg}             	= alldata{nsuj,i};
    
    rnd_vct                         = 0.495:0.0001:0.505;
    for nc = 1:size(alldata{nsuj,flg}.avg,1)
        for nt = 1:size(alldata{nsuj,flg}.avg,2)
            alldata{nsuj,flg}.avg(nc,nt)    	= rnd_vct(randi(length(rnd_vct)));
        end
    end
    
    list_cond{end+1}                    = 'chance';
    
end

keep alldata list_cond

%%

list_test                           = [];

for ncond = 1:size(alldata,2)-1
    list_test(ncond,1)              = ncond;
    list_test(ncond,2)              = size(alldata,2);
end

for ntest = 1:size(list_test,1)
    
    cfg                         	= [];
    cfg.statistic                	= 'ft_statfun_depsamplesT';
    cfg.method                   	= 'montecarlo';
    cfg.correctm                  	= 'cluster';
    cfg.clusteralpha               	= 0.05;
    
    cfg.latency                    	= [-0.1 1];
    
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
    
    
    stat{ntest}                     = ft_timelockstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
    [min_p(ntest),~]            	= h_pValSort(stat{ntest});
    list_test_name{ntest}           = [list_cond{list_test(ntest,1)} ' vs ' list_cond{list_test(ntest,2)}];
    
end

keep alldata list_cond list_test_name stat min_p list_test

%%

i                                  	= 0;
nrow                                = 2;
ncol                                = 2;
z_limit                             = [0.47 0.6];
plimit                              = 0.1;

for ntest = 1:length(stat)
    
    stat{ntest}.mask             	= stat{ntest}.prob < plimit;
    
    for nchan = 1:length(stat{ntest}.label)
        
        tmp                         = stat{ntest}.mask(nchan,:,:) .* stat{ntest}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        i = i + 1;
        subplot(nrow,ncol,i)
        
        cfg                         = [];
        cfg.channel                 = stat{ntest}.label{nchan};
        cfg.p_threshold             = min_p(ntest) + 10e-5;
        
        cfg.z_limit                 = z_limit;
        cfg.time_limit              = stat{ntest}.time([1 end]);
        
        ix1                         = list_test(ntest,1);
        ix2                         = list_test(ntest,2);
        
        cfg.color                   = 'kr';
        
        h_plotSingleERFstat_selectChannel(cfg,stat{ntest},squeeze(alldata(:,[ix1 ix2])));
        
        %         legend({list_cond{ix1},'',list_cond{ix2},''});
        
        ylabel(['p= ' num2str(round(min_p(ntest),4))]);
        
        ylim(z_limit);
        yticks(z_limit);
        xticks(0:0.2:2);
        xlim(stat{ntest}.time([1 end]));
        hline(0.5,'--k');
        vline(0,'--k');
        ax = gca();ax.TickDir  = 'out';box off;
        
        title({stat{ntest}.label{nchan},list_test_name{ntest}});
        
    end
end