clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                      	= [1:33 35:36 38:44 46:51];
allpeaks                     	= [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)          	= apeak; clear apeak;
    allpeaks(nsuj,2)         	= bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    subjectName              	= ['sub' num2str(suj_list(nsuj))];clc;
    
    list_stim                   = {'first' 'target'};
    test_band                   = {'alpha' 'beta'};
    
    i                           = 0;
    list_cond                 	= {};
    
    for nback = [1 2]
        for nstim = [1 2]
            
            % load data from both sessions
            check_name             	= dir(['J:/nback/tf_sens/' subjectName '.sess*.' num2str(nback) 'back.' list_stim{nstim} '.stim.1t100Hz.sens.mat']);
            
            for nf = 1:length(check_name)
                
                fname             	= [check_name(nf).folder filesep check_name(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                
                % baseline-correct
                cfg                	= [];
                cfg.baseline      	= [-0.4 -0.2];
                cfg.baselinetype   	= 'relchange';
                freq_comb       	= ft_freqbaseline(cfg,freq_comb);
                
                tmp{nf}             = freq_comb; clear freq_comb;
                
            end
            
            % avearge both sessions
            freq                    = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
            
            for nband = [1 2]
                
                switch test_band{nband}
                    case 'alpha'
                        bnd_width  	= 1;
                        apeak    	= allpeaks(nsuj,1);
                        xi        	= find(round(freq.freq) == round(apeak - bnd_width));
                        yi         	= find(round(freq.freq) == round(apeak + bnd_width));
                    case 'beta'
                        bnd_width  	= 2;
                        apeak     	= allpeaks(nsuj,2);
                        xi         	= find(round(freq.freq) == round(apeak - bnd_width));
                        yi       	= find(round(freq.freq) == round(apeak + bnd_width));
                end
                
                avg             	= [];
                avg.avg           	= squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
                avg.label        	= freq.label;
                avg.dimord        	= 'chan_time';
                avg.time          	= freq.time;
                
                i                  	= i + 1;
                alldata{nsuj,i}    	= avg; clear avg;
                
                list_cond{i}      	= ['B' num2str(nback) ' ' list_stim{nstim} ' ' test_band{nband}];
                
            end
        end
    end
    
    behav_struct                    = h_nbk_exctract_behav(suj_list(nsuj));
    % - % - make sure you got these right
    behav_struct                    = behav_struct(:,2:3);
    
    i                               = 0;
    list_behav                      = {}; % 'rt','correct'};
    
    for nback = 1:length(behav_struct)
        i                           = i + 1;
        allbehav{nsuj,i}            = [behav_struct(nback).rt];
        list_behav{i}               = [behav_struct(nback).cond ' rt'];
        
        i                           = i + 1;
        allbehav{nsuj,i}            = [behav_struct(nback).correct];
        list_behav{i}               = [behav_struct(nback).cond ' acc'];

    end
    
    
    keep alldata allbehav list_behav list_cond keep suj_list allpeaks  nsuj
    
end

keep alldata list_behav allbehav list_cond

%%

cfg                     = [];
cfg.method              = 'montecarlo';
cfg.latency             = [0 1];
cfg.statistic           = 'ft_statfun_correlationT';
cfg.clusterstatistics   = 'maxsum';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.ivar                = 1;
cfg.type            	= 'Spearman';
cfg.minnbchan         	= 3;

nb_suj                 	= size(alldata,1);
[design,neighbours]  	= h_create_design_neighbours(nb_suj,alldata{1,1},'elekta','t');
cfg.neighbours       	= neighbours;

i                       = 0;

for ncond = 1:size(alldata,2)
    
    if ncond < 5
        test_behav      = [1 2];
    else
        test_behav      = [3 4];
    end
    
    for nbehav = 1:length(test_behav)
        
        i                                               = i+1;
        cfg.design(1,1:nb_suj)                          = [allbehav{:,test_behav(nbehav)}];
        stat{i}                                         = ft_timelockstatistics(cfg, alldata{:,ncond});
        list_test{i,1}                              	= [list_cond{ncond} ' with ' list_behav{test_behav(nbehav)}];
        [list_test{i,2},~]                              = h_pValSort(stat{i});
        
    end
    
end

keep alldata allbehav list_behav list_cond list_test stat

%%

figure;
nrow                                    = 4;
ncol                                    = 2;
i                                       = 0;

for ntest = 1:length(stat)
    
    plimit = 0.12;
    
    if list_test{ntest,2} < plimit
        
        sfocus                          = stat{ntest};
        sfocus.mask                     = sfocus.prob < plimit;
        
        statplot                        = [];
        statplot.time                   = sfocus.time;
        statplot.label                  = sfocus.label;
        statplot.dimord                 = sfocus.dimord;
        statplot.avg                    = sfocus.mask .* sfocus.rho;
        
        cfg                             = [];
        cfg.layout                      = 'neuromag306cmb.lay';
        cfg.zlim                        = [-0.1 0.1];
        cfg.colormap                    = brewermap(256,'*RdBu');
        cfg.marker                      = 'off';
        cfg.comment                     = 'no';
        cfg.colorbar                    = 'yes';        
        
        i = i +1;
        subplot(nrow,ncol,i);
        ft_topoplotER(cfg,statplot);
        title({list_test{ntest},['p = ' num2str(list_test{ntest,2})]});
        
        vct_y                           = statplot.avg;
        vct_y(vct_y == 0)               = NaN;
        vct_y                           = nanmean(vct_y,1);
        vct_y(isnan(vct_y))             = 0;
        
        i = i +1;
        subplot(nrow,ncol,i);
        plot(statplot.time,vct_y);
        xlim(statplot.time([1 end]));
        ylim([-0.4 0.4]);
        vline(0,'-k')
        
    end
end