clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/');

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        list_ix_cue                 = {'DIS','fDIS'};
        list_method                 = {'FunConnectivity'};
        
        for ncue = 1:length(list_ix_cue)
            for nmethod = 1:length(list_method)
                
                fname_in            = ['../data/post_ol_conn_data/' suj '.' list_ix_cue{ncue} '.broadAudSchTPJMniPF.1t110Hz.m200p800msCov.' list_method{nmethod} '.Rearranged.mat'];
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                %                 for nchan = 1:length(freq_conn.label)
                %                     uscore = strfind(freq_conn.label{nchan},'_');
                %                     if ~isempty(uscore)
                %                         freq_conn.label{nchan}(uscore) = ' ';
                %                     end
                %                 end
                %
                %                 freq_conn.powspctrm             = 0.5 .* (log((1+freq_conn.powspctrm)./(1-freq_conn.powspctrm)));
                %
                %                 freq                            = [];
                %                 freq.time                       = freq_conn.time;
                %                 freq.freq                       = freq_conn.freq;
                %                 freq.dimord                     = 'chan_freq_time';
                %
                %                 freq.powspctrm                  = [];
                %                 freq.label                      = {};
                %
                %                 i                               = 0;
                %
                %                 load ../data_fieldtrip/index/broadAudSchTPJMniPFC.mat
                %
                %                 index_H(index_H(:,2) == 1 | index_H(:,2) == 3,2)    = 1;
                %                 index_H(index_H(:,2) == 2 | index_H(:,2) == 4,2)    = 2;
                %
                %                 index_H(index_H(:,2) == 5 | index_H(:,2) == 7 | index_H(:,2) == 9,2)    = 3;
                %                 index_H(index_H(:,2) == 6 | index_H(:,2) == 8 | index_H(:,2) == 10,2)   = 4;
                %
                %                 index_H(index_H(:,2) == 11,2)   = 5;
                %                 index_H(index_H(:,2) == 12,2)   = 6;
                %
                %                 list_H                          = {'pfcLeft','pfcRight','audLeft','audRight','tpjLeft','tpjRight'};
                %
                %                 transform_freq.perform          = 'yes';
                %                 transform_freq.index            = {};
                %                 transform_freq.label            = {};
                %
                %                 for nolivier = 1:length(list_H)
                %                     transform_freq.index{nolivier} = find(index_H(:,2) == nolivier);
                %                     transform_freq.label{nolivier} = list_H{nolivier};
                %                 end
                %
                %                 list_chan_seed    =  1:length(list_H);
                %                 list_chan_target  =  1:length(list_H);
                %
                %                 conn_done         = [];
                %
                %                 fprintf('Rearranging Connectivity for %s\n',suj);
                %
                %                 for nseed = 1:length(list_chan_seed)
                %                     for ntarget = 1:length(list_chan_target)
                %
                %                         if list_chan_seed(nseed) ~= list_chan_target(ntarget)
                %
                %                             if ~isempty(conn_done)
                %
                %                                 check1                  = conn_done(conn_done(:,1) == list_chan_seed(nseed) & conn_done(:,2) == list_chan_target(ntarget),:);
                %                                 check2                  = conn_done(conn_done(:,2) == list_chan_seed(nseed) & conn_done(:,1) == list_chan_target(ntarget),:);
                %
                %                             else
                %
                %                                 check1                  = [];
                %                                 check2                  = [];
                %
                %
                %                             end
                %
                %                             if isempty(check1) && isempty(check2)
                %
                %                                 i                           = i + 1;
                %                                 seed                        = freq_conn.powspctrm(transform_freq.index{list_chan_seed(nseed)},transform_freq.index{list_chan_target(ntarget)},:,:);
                %
                %                                 seed                        = squeeze(mean(seed,1));
                %                                 seed                        = squeeze(mean(seed,1));
                %
                %
                %                                 freq.powspctrm(i,:,:)       = seed;
                %
                %                                 freq.label{i}               = [transform_freq.label{nseed} ' with ' transform_freq.label{ntarget}];
                %
                %                                 conn_done(i,1)              = list_chan_seed(nseed);
                %                                 conn_done(i,2)              = list_chan_target(ntarget);
                %
                %                             end
                %                         end
                %                     end
                %                 end
                %
                %                 fname_out = ['../data_fieldtrip/dis_conn_virtual/' suj '.' list_ix_cue{ncue} '.broadAudSchTPJMniPF.1t110Hz.m200p800msCov.' list_method{nmethod} '.Rearranged.mat'];
                %                 fprintf('Saving %s\n',fname_out);
                %                 save(fname_out,'freq','-v7.3');
                
                if ncue == 1
                    allsuj_activation{ngroup}{sb,1,1}   = freq;
                else
                    %                     freq.powspctrm(:)                   = 0;
                    allsuj_baselineRep{ngroup}{sb,1,1}  = freq;
                end
                
                clear freq
                
                %                 [tmp{1},tmp{2}]                                 = h_prepareBaseline(freq,[-0.6 -0.2],[7 40],[-0.2 1.2],'no');
                %                 allsuj_activation{ngroup}{sb,ncue,nmethod}      = tmp{1};
                %                 allsuj_baselineRep{ngroup}{sb,ncue,nmethod}     = tmp{2};
                %
                %                 clear tmp freq ;
                
            end
        end
    end
