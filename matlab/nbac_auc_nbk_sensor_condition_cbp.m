clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

i                                   = 0;

for nsuj = [1:33 35:36 38:44 46:51]
    
    i                               = i +1;
    tmp                             = [];
    
    list_condition                  = {'0v1B','0v2B','1v2B'};
    
    for n_con = 1:length(list_condition)
        
        fname                       = ['~/Dropbox/project_me/data/nback/decode_data/nback/sub' num2str(nsuj) '.' list_condition{n_con} '.auc.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        
        load nbk_time_axis.mat
        
        avg                        	= [];
        avg.label                 	= {'auc'};
        avg.dimord                	= 'chan_time';
        avg.time                  	= time_axis;
        avg.avg                   	= scores;
        
        alldata{i,n_con}           	= avg; clear avg;
        
    end
end

keep alldata;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                         = [];
cfg.latency                                 = [-0.2 6];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusterstatistic                        = 'maxsum';
cfg.clusteralpha                            = 0.05;
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

cfg.neighbours                              = neighbours;
cfg.design                                  = design;

list_index_stat                             = [1 2; 1 3; 2 3];

for nt = 1:size(list_index_stat,1)
    stat{nt}                                = ft_timelockstatistics(cfg, alldata{:,list_index_stat(nt,1)}, alldata{:,list_index_stat(nt,2)});
end

for ntest = 1:size(alldata,2)
    [min_p(ntest),p_val{ntest}]             = h_pValSort(stat{ntest});
end

i                                           = 0;
nrow                                        = 2;
ncol                                        = 1;
p_limit                                     = 0.05;
z_limit                                     = [0.49 0.65];
    
for nt = 1:length(stat)
    
    if min_p(nt) < p_limit
        
        stat{nt}.mask               = stat{nt}.prob < p_limit;
        
        for nchan = 1:length(stat{nt}.label)
            
            tmp                     = stat{nt}.mask(nchan,:,:) .* stat{nt}.prob(nchan,:,:);
            tmp_stat                = stat{nt}.mask(nchan,:,:) .* stat{nt}.stat(nchan,:,:);
            
            ix                      = unique(tmp);
            ix                      = ix(ix~=0);
            
            ix_stat                 = unique(tmp_stat);
            ix_stat                 = ix_stat(ix_stat~=0);
            
            if ~isempty(ix)
                
                i                   = i +1;
                subplot(nrow,ncol,i)
                hold on;
                
                list_name_stat      = {'0-1 Back','0-2 Back','1-2 Back'};
                
                cfg                 = [];
                cfg.channel         = stat{nt}.label{nchan};
                cfg.p_threshold 	= p_limit;
                cfg.time_limit      = stat{nt}.time([1 end]);
                
                list_color          = 'bgm';
                cfg.color           = list_color(list_index_stat(nt,:));
                
                cfg.z_limit         = z_limit;
                h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,list_index_stat(nt,:))));
                
                nme                 = cfg.channel;
                
                cond1               = list_name_stat{list_index_stat(nt,1)};
                cond2               = list_name_stat{list_index_stat(nt,2)};

                title([cond1 ' vs ' cond2]);%  ' p = ' num2str(round(min(ix),3))]);
                
                set(gca,'FontSize',20,'FontName', 'Calibri');
                                
                legend({cond1,'',cond2,''});
                
                vline(0,'--k'); 
                vline(2,'--k');
                vline(4,'--k');
                
                ylabel('Accuracy');
                xlabel('Time (s)');
                
            end
        end
    end
end