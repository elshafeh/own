clear ; close all;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                                = [1:4 8:17];

for ns = 1:length(suj_list)
    for ndata = 1:2
        
        list_feat                       = {'inf.unf','left.right'};
        
        for nfeat = 1:length(list_feat)
            
            list_data                   = {'meg','eeg'};
            
            fname                       = ['/project/3015039.05/temp/meeg/data/decode/yc' num2str(suj_list(ns)) '.CnD.brain.slct.lp.' list_data{ndata} '.' list_feat{nfeat} '.auc.bychan.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            if ns == 1 && ndata == 1&& nfeat == 1
                load /project/3015039.05/temp/meeg/data/lcmv_brain/yc1.CnD.brain.slct.bp.eeg.mat
                roi_label            	= data.label;
            end
            
            avg                         = [];
            avg.avg                     = scores; clear scores;
            avg.label                   = roi_label;
            avg.dimord                  = 'chan_time';
            avg.time                    = time_axis;
            
            alldata{ns,nfeat,ndata}     = avg; clear avg;
            
        end
    end
end

keep alldata list_feat

nbsuj                           = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                             = [];

cfg.latency                     = [-0.2 2];

cfg.statistic                   = 'ft_statfun_depsamplesT';
cfg.method                      = 'montecarlo';
cfg.correctm                    = 'cluster';
cfg.clusteralpha                = 0.05;
cfg.clusterstatistic            = 'maxsum';
cfg.minnbchan                   = 0;
cfg.tail                        = 0;
cfg.clustertail                 = 0;
cfg.alpha                       = 0.025;
cfg.numrandomization            = 1000;
cfg.uvar                        = 1;
cfg.ivar                        = 2;

cfg.neighbours                  = neighbours;
cfg.design                      = design;

for nfeat = 1:size(alldata,2)
    stat{nfeat}                 = ft_timelockstatistics(cfg,alldata{:,nfeat,1},alldata{:,nfeat,2});
end

for nfeat = 1:length(stat)
    [min_p(nfeat),p_val{nfeat}]	= h_pValSort(stat{nfeat});
end

keep alldata list_feat min_p p_val stat

i                            	= 0;
nrow                            = 4;
ncol                            = 2;
p_limit                      	= 0.1;
z_limit                         = [0.48 0.7];
    
for nfeat = 1:length(stat)
    
    
    if min_p(nfeat) < p_limit
        
        stat{nfeat}.mask                        = stat{nfeat}.prob < p_limit;
        
        for nchan = 1:length(stat{nfeat}.label)
            
            tmp                                 = stat{nfeat}.mask(nchan,:,:) .* stat{nfeat}.prob(nchan,:,:);
            ix                                  = unique(tmp);
            ix                                  = ix(ix~=0);
            
            if ~isempty(ix)
                
                i                               = i +1;
                subplot(nrow,ncol,i)
                hold on;
                
                cfg                             = [];
                cfg.channel                     = stat{nfeat}.label{nchan};
                cfg.p_threshold               	= p_limit;
                cfg.time_limit               	= stat{nfeat}.time([1 end]);
                cfg.color                      	= 'br';
                cfg.z_limit                     = z_limit;
                h_plotSingleERFstat_selectChannel(cfg,stat{nfeat},squeeze(alldata(:,nfeat,:)));
                
                nme                             = strsplit(stat{nfeat}.label{nchan},',');
                nme                             = nme{2};
                
                title([upper(nme) ' ' list_feat{nfeat} ' p = ' num2str(round(min(ix),3))]);
                set(gca,'FontSize',8,'FontName', 'Calibri');
                vline(0,'--k'); vline(1.2,'--k');
                
            end
        end
    end
end