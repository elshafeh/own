clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = '/project/3035002.01/bil/timegen/'; %'~/Dropbox/project_me/data/bil/decode/';
    
    list_frequency                      = {'theta' 'alpha' 'beta'}; % 'gamma' 
    list_decoding                       = {'frequency' 'orientation'};
    
    list_bin                            = [1 5];
    name_bin                            = {'Bin1' 'Bin5'};
    
    for nfreq = 1:length(list_frequency)
        for nbin = 1:length(list_bin)
            
            ext_name                    = '.newpeaks.all.bsl.timegen.mat'; %'.all.bsl.timegen.mat';
            
            pow                         = [];
            
            for ndeco = 1:length(list_decoding)
                
                fsearch                 = [dir_data subjectName '.1stgab.decodinggabor.' list_frequency{nfreq} ...
                    '.band.1stgab.window.bin' num2str(list_bin(nbin)) '.' list_decoding{ndeco}  ext_name];
                flist               	= dir(fsearch);
                
                tmp                     = [];
                
                for nf = 1:length(flist)
                    fname               = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp(nf,:,:)     	= scores;clear scores;
                end
                
                pow                     = squeeze(mean(tmp,1)); clear tmp;
                
                train_window            = [0.1 0.4];
                
                t1                   	= nearest(time_axis,train_window(1));
                t2                   	= nearest(time_axis,train_window(2));
                
                avg                   	= [];
                
                avg.avg                	= squeeze(mean(pow(:,t1:t2,:),2));
                
                if size(avg.avg,2) < size(avg.avg,1)
                    avg.avg           	= avg.avg';
                end
                
                avg.label             	= list_decoding(ndeco);
                avg.dimord            	= 'chan_time';
                avg.time            	= time_axis;
                alldata{nsuj,nfreq,ndeco,nbin}  	= avg; clear avg;
            
            end
        end
    end
end

keep alldata list_*

%%

nsuj                                    = size(alldata,1);
[design,neighbours]                     = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nfreq = 1:size(alldata,2)
    for ndeco = 1:size(alldata,3)
        
        cfg                             = [];
        cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
        cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
        cfg.uvar                        = 1;cfg.ivar = 2;
        cfg.tail                        = 0;cfg.clustertail  = 0;
        
        cfg.latency                     = [0 3];
        cfg.clusteralpha                = 0.05; % !!
        cfg.alpha                       = 0.05;
        
        cfg.numrandomization            = 1000;
        cfg.design                      = design;
        
        allstat{nfreq,ndeco}            = ft_timelockstatistics(cfg, alldata{:,nfreq,ndeco,1}, alldata{:,nfreq,ndeco,2});
        
    end
end

keep alldata list_* allstat name_bin

%% - % - 

figure;
nrow                                    = size(allstat,2);
ncol                                    = size(allstat,1);
i                                       = 0;
zlimit                                  = [0.55 0.8];
plimit                                  = 0.05;

for ndeco = [2 1]
    for nfreq = 1:size(allstat,1)
        
        stat                            = allstat{nfreq,ndeco};
        stat.mask                       = stat.prob < plimit;
        
        nchan                           = 1;
        
        vct                             = stat.prob(nchan,:);
        min_p                           = min(vct);
        
        cfg                             = [];
        cfg.time_limit                  = [-0.1 3]; %stat.time([1 end]);
        cfg.color                       = {'-b' '-r'};
        cfg.z_limit                     = zlimit(nchan,:);
        cfg.linewidth                   = 6;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_singlechannel(cfg,stat,squeeze(alldata(:,nfreq,ndeco,[1 2])));
        
        ylabel({stat.label{nchan}, ['p = ' num2str(round(min_p,3))]})
        
        
        vline([0],'--k');
        
        xticks([0 0.5 1 1.5 2 2.5 3]);
        xticklabels({'Gab' '0.5' '1' 'Cue2' '2' '2.5' 'Gab2'});
        
        title(list_frequency{nfreq});
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
        
    end
end