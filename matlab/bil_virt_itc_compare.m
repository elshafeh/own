clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName         	= suj_list{ns};
    
    subject_folder          = ['/project/3015079.01/data/' subjectName '/virt/'];
    fname                 	= [subject_folder subjectName '.wallis.cuelock.itc.5binned.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nb = 1:length(phase_lock)
        
        freq               	= phase_lock{nb};
        freq               	= rmfield(freq,'rayleigh');
        freq              	= rmfield(freq,'p');
        freq              	= rmfield(freq,'sig');
        freq             	= rmfield(freq,'mask');
        freq              	= rmfield(freq,'mean_rt');
        freq             	= rmfield(freq,'med_rt');
        freq            	= rmfield(freq,'index');
        
        freq.label          = h_removeunderscore(freq.label);
        
        alldata{ns,nb}   	= freq; clear freq;
        
    end
end

%%

keep alldata list_*

% compute anova
nbsuj                       = size(alldata,1);
[~,neighbours]              = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.method                  = 'ft_statistics_montecarlo';
cfg.statistic               = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistic        = 'maxsum';
cfg.clusterthreshold        = 'nonparametric_common';
cfg.tail                 	= 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail             = cfg.tail;
cfg.alpha                   = 0.05;
cfg.computeprob             = 'yes';
cfg.numrandomization        = 1000;
cfg.neighbours              = neighbours;
cfg.minnbchan               = 0;
cfg.channel               	= 1;

design(1,1:nbsuj)           = 1;
design(1,nbsuj+1:2*nbsuj)   = 2;
design(1,nbsuj*2+1:3*nbsuj) = 3;
design(1,nbsuj*3+1:4*nbsuj) = 4;
design(1,nbsuj*4+1:5*nbsuj) = 5;
design(2,:)                 = repmat(1:nbsuj,1,5);

cfg.design                  = design;
cfg.ivar                    = 1; % condition
cfg.uvar                    = 2; % subject number

stat                        = ft_freqstatistics(cfg, alldata{:,1}, alldata{:,2}, alldata{:,3}, alldata{:,4}, alldata{:,5});

%% plot

close all; figure;

stoplot                     = [];
stoplot.freq                = stat.freq;
stoplot.time                = stat.time;
stoplot.label               = stat.label;
stoplot.dimord              = 'chan_freq_time';
stoplot.powspctrm           = squeeze(stat.stat .* stat.mask);

nrow                    	= 5;
ncol                      	= 8;
i                        	= 0;

for nchan = 1:length(stoplot.label)
    
    chk                         = unique(stoplot.powspctrm(nchan,:,:));
    
    if length(chk) > 1
        
        cfg                    	= [];
        cfg.channel          	= nchan;
        cfg.comment           	= 'no';
        cfg.colorbar           	= 'no';
        cfg.colormap          	= brewermap(256, '*Reds');
        cfg.zlim              	= 'zeromax';
        
        i = i +1;
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg,stoplot);
        title(stoplot.label{nchan});
        vline([0 1.5 3 4.5 5.5],'--k');
        xticklabels({'C1' 'G1' 'C2' 'G2' 'RT'});
        xticks([0 1.5 3 4.5 5.5]);
        
        %         set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
        i = i +1;
        subplot(nrow,ncol,i)
        
        data_plot            	= [];
        
        for nsuj = 1:size(alldata,1)
            for nbin = 1:size(alldata,2)
                
                f1              = find(round(alldata{nsuj,nbin}.freq) == round(stat.freq(1)));
                f2              = find(round(alldata{nsuj,nbin}.freq) == round(stat.freq(end)));
                
                t1              = find(round(alldata{nsuj,nbin}.time,2) == round(stat.time(1),2));
                t2              = find(round(alldata{nsuj,nbin}.time,2) == round(stat.time(end),2));
                
                tmp.powspctrm   = alldata{nsuj,nbin}.powspctrm(nchan,f1:f2,t1:t2);
                
                tmp           	= tmp.powspctrm .* squeeze(stat.mask);
                tmp(tmp == 0)  	= NaN;
                tmp            	= nanmean(nanmean(nanmean(tmp)));
                
                data_plot(nsuj,nbin,:)  = tmp; clear tmp;
                
            end
        end
        
        mean_data           	= nanmean(data_plot,1);
        bounds               	= nanstd(data_plot, [], 1);
        bounds_sem            	= bounds ./ sqrt(size(data_plot,1));
        
        errorbar(mean_data,bounds_sem,'-ks');
        
        xlim([0 6]);
        xticks([1 2 3 4 5]);
        xticklabels({'F','','M','','S'});
        yticks([]);
        
    end
end
