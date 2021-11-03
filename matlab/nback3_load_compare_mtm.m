clc;clear;clc;

suj_list                  	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    for nback = 1:2
        
        ext_stim           	= 'norep';
        baseline_correct   	= 'average'; % none average time freq
        baseline_period   	= [-0.4 -0.2];
        
        dir_data           	= '~/Dropbox/project_me/data/nback/tf/behav2tf/';
        file_list       	= dir([dir_data 'sub' num2str(suj_list(nsuj)) '.' num2str(nback) 'back.' ext_stim '.correct.adaptive.mtm.mat']);
        pow              	= [];
        
        for nfile = 1:length(file_list)
            
            fname_in      	= [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            pow(nfile,:,:,:)    = freq_comb.powspctrm;
            
        end
        
        freq_comb.powspctrm	= squeeze(mean(pow,1)); clear pow;
        
        % - % baseline correction
        if strcmp(baseline_correct,'average')
            t1           	= nearest(freq_comb.time,baseline_period(1));
            t2            	= nearest(freq_comb.time,baseline_period(2));
            bsl           	= nanmean(freq_comb.powspctrm(:,:,t1:t2),3);
            freq_comb.powspctrm	= (freq_comb.powspctrm - bsl) ./ bsl ; clear bsl t1 t2;
        end
        
        % - % baseline correction
        if strcmp(baseline_correct,'time')
            bsl             = nanmean(freq_comb.powspctrm,3);
            freq_comb.powspctrm     = (freq_comb.powspctrm) ./ bsl ; clear bsl;
            
        end
        
        % - % baseline correction
        if strcmp(baseline_correct,'freq')
            bsl             = nanmean(freq_comb.powspctrm,2);
            freq_comb.powspctrm     = (freq_comb.powspctrm) ./ bsl ; clear bsl;
        end
        
        alldata{nsuj,nback}	= freq_comb; clear freq_comb;
        
    end
end

%%

keep alldata list_band ext_stim baseline_correct

nbsuj                    	= size(alldata,1);
[design,neighbours]       	= h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

cfg                       	= [];
cfg.statistic            	= 'ft_statfun_depsamplesT';
cfg.method                  = 'montecarlo';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.frequency               = [5 50];
cfg.latency                 = [-0.1 2];
cfg.clusterstatistic        = 'maxsum';
cfg.minnbchan               = 3;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.uvar                    = 1;
cfg.ivar                    = 2;

cfg.design                  = design;
cfg.neighbours              = neighbours;

stat                        = ft_freqstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]               = h_pValSort(stat);clc;

%%

close all;

plimit                   	= 0.05;
nrow                     	= 2;
ncol                        = 2;
i                         	= 0;

if min_p < plimit
    
    cfg                     = [];
    cfg.layout             	= 'neuromag306cmb_helmet.mat'; %'neuromag306cmb.lay';
    cfg.zlim                = [-2 2];
    cfg.colormap         	= brewermap(256,'*RdBu');
    cfg.plimit           	= plimit;
    cfg.vline               = 0;
    cfg.sign                = [-1 1];
    cfg.test_name           = '1Back - 2Back';
    cfg.fontsize         	= 16;
    cfg.vline               = [0 0.5];
    cfg.hline               = [7 15];
    
    h_plotstat_3d(cfg,stat);
    
end