end

clearvars -except allsuj_* list_ix_cue;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                    = size(allsuj_activation{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        for nmethod = 1:size(allsuj_activation{ngroup},3)
            
            cfg                     = [];
            cfg.clusterstatistic    = 'maxsum';
            cfg.method              = 'montecarlo';
            cfg.statistic           = 'depsamplesT';
            cfg.neighbours          = neighbours;
            
            cfg.correctm            = 'cluster';
            
            cfg.latency             = [-0.1 0.4];
            cfg.frequency           = [25 110];
            
            %             cfg.avgovertime         = 'yes';
            
            %             cfg.avgoverfreq         = 'yes';
            
            cfg.clusteralpha        = 0.005;
            
            cfg.alpha               = 0.025;
            cfg.minnbchan           = 0;
            
            cfg.tail                = 0;
            cfg.clustertail         = 0;
            
            cfg.numrandomization    = 1000;
            cfg.design              = design;
            cfg.uvar                = 1;
            cfg.ivar                = 2;
            
            stat{ngroup,ncue,nmethod}      = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue,nmethod},allsuj_baselineRep{ngroup}{:,ncue,nmethod});
            
        end
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for nmethod = 1:size(stat,3)
            [min_p(ngroup,ncue,nmethod),p_val{ngroup,ncue,nmethod}] = h_pValSort(stat{ngroup,ncue,nmethod});
        end
    end
end

clear i;
i = 0;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for nmethod = 1:size(stat,3)
            
            plimit                  = 0.05;
            
            stat_to_plot            = stat{ngroup,ncue,nmethod};
            stat_to_plot.mask       = stat_to_plot.prob < plimit;
            
            pow_to_plot             = [];
            pow_to_plot.dimord      = stat_to_plot.dimord;
            pow_to_plot.freq        = stat_to_plot.freq;
            pow_to_plot.time        = stat_to_plot.time;
            pow_to_plot.label       = stat_to_plot.label;
            data                    = stat_to_plot.stat .* stat_to_plot.mask;
            tlimit                  = nanmean(nanmean(nanmean(data)));
            data(data< tlimit)        = 0; % 1.323   1.721   2.080   2.518   2.831   3.527
            
            pow_to_plot.powpsctrm   = data;
            z_limit                 = 10;
            
            for nchan = 1:length(pow_to_plot.label)
                
                i                  = i + 1;
                subplot(5,3,i)
                [x_ax,y_ax,z_ax]    = size(pow_to_plot.powpsctrm);
                
                
                if y_ax == 1
                    
                    plot(pow_to_plot.time,squeeze(pow_to_plot.powpsctrm(nchan,:,:)));
                    ylim([-z_limit z_limit]);
                    xlim([pow_to_plot.time(1) pow_to_plot.time(end)])
                    
                elseif z_ax == 1
                    
                    plot(pow_to_plot.freq,squeeze(pow_to_plot.powpsctrm(nchan,:,:)));
                    ylim([-z_limit z_limit]);
                    xlim([pow_to_plot.freq(1) pow_to_plot.freq(end)])
                    
                else
                    
                    cfg                 = [];
                    cfg.channel         = nchan;
                    cfg.parameter       = 'powpsctrm';
                    
                    cfg.zlim            = [-z_limit z_limit];
                    ft_singleplotTFR(cfg,pow_to_plot);
                    
                    vline(0.1,'--k');
                    vline(0.3,'--k');
                    hline(60,'--k');
                    hline(100,'--k');
                    
                end
                
                title(stat_to_plot.label{nchan})
                
            end
        end
    end
