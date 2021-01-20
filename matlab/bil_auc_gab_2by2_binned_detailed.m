clear;clc;
clc; global ft_default; close all;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = 'D:/Dropbox/project_me/data/bil/decode/';
    
    frequency_list                      = {'theta' 'alpha' 'beta'}; % 
    ext_feat                            = 'orientation';
    
    name_bin                            = {'bin1' 'bin5'};
    
    for nfreq = 1:length(frequency_list)
        for nbin = 1:length(name_bin)
            
            fname               = [dir_data subjectName '.1stgab.decodinggabor.' frequency_list{nfreq} '.band.preGab1.window.' name_bin{nbin} '.' ext_feat '.all.bsl.auc.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            avg                         = [];
            avg.avg                     = scores; clear scores;
            avg.label               	= {ext_feat};
            avg.dimord                  = 'chan_time';
            avg.time                	= time_axis;
            tmp{1}                      = avg;
            
            fname                       = [dir_data subjectName '.2ndgab.decodinggabor.' frequency_list{nfreq} '.band.preGab2.window.' name_bin{nbin} '.' ext_feat '.all.bsl.auc.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            avg                         = [];
            avg.avg                     = scores; clear scores;
            avg.label               	= {ext_feat};
            avg.dimord                  = 'chan_time';
            avg.time                	= time_axis;
            tmp{2}                      = avg;
            
            alldata{nsuj,nfreq,nbin}  	= ft_timelockgrandaverage([],tmp{:}); clear tmp;
            
        end
    end
end

%%

keep alldata frequency_list name_bin

nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nfreq = 1:size(alldata,2)
    
    cfg                             = [];
    cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                        = 1;cfg.ivar = 2;
    cfg.tail                        = 0;cfg.clustertail  = 0;
    
    cfg.latency                     = [-0.1 1];
    cfg.clusteralpha                = 0.05; % !!
    cfg.alpha                       = 0.025;
    
    cfg.numrandomization            = 1000;
    cfg.design                      = design;
    
    compare_bin                     = [1 2];
    
    allstat{nfreq}                  = ft_timelockstatistics(cfg, alldata{:,nfreq,compare_bin(1)}, alldata{:,nfreq,compare_bin(2)});
    [min_p(nfreq) , p_val{nfreq}]   = h_pValSort(allstat{nfreq});
    
end

keep alldata frequency_list name_bin allstat min_p

%%

figure;
nrow                       	= 2;
ncol                       	= 2;
i                          	= 0;
zlimit                   	= [0.45 0.6;0.45 0.85];

for nfreq = 1:length(allstat)
    
    stat                    = allstat{nfreq};
    stat.mask               = stat.prob < 0.1;
    
    for nchan = 1:length(stat.label)
        
        vct              	= stat.prob(nchan,:);
        min_p             	= min(vct);
        
        cfg               	= [];
        cfg.channel      	= nchan;
        cfg.time_limit     	= stat.time([1 end]);
        cfg.color          	= {'-b' '-r'};
        cfg.z_limit        	= zlimit(nchan,:);
        cfg.linewidth      	= 10;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_singlechannel(cfg,stat,squeeze(alldata(:,nfreq,:)));
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        
        vline([0],'--k');
        
        xticks([0 0.5 1]);
        xticklabels({'Gab' '0.5' '1'});
        
        hline(0.5,'--k');
        
        title(frequency_list{nfreq});
        
        legend(name_bin);
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end