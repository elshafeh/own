clear ;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                                = [1:33 35:36 38:44 46:51]; %who_what_per_subject('stim_stack','auc.collapse'); %

for ns = 1:length(suj_list)
    
    for nback = [1 2 3]
        
        data                            = [];
        list_chan                       = {};
        list_lock                       = {'1st','2nd','3rd'};
        
        for nlock = [1 2 3]
            
            for nstim = 1:10
                
                fname                   = ['../data/decode_data/stim_stack/sub' num2str(suj_list(ns)) '.stim' num2str(nstim) '.' num2str(nback-1) 'back.' num2str(nlock-1) 'lock'];
                fname                   = [fname '.demean.2cv.auc.collapse.mat'];
                
                if exist(fname)
                    fprintf('loading %s\n',fname);
                    load(fname);
                    data                = [data;scores]; clear scores;
                    list_chan{end+1} 	= ['stim' num2str(nstim) ' ' list_lock{nlock} ' lock'];
                else
                    warning(['missing: ' fname]);
                end
                
            end
            
            fprintf('\n');
        end
        
        avg                         = [];
        avg.time                    = time_axis;
        avg.avg                     = data; clear data;
        avg.dimord                  = 'chan_time';
        avg.label                   = list_chan;
        
        alldata{ns,nback}         	= avg; clear avg;
        
    end
end

keep alldata

nb_suj                           	= size(alldata,1);
[design,neighbours]               	= h_create_design_neighbours(nb_suj,alldata{1,1},'gfp','t');

cfg                                 = [];
cfg.latency                         = [-0.2 5.5];
cfg.statistic                       = 'ft_statfun_depsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.clusterstatistic                = 'maxsum';
cfg.minnbchan                       = 0;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.uvar                            = 1;
cfg.ivar                            = 2;
cfg.neighbours                      = neighbours;
cfg.design                          = design;

list_index_stat                     = [1 2; 1 3; 2 3];

for nt = 1:size(list_index_stat,1)
    stat{nt}                     	= ft_timelockstatistics(cfg, alldata{:,list_index_stat(nt,1)}, alldata{:,list_index_stat(nt,2)});
end

for nt = 1:length(stat)
    [min_p(nt),p_val{nt}]           = h_pValSort(stat{nt});
end

keep stat alldata min_p p_val list_index_stat

i                                   = 0;
nrow                                = 2;
ncol                                = 2;
p_limit                             = 0.05;
z_limit                             = [0.45 0.7];
    
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
                
                list_name_stat      = {'0 v 1Back','0 v 2Back','1 v 2Back'};
                
                cfg                 = [];
                cfg.channel         = stat{nt}.label{nchan};
                cfg.p_threshold 	= p_limit;
                cfg.time_limit      = stat{nt}.time([1 end]);
                cfg.color         	= 'br';
                cfg.z_limit         = z_limit;
                h_plotSingleERFstat_selectChannel(cfg,stat{nt},squeeze(alldata(:,list_index_stat(nt,:))));
                
                nme                 = cfg.channel;
                
                if min(ix_stat) < 0
                    title([nme ' ' list_name_stat{nt} ' p = ' num2str(round(min(ix),3)) ' [-ve]']);
                else
                    title([nme ' ' list_name_stat{nt} ' p = ' num2str(round(min(ix),3)) ' [+ve]']);
                end
                
                set(gca,'FontSize',16,'FontName', 'Calibri');
                
                list_cond       = {'0 Back','1 Back','2 Back'};
                
                legend({list_cond{list_index_stat(nt,1)},'',list_cond{list_index_stat(nt,2)},''});
                
                vline(0,'--k'); 
                vline(2,'--k');
                vline(4,'--k');
                
            end
        end
    end
end