end

% plimit                  = 0.05;
%
% stat_to_plot            = stat{1,1,1};
% stat_to_plot.mask       = stat_to_plot.prob < plimit;
%
% pow_to_plot             = [];
% pow_to_plot.dimord      = stat_to_plot.dimord;
% pow_to_plot.freq        = stat_to_plot.freq;
% pow_to_plot.time        = stat_to_plot.time;
% pow_to_plot.label       = stat_to_plot.label;
% pow_to_plot.powpsctrm   = stat_to_plot.stat .* stat_to_plot.mask;
%
% z_limit                 = 10;

% for nfigure = 1:2
%     
%     figure;
%     clear i;
%     i = 0;
% 
%     for nchan = 1:length(pow_to_plot.label)
%         
%         i                  = i + 1;
%         subplot(5,3,i)
%         [x_ax,y_ax,z_ax]    = size(pow_to_plot.powpsctrm);
%         
%         
%         if y_ax == 1
%             
%             plot(pow_to_plot.time,squeeze(pow_to_plot.powpsctrm(nchan,:,:)));
%             ylim([-z_limit z_limit]);
%             xlim([pow_to_plot.time(1) pow_to_plot.time(end)])
%             
%         elseif z_ax == 1
%             
%             plot(pow_to_plot.freq,squeeze(pow_to_plot.powpsctrm(nchan,:,:)));
%             ylim([-z_limit z_limit]);
%             xlim([pow_to_plot.freq(1) pow_to_plot.freq(end)])
%             
%         else
%             
%             if nfigure == 1
%                 
%                 avg_data_to_plot    = squeeze(pow_to_plot.powpsctrm(nchan,:,:));
%                 avg_data_to_plot    = mean(avg_data_to_plot,2);
%                 plot(pow_to_plot.freq,avg_data_to_plot);
%                 ylim([0 z_limit]);
%                 xlim([pow_to_plot.freq(1) pow_to_plot.freq(end)])
%                 
%             else
%                 avg_data_to_plot    = squeeze(pow_to_plot.powpsctrm(nchan,:,:));
%                 avg_data_to_plot    = mean(avg_data_to_plot,1);
%                 plot(pow_to_plot.time,avg_data_to_plot);
%                 ylim([-z_limit z_limit]);
%                 xlim([pow_to_plot.time(1) pow_to_plot.time(end)])
%                 
%             end
%             %                     cfg                 = [];
%             %                     cfg.channel         = nchan;
%             %                     cfg.parameter       = 'powpsctrm';
%             %                     cfg.zlim            = [0 1];
%             %                     ft_singleplotTFR(cfg,pow_to_plot);
%             %                     vline(0.1,'--k');
%             %                     vline(0.3,'--k');
%             %                     hline(60,'--k');
%             %                     hline(100,'--k');
%             
%         end
%         
%         title(stat_to_plot.label{nchan})
%         
%     end
% end

