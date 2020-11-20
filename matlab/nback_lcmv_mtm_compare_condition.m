clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

i                                               = 0;

for n_suj = 1:51

    chk                                         = dir(['J:/temp/nback/data/voxbrain/tf/sub' num2str(n_suj) '*.mat']);

    if ~isempty(chk)

        i                                       = i + 1;

        for nback = [0 1 2]

            t                                   = 0;

            for n_ses = 1:2

                fname                           = ['J:/temp/nback/data/voxbrain/tf/sub' num2str(n_suj) '.session' num2str(n_ses) '.brain1vox.' num2str(nback) 'back.1t30Hz.1HzStep.mat'];

                if exist(fname)
                    
                    t  = t+1;
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    fname                       = ['J:/temp/nback/data/voxbrain/tf/sub' num2str(n_suj) '.session' num2str(n_ses) '.brain1vox.alphabetapeak.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    allpeaks(isnan(allpeaks(:,1)),1)     = nanmean(allpeaks(:,1));
                    allpeaks(isnan(allpeaks(:,2)),2)     = nanmean(allpeaks(:,2));

                    pow                      	= [];
                    
                    indx_freq                   = 2;
                    bnd_width                   = 1;
                    
                    for nchan = 1:length(freq.label)
                        f1                     	= find(round(freq.freq) == round(allpeaks(nchan,indx_freq) - bnd_width));
                        f2                    	= find(round(freq.freq) == round(allpeaks(nchan,indx_freq) + bnd_width));
                        pow(nchan,:)         	= squeeze(mean(freq.powspctrm(nchan,f1:f2,:),2));
                    end
                    
                    avg                       	= [];
                    avg.label               	= freq.label;
                    avg.time                    = freq.time;
                    avg.dimord                	= 'chan_time';
                    avg.avg                   	= pow; clear pow bsl t1 t2 f1 f2 allpeaks;
                    
                    tmp{t}                      = avg; clear avg;
                    
                end
            end

            if length(tmp) == 1
                avg                             = tmp{1};
            else
                avg                             = ft_timelockgrandaverage([],tmp{:});
            end
            
            t1                                  = find(round(avg.time,2) == round(-0.21,2));
            t2                                  = find(round(avg.time,2) == round(0,2));
            bsl                                 = mean(avg.avg(:,t1:t2),2);
            avg.avg                           	= (avg.avg - bsl) ./ bsl;
            
            alldata{i,nback+1}                  = avg; clear avg

            clear tmp;

        end
    end
end

keep alldata

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;

cfg.latency                                 = [-0.2 1.5];

cfg.clusterstatistic                        = 'maxsum';
cfg.minnbchan                               = 0;
cfg.tail                                    = 0;
cfg.clustertail                             = 0;
cfg.alpha                                   = 0.025;
cfg.numrandomization                        = 1000;
cfg.uvar                                    = 1;
cfg.ivar                                    = 2;

nbsuj                                       = size(alldata,1);
[design,neighbours]                         = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                                  = design;
cfg.neighbours                              = neighbours;

list_test                                   = [1 2; 1 3; 2 3];

for ns = 1:3
    stat{ns}                                = ft_timelockstatistics(cfg, alldata{:,list_test(ns,1)}, alldata{:,list_test(ns,2)});
end

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]                   = h_pValSort(stat{ns});
    stat{ns}                                = rmfield(stat{ns},'negdistribution');
    stat{ns}                             	= rmfield(stat{ns},'posdistribution');
end

close all;

for ns = 1:length(stat)
    
    figure;
    i                                     	= 0;
    
    list_p                                  = [0.1 0.1 0.1];
    list_row                                = [2 4 2];
    list_col                                = [2 4 2]; 
    
    plimit                                 	= list_p(ns);
    nrow                                 	= list_row(ns);
    ncol                                   	= list_col(ns);
    
    stat{ns}.mask                           = stat{ns}.prob < plimit;
    
    for nchan = 1:length(stat{ns}.label)
        
        tmp                                 = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            cfg                             = [];
            cfg.channel                     = stat{ns}.label{nchan};
            cfg.p_threshold                 = plimit;
            cfg.time_limit                  = stat{ns}.time([1 end]);
            cfg.z_limit                     = [-0.5 0.5];
            cfg.color                       = 'br';
            h_plotSingleERFstat_selectChannel(cfg,stat{ns},alldata(:,list_test(ns,:)));
            
            nme                             = strsplit(stat{ns}.label{nchan},',');
            nme                             = nme{2};
            
            list_name                       = {'0v1','0v2','1v2'};
            
            title([upper(nme) ' ' list_name{ns} ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',8,'FontName', 'Calibri');
            vline(0,'--k'); hline(0,'--k');
            
            %             list_back                       = {'0back','1back','2back'};
            %             legend({list_back{list_test(ns,1)} , '' , list_back{list_test(ns,2)} ''});
            
        end
    end
end