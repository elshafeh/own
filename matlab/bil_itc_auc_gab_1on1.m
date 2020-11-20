clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = '~/Dropbox/project_me/data/bil/decode/';
    
    list_freq                           = {'theta.minus1f' 'alpha.minus1f' 'beta.minus1f'  'broadband'};
    list_feat                           = {'frequency' 'orientation'};
    list_bin                            = {'bin1' 'bin5'};
    
    for nfreq = 1:length(list_freq)
        for nfeat = 1:length(list_feat)
            for nbin = 1:length(list_bin)
                
                flist                  	= dir([dir_data subjectName '.decodinggabor.*.lock.' list_freq{nfreq} '.centered.itc.' list_bin{nbin} '.' list_feat{nfeat}  ...
                    '.all.bsl.auc.mat']);
                
                tmp                     = [];
                
                for nf = 1:length(flist)
                    fname               = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp                 = [tmp;scores];clear scores
                end
                
                avg                    	= [];
                avg.avg              	= mean(tmp,1);
                avg.label               = {'auc'};
                avg.dimord           	= 'chan_time';
                avg.time              	= time_axis;
                
                alldata{nsuj,nfreq,nfeat,nbin}  	= avg; clear avg scores;
                
                
                
            end
        end
    end
    
    fprintf('\n');
    
end

keep alldata list_*;

%%

nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nfreq = 1:size(alldata,2)
    for nfeat = 1:size(alldata,3)
        
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
        
        allstat{nfreq,nfeat}      	= ft_timelockstatistics(cfg, alldata{:,nfreq,nfeat,1}, alldata{:,nfreq,nfeat,2});
        [min_p(nfreq,nfeat),~]    	= h_pValSort(allstat{nfreq,nfeat});
        
    end
end

keep alldata list_* allstat min_p

%%

figure;
nrow                                = 2;
ncol                                = 2;
i                                   = 0;

for nfreq = 1:size(alldata,2)
    for nfeat = 1:size(alldata,3)
        
        plimit                      = 0.2;
        stat                        = allstat{nfreq,nfeat};
        stat.mask                   = stat.prob < plimit;
        
        for nchan = 1:length(stat.label)
            
            vct                     = stat.prob(nchan,:);
            min_p                   = min(vct);
            
            if min_p < plimit
                
                cfg               	= [];
                cfg.channel      	= nchan;
                cfg.time_limit     	= stat.time([1 end]);
                cfg.color          	= {'-b' '-r'};
                
                if nfeat == 1
                    cfg.z_limit     = [0.45 0.8];
                else
                    cfg.z_limit   	= [0.45 0.6];
                end
                
                cfg.linewidth      	= 10;
                
                i = i+1;
                subplot(nrow,ncol,i);
                h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nfreq,nfeat,:)));
                                
                vline([0],'--k');
                xticks([0]);
                xticklabels({'Gabor Onset'});
                
                hline(0.5,'--k');
                
                title({list_freq{nfreq},list_feat{nfeat}, ['p= ' num2str(round(min_p,3))]});
                
                set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
                
                yticks([0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8])
                grid;
                
            end
        end
    end
end

keep alldata list_* allstat