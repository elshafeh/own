clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [1 2];
    list_cond                       = {'0back','1back','2back'};
    list_color                      = 'rgb';
    
    list_cond                       = list_cond(list_nback+1);
    list_color                      = list_color(list_nback+1);
    
    
    for nback = 1:length(list_nback)
        
        pow                         = nan(10,210);
        
        for nstim = 1:10
            
            file_list            	= dir(['K:\nback\stim_per_cond\sub' num2str(suj_list(nsuj)) '.sess*.stim' ...
                num2str(nstim) '.' num2str(list_nback(nback)) 'back.dwn70.1st.auc.mat']);
            tmp                  	= [];
            
            for nf = 1:length(file_list)
                fname             	= [file_list(nf).folder '\' file_list(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp               	= [tmp;scores]; clear fname;
            end
            
            if ~isempty(tmp)
                pow(nstim,:)    	= mean(tmp,1);
            end
            
            list_chan{nstim}       	= ['stim' num2str(nstim)];
            
        end
        
        avg                       	= [];
        avg.time               		= time_axis;
        
        avg.label                   = {'auc'};%list_chan;%
        avg.avg                   	= nanmean(pow,1);%pow;%
        
        if (size(avg.avg,2) ~= length(avg.time)) || (size(avg.avg,1) ~= length(avg.label))
            error('something wrong');
        end
        
        avg.dimord              	= 'chan_time';
        alldata{nsuj,nback}      	= avg; clear avg pow;
        
    end
end

keep alldata list_*

cfg                                         = [];
cfg.statistic                               = 'ft_statfun_depsamplesT';
cfg.method                                  = 'montecarlo';
cfg.correctm                                = 'cluster';
cfg.clusteralpha                            = 0.05;

cfg.latency                                 = [-0.2 2];

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

list_test                                   = [1 2];%; 1 3; 2 3];

for nt = 1:size(list_test,1)
    stat{nt}                                = ft_timelockstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
end

for ns = 1:length(stat)
    [min_p(ns),p_val{ns}]                	= h_pValSort(stat{ns});
    stat{ns}                              	= rmfield(stat{ns},'negdistribution');
    stat{ns}                              	= rmfield(stat{ns},'posdistribution');
end

i                                           = 0;
nrow                                        = 2;
ncol                                        = 2;
z_limit                                     = [0.0 1];
plimit                                      = 0.1;

for ns = 1:length(stat) 
    
    stat{ns}.mask                           = stat{ns}.prob < plimit;
    
    for nchan = 1:length(stat{ns}.label)
        
        tmp                                 = stat{ns}.mask(nchan,:,:) .* stat{ns}.prob(nchan,:,:);
        ix                                  = unique(tmp);
        ix                                  = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            
            nme                             = stat{ns}.label{nchan};
            
            cfg                             = [];
            cfg.channel                     = stat{ns}.label{nchan};
            cfg.p_threshold               	= plimit;
            
            
            cfg.z_limit                     = z_limit;
            cfg.time_limit                  = [-0.2 2];
            
            ix1                             = list_test(ns,1);
            ix2                             = list_test(ns,2);
            
            cfg.color                      	= list_color([ix1 ix2]);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{ns},squeeze(alldata(:,[ix1 ix2])));
                        
            legend({list_cond{ix1},'',list_cond{ix2},''});
            
            title([stat{ns}.label{nchan} ' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',16,'FontName', 'Calibri');
            
            hline(0.5,'--k');
            vline(0,'--k');
            
        end
    end
end