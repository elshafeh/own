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
[design,neighbours]      	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                         = [];
cfg.clusterstatistic        = 'maxsum';
cfg.method                  = 'montecarlo';
cfg.correctm                = 'cluster';
cfg.statistic               = 'depsamplesT';
cfg.uvar                    = 1;cfg.ivar = 2;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.neighbours              = neighbours;

cfg.clusteralpha            = 0.05; % !!
cfg.minnbchan               = 0; % !!
cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;

stat                        = ft_freqstatistics(cfg, alldata{:,1},alldata{:,5});

%%

[min_p, p_val]              = h_pValSort(stat);


%%

close all;
nrow                    	= 5;
ncol                      	= 5;
i                        	= 0;
plimit                      = 0.15;

nw_stat                     = stat;
nw_stat.mask                = nw_stat.prob < plimit;


for nchan = 1:length(nw_stat.label)
    
    flg                     = length(unique(nw_stat.mask(nchan,:)));
    
    if flg > 1
        
        cfg                 = [];
        cfg.colormap        = brewermap(256, '*RdBu');
        cfg.channel         = nchan;
        cfg.parameter       = 'stat';
        cfg.maskparameter	= 'mask';
        cfg.maskstyle       = 'outline';
        cfg.zlim            = [-5 5];
        cfg.colorbar        ='yes';
        
        i = i+1;
        subplot(nrow,ncol,i);
        ft_singleplotTFR(cfg,nw_stat);
        
        ylabel({nw_stat.label{nchan}});
        
        vct_plt     = [0 1.5 3 4.5 5.5];
        vline(vct_plt,'--k');
        xticklabels({'1st C' '1st G' '2nd C' '2nd G' 'RT'});
        xticks(vct_plt);
        set(gca,'FontSize',12,'FontName', 'Calibri');
        
    end
end