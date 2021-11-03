clear;clc;

suj_list                      	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in                  	= ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)     	= apeak;
    allbetapeaks(nsuj,1)     	= bpeak;
    
end

mean_beta_peak               	= round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))               = mean_beta_peak;

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    dir_data                    = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.mtm.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    ext_stim                    = 'target';
    ext_behav                   = 'accuracy';
    
    if strcmp(ext_stim,'target')
        flg_trials              = find(trialinfo(:,2) == 2);
    end
    
    rho_carrier                 = [];
    disp('computing correlation');
    
    f1                          = nearest(freq_comb.freq,5);
    f2                          = nearest(freq_comb.freq,35);
    
    t1                          = nearest(freq_comb.time,-0.5);
    t2                          = nearest(freq_comb.time,0.5);
    
    freq_comb.powspctrm       	= freq_comb.powspctrm(:,:,f1:f2,t1:t2);
    freq_comb.freq              = freq_comb.freq(f1:f2);
    freq_comb.time              = freq_comb.time(t1:t2);
    
    for nfreq = 1:length(freq_comb.freq)
        for ntime = 1:length(freq_comb.time)
            
            pow                 = squeeze(freq_comb.powspctrm(flg_trials,:,nfreq,ntime));
            
            if strcmp(ext_behav,'accuracy')
                behav         	= trialinfo(flg_trials,4);
                
                behav(behav == 1 | behav == 3)  = 1;
                behav(behav == 2 | behav == 4)  = 0;
                
                
            elseif strcmp(ext_behav,'rt')
                behav               = trialinfo(flg_trials,5)/1000;
            end
            
            [rho,p]          	= corr(pow,behav , 'type', 'Spearman');
            rho              	= .5.*log((1+rho)./(1-rho));
            
            rho_carrier(:,nfreq,ntime)    = rho; clear rho;
            
        end
    end
    
    freq                            = [];
    freq.time                       = freq_comb.time;
    freq.freq                       = freq_comb.freq;
    freq.label                      = freq_comb.label;
    freq.dimord                     = 'chan_freq_time';
    freq.powspctrm                  = rho_carrier; clear rho_carrier;
    
    alldata{nsuj,1}                 = freq;
    
    freq.powspctrm(:)             	= 0;
    alldata{nsuj,2}                 = freq; clear avg rho
    
end

%%

for nsuj = 1:size(alldata,1)
    alldata{nsuj,2}.powspctrm(:)    = 0;
end

keep alldata ext_*

%%

nbsuj                         	= size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');


cfg                             = [];
cfg.statistic                   = 'ft_statfun_depsamplesT';
cfg.method                      = 'montecarlo';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
% cfg.frequency                   = [15 35];
% cfg.latency                 = [-0.5 0.5];
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 2;
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.uvar                        = 1;
cfg.ivar                        = 2;
nbsuj                           = size(alldata,1);
cfg.design                      = design;
cfg.neighbours                  = neighbours;

stat                            = ft_freqstatistics(cfg,alldata{:,1},alldata{:,2});
[min_p,p_val]                   = h_pValSort(stat);clc;


%%

plimit                        	= 0.05;
nrow                           	= 2;
ncol                          	= 2;
i                            	= 0;

if min_p < plimit
    
    cfg                         = [];
    cfg.layout                  = 'neuromag306cmb.lay';
    cfg.zlim                    = [-3 3];
    cfg.colormap                = brewermap(256,'*RdBu');
    cfg.plimit                  = plimit;
    cfg.vline                   = 0;
    cfg.sign                    = [-1 1];
    cfg.test_name               = [ext_stim ' with ' ext_behav];
    h_plotstat_3d(cfg,stat);
    
end