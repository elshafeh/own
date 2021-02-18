clear;

clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                    = [1:29 31:33 35:36 38:44 46:51]; % remove sub30 - not enough trials
ix_bad_subject                              = [];

for nsuj = 1:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    dir_data                                = '/Users/heshamelshafei/Dropbox/project_me/data/nback/bin_decode/auc/';
    
    list_band                               = {'alpha' 'beta'}; % 'gamma1' 'gamma2'}; %{'broadband'}; % 'slow'
    list_deco                               = {'condition' 'target'  'stim*'  }; % 'first'
    list_bin                                = {'3binsb1' '3binsb2' '3binsb3'}; 
    
    for ndeco = 1:length(list_deco)
        for nband = 1:length(list_band)
            for nbin = 1:length(list_bin)
                
                flist                       = dir([dir_data subjectname '.' list_band{nband} '.decoding.' ...
                    list_deco{ndeco} '.' list_bin{nbin} '.4fold.nodemean.auc.mat']);
                
                if isempty(flist)
                    ix_bad_subject          = [ix_bad_subject nsuj];
                end
                
                %                 if isempty(flist)
                %                     flist                	= dir([dir_data subjectname '.' list_band{nband} '.decoding.' ...
                %                         list_deco{ndeco} '.' list_bin{nbin} '.3fold.nodemean.auc.mat']);
                %                 end
                %
                %                 if isempty(flist)
                %                     flist                	= dir([dir_data subjectname '.' list_band{nband} '.decoding.' ...
                %                         list_deco{ndeco} '.' list_bin{nbin} '.*fold.nodemean.auc.mat']);
                %                 end
                
                mtrx_data                   = [];
                
                for nf = 1:length(flist)
                    fname                   = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    mtrx_data(nf,:)         = scores; clear scores fname;
                end
                
                avg                         = [];
                avg.label                   = {'auc'};
                avg.time                    = time_axis;
                avg.avg                     = mean(mtrx_data,1);
                avg.dimord                  = 'chan_time';
                
                alldata{nsuj,ndeco,nband,nbin}  = avg; clear avg;
                
            end
        end
    end
end

%%

keep alldata list_* ix_bad_subject

nsuj                                = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for ndeco = 1:length(list_deco)
    for nband = 1:length(list_band)
        
        
        cfg                         = [];
        cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
        cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
        cfg.uvar                    = 1;cfg.ivar = 2;
        cfg.tail                    = 0;cfg.clustertail  = 0;
        cfg.neighbours              = neighbours;
        cfg.latency                 = [-0.01 1];
        cfg.clusteralpha            = 0.05; % !!
        cfg.minnbchan               = 0; % !!
        cfg.alpha                   = 0.025;
        
        cfg.numrandomization        = 1000;
        cfg.design                  = design;
        
        allstat{ndeco,nband,1}   	= ft_timelockstatistics(cfg, alldata{:,ndeco,nband,1}, alldata{:,ndeco,nband,2});
        allstat{ndeco,nband,2}    	= ft_timelockstatistics(cfg, alldata{:,ndeco,nband,1}, alldata{:,ndeco,nband,3});
        allstat{ndeco,nband,3}    	= ft_timelockstatistics(cfg, alldata{:,ndeco,nband,2}, alldata{:,ndeco,nband,3});
        
    end
end

%%

keep alldata list_* allstat

figure;
nrow                                    = 2;
ncol                                    = 2;
i                                       = 0;
zlimit                                  = [0.7 1 0.7 0.7 0.7];

list_test                               = {'b1 v b2' 'b1 v b3' 'b2 v b3'};
list_index                              = [1 2; 1 3; 2 3];

for ndeco = 1:length(list_deco)
    for nband = 1:length(list_band)
        for ntest = 1:length(list_test)
            
            plimit                      = 0.2;
            stat                        = allstat{ndeco,nband,ntest};
            stat.mask                   = stat.prob < plimit;
            
            for nchan = 1:length(stat.label)
                
                vct                     = stat.prob(nchan,:);
                min_p                   = min(vct);
                
                if min_p < plimit
                    
                    cfg                     = [];
                    cfg.channel             = nchan;
                    cfg.time_limit          = stat.time([1 end]);
                    cfg.color               = {'-b' '-r'};
                    cfg.z_limit             = [0.45 zlimit(ndeco)];
                    cfg.linewidth           = 10;
                    
                    i = i+1;
                    subplot(nrow,ncol,i);
                    h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,ndeco,nband,list_index(ntest,:))));
                    
                    title([list_band{nband} ' p = ' num2str(round(min_p,3))])
                    ylabel({['Decoding ' list_deco{ndeco}],list_test{ntest}});
                    
                    vline([0],'--k');
                    hline(0.5,'--k');
                    
                    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
                    
                end
            end
        end
    end
end