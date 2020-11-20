% the idea here is to contrast attended and non-attended for each cue (and
% frequency) separately

clear;clc;
addpath('../toolbox/sigstar-master/');

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                 = suj_list{nsuj};
    
    list_cue                                    = {'pre' 'retro'};
    list_task                                   = {'ori' 'freq'};
    list_decode                                 = {'ori' 'freq'};
    
    frequency_list                              = {'theta' 'alpha' 'beta' 'gamma'};
    
    ext_match                                   = 'correct';
    
    
    lock_list                                   = {'decoding.1stgab'};
    new_data                                    = [];
    
    for nfreq = 1:length(frequency_list)
        for ncue = 1:length(list_cue)
            
            avg_data{1}                         = []; % attended
            avg_data{2}                         = []; % unattended
            
            for ntask = 1:length(list_task)
                for ndeco = 1:length(list_decode)
                    
                    ext_cue                 	= list_cue{ncue};
                    ext_task                	= list_task{ntask};
                    ext_feat                  	= list_decode{ndeco};
                    
                    fname = ['I:/bil/decode/' subjectName '.1stgab.lock.' frequency_list{nfreq} '.centered.cue.' ...
                        ext_cue '.'  ext_task '.decoding.1stgab.' ext_feat '.correct.nonmatch.ninjauc.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    if strcmp(ext_feat,ext_task)
                        avg_data{1}             = [avg_data{1};scores]; clear scores;
                    else
                        avg_data{2}             = [avg_data{2};scores]; clear scores;
                    end
                    
                end
            end
            
            for natt = 1:2
                avg                         = []; clc;
                avg.label                   = {'decoding 1st Gab'};
                avg.dimord                 	= 'chan_time';
                avg.time                   	= time_axis;
                avg.avg                     = [mean(avg_data{natt},1)];
                alldata{nsuj,nfreq,ncue,natt}  	= avg; clear all_scores avg;
            end
            
        end
    end
end

keep alldata *_list list_*

for nfreq= 1:size(alldata,2)
    for ncue = 1:size(alldata,3)
        
        nsuj                        = size(alldata,1);
        [design,neighbours]         = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;
        
        cfg                         = [];
        cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
        cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
        cfg.uvar                    = 1;cfg.ivar = 2;
        cfg.tail                    = 0;cfg.clustertail  = 0;
        cfg.neighbours              = neighbours;
        
        cfg.clusteralpha            = 0.05; % !!
        cfg.minnbchan               = 0; % !!
        cfg.alpha                   = 0.025;
        
        cfg.numrandomization        = 1000;
        cfg.design                  = design;
        
        cfg.latency                 = [-0.1 3.5];
        
        list_name{nfreq,ncue}     	= [frequency_list{nfreq} ' ' list_cue{ncue} ' attended (b) - unattended (r)'];
        
        stat{nfreq,ncue}        	= ft_timelockstatistics(cfg, alldata{:,nfreq,ncue,1},alldata{:,nfreq,ncue,2});
        [min_p(nfreq,ncue), p_val{nfreq,ncue}]        = h_pValSort(stat{nfreq,ncue});
        
    end
end

keep alldata *_list list_* *_list stat list_name min_p

close all; figure;
nrow                            = 3;
ncol                            = 2;
i                               = 0;

zlimit                          = [0.7 0.7 0.7 0.7 0.7 0.7];
plimit                          = 0.2;

for nfreq= 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        if min_p(nfreq,ncue) < plimit
            
            nw_stat             = stat{nfreq,ncue};
            nw_stat.mask        = nw_stat.prob < plimit;
            
            for nchan = 1:length(nw_stat.label)
                
                flg             = length(unique(nw_stat.mask(nchan,:)));
                
                if flg > 1
                    
                    i = i+1;
                    
                    cfg         	= [];
                    cfg.channel    	= nchan;
                    cfg.time_limit 	= nw_stat.time([1 end]);
                    cfg.color     	= 'br';
                    cfg.z_limit    	= [0.46 zlimit(i)];
                    cfg.linewidth  	= 5;
                    
                    subplot(nrow,ncol,i);
                    h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,squeeze(alldata(:,nfreq,ncue,:)));
                    
                    title({nw_stat.label{nchan}, ['p= ' num2str(round(min_p(nfreq,ncue),3))]});
                    ylabel(list_name{nfreq,ncue});
                    
                    vct_plt     = [0 1.5 3];
                    
                    vline(vct_plt,'--k');
                    xticklabels({'1st G' '2nd Cue' '2nd G'});
                    xticks(vct_plt);
                    
                    hline(0.5,'--k');
                    
                end
            end
        end
    end
end

keep alldata *_list list_* *_list stat list_name min_p