clear;clc;
clc; global ft_default; close all;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = '~/Dropbox/project_me/data/bil/decode/';
    
    frequency_list                      = {'beta' }; % 'theta' 'alpha' 'beta' 
    decoding_list                       = {'orientation'}; % 'orientation'
    
    list_bin                            = [1 2 3 4 5];
    name_bin                            = {'Bin1' 'Bin2' 'Bin3' 'Bin4' 'Bin5'};
    
    for nfreq = 1:length(frequency_list)
        for nbin = 1:length(list_bin)
            
            avg                         = [];
            avg.avg                     = [];
            
            for ndeco = 1:length(decoding_list)
                
                flist_1               	= dir([dir_data subjectName '.1stgab.decodinggabor.' frequency_list{nfreq} ...
                    '.band.preGab1.window.bin' num2str(list_bin(nbin)) '.' decoding_list{ndeco}  '.all.bsl.auc.mat']);
                
                flist_2               	= dir([dir_data subjectName '.2ndgab.decodinggabor.' frequency_list{nfreq} ...
                    '.band.preGab2.window.bin' num2str(list_bin(nbin)) '.' decoding_list{ndeco}  '.all.bsl.auc.mat']);
                
                flist                   = [flist_1;flist_2]; clear flist_*
                
                tmp                     = [];
                
                for nf = 1:length(flist)
                    fname               = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    if length(scores) > 84
                        t1            	= find(round(time_axis,2) == round(-0.2,2));
                        t2              = t1+83;
                        scores          = scores(:,t1:t2);
                    end
                    
                    tmp                 = [tmp;scores];clear scores;
                end
                
                avg.avg                 = [avg.avg;mean(tmp,1)]; clear tmp;
            end
            
            avg.label               	= decoding_list;
            avg.dimord                  = 'chan_time';
            avg.time                	= time_axis;
            
            alldata{nsuj,nfreq,nbin}  	= avg; clear avg;
            
        end
        
        
    end
end

keep alldata *_list name_bin

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nfreq = 1:size(alldata,2)
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    cfg.latency                 = [-0.1 1];
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 0; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    compare_bin                 = [1 5];
    name_bin                    = {'' '' '' ''};
    name_bin{1}                 = ['B' num2str(compare_bin(1))];
    name_bin{3}                 = ['B' num2str(compare_bin(2))];
    
    allstat{nfreq}              = ft_timelockstatistics(cfg, alldata{:,nfreq,compare_bin(1)}, alldata{:,nfreq,compare_bin(2)});
    
end

keep alldata *_list allstat name_bin

%% - % - 

figure;
nrow                       	= 2;
ncol                       	= 2;
i                          	= 0;
zlimit                   	= [0.45 0.85; 0.45 0.6];

for nfreq = 1:length(allstat)
    
    stat                    = allstat{nfreq};
    stat.mask               = stat.prob < 0.05;
    
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
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nfreq,[1 5])));
        
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