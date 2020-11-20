clear; global ft_default;
ft_default.spmversion = 'spm12';

list_suj                              	        = [1:33 35:36 38:44 46:51];

load ../data/stock/template_grid_0.5cm.mat

for nsuj  = 1:length(list_suj)
    
    list_cond                                   = {'0back.dwn70.target','1back.dwn70.target','2back.dwn70.target'};
    
    for ncond = 1:length(list_cond)
        
        sub_carr                              	= [];
        flist                                   = dir(['J:/temp/nback/data/source/coef/sub' num2str(list_suj(nsuj)) '.sess*.' list_cond{ncond} '.deocdingStim.coef.lcmv.mat']);
        
        for nf = 1:length(flist)
            fname                               = [flist(nf).folder filesep flist(nf).name];
            fprintf('loading %50s\n',fname);
            load(fname);
            sub_carr(nf,:,:)                    = [abs(data.avg)];
            time_axis                           = data.time;
        end
        
        clear data;
        
        sub_carr                            = squeeze(nanmean(sub_carr,1));
        
        t1                                  = find(round(time_axis,2) == round(-0.1,2));
        t2                                  = find(round(time_axis,2) == round(0,2));
        
        act                             	= sub_carr;
        bsl                                 = mean(sub_carr(:,t1:t2),2);
        
        pow                                 = nan(length(template_grid.inside),length(time_axis));
        pow(find(template_grid.inside==1),:) 	= (act-bsl)./bsl;
        
        [parcel_pow,parcel_name]            = h_source2parcel(pow,'../data/index/brain1vox.mat');
        
        avg                                 = [];
        avg.avg                             = parcel_pow;
        avg.label                           = parcel_name;
        avg.dimord                          = 'chan_time';
        avg.time                            = time_axis;
        
        list_unique                         = h_grouplabel(avg,'no');
        new_avg                           	= h_transform_avg(avg,list_unique(:,2),list_unique(:,1));
        
        alldata{nsuj,ncond}                 = new_avg; clear new_avg avg parcel_* pow
        
    end
end

keep alldata

list_color                          = 'rgb';

cfg                                 = [];
cfg.statistic                       = 'ft_statfun_depsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.latency                         = [-0.1 2];
cfg.clusterstatistic                = 'maxsum';
cfg.minnbchan                       = 0;
cfg.tail                            = 0;
cfg.clustertail                     = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.uvar                            = 1;
cfg.ivar                            = 2;

nbsuj                               = size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design                          = design;
cfg.neighbours                      = neighbours;


list_test                           = [1 2; 1 3; 2 3];

for nt = 1:size(list_test,1)
    stat{nt}                        = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]        	= h_pValSort(stat{ns});
    stat{ns}                        = rmfield(stat{ns},'negdistribution');
    stat{ns}                        = rmfield(stat{ns},'posdistribution');
    stat{ns}                        = rmfield(stat{ns},'cfg');
end

i                                  	= 0;
nrow                                = 1;
ncol                                = 3;
z_limit                             = [-0.1 4];
plimit                              = 0.05;

for ns = 1:length(stat)
    
    list_cond                   	= {'0back','1back','2back'};
    
    stat{ns}.mask                   = stat{ns}.prob < plimit;
    
    for nchan = 1:length(stat{ns}.label)
        
        tmp                         = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        if ~isempty(ix)
            
            i = i +1;
            subplot(nrow,ncol,i)
            
            cfg                     = [];
            cfg.channel             = stat{ns}.label{nchan};
            cfg.p_threshold        	= plimit;
            
            
            cfg.z_limit             = z_limit;
            cfg.time_limit          = stat{ns}.time([1 end]);
            
            ix1                     = list_test(ns,1);
            ix2                     = list_test(ns,2);
            
            cfg.color            	= list_color([ix1 ix2]);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{ns},squeeze(alldata(:,[ix1 ix2])));
            
            legend({list_cond{ix1},'',list_cond{ix2},''});
            
            nme_chan                = strsplit(stat{ns}.label{nchan},'.');
            
            if length(nme_chan) > 1
                nme_chan            = [nme_chan{1} ' ' nme_chan{end}];
            else
                nme_chan            = nme_chan{1};
            end
            
            %nme_chan
            
            title(nme_chan);%['p = ' num2str(round(min(ix),4))]);
            set(gca,'FontSize',16,'FontName', 'Calibri');
            vline(0,'--k');
            ylabel('coef');
            xlabel('time');
            
            %             subplot(nrow,ncol,nrow);
            %             plot_vct        = -log(tmp);
            %             plot_vct(isinf(plot_vct)) = 0;
            %             plot(stat{ns}.time,plot_vct,'-k','LineWidth',2);
            %
            %             xlim([cfg.time_limit]);
            %
            %             hline(-log(0.05),'--k','p=0.05');
            %             ylabel('-log10 p values');
            
        end
    end
end