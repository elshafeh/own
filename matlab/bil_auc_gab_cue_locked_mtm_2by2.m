clear;clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName           	= suj_list{nsuj};
    
    frequency_list        	= [1:50 55:5:100];
    cue_list            	= {'cue.pre.freq' 'cue.pre.ori' 'cue.retro.freq' 'cue.retro.ori'};
    lock_list           	= {'freq' 'ori'};
    
    
    for nlock = 1:length(lock_list)
        for ncue = 1:length(cue_list)
            
            freq            = [];
            freq.powspctrm	= [];
            
            for nfreq = 1:length(frequency_list)
                
                fname   	= ['M:/data/bil/decode/' subjectName '.1stgab.lock.' num2str(frequency_list(nfreq)) 'Hz.centered.' ...
                    cue_list{ncue}  '.decoding.1stgab.' lock_list{nlock} '.correct.ninjauc.mat'];
                
                fprintf('loading %s\n',fname);
                load(fname);
                
                freq.powspctrm(:,nfreq,:) =  scores; clear sources;
                
            end
            
            freq.label      = lock_list(nlock);
            freq.dimord 	= 'chan_freq_time';
            freq.time   	= time_axis;
            freq.freq   	= frequency_list;
            
            alldata{nsuj,nlock,ncue}         = freq; clear freq;
            
            
        end
    end
end

keep alldata *_list

list_test                   = [1 2; 1 3; 1 4; 2 3; 2 4;3 4];

list_name                 	= {};
i                       	= 0;

for nlock = 1:size(alldata,2)
    for ntest = 1:size(list_test,1)
        
        nsuj            	= size(alldata,1);
        [design,neighbours]	= h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;
        
        cfg                	= [];
        cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
        cfg.correctm     	= 'cluster';cfg.statistic = 'depsamplesT';
        cfg.uvar           	= 1;cfg.ivar = 2;
        cfg.tail           	= 0;cfg.clustertail  = 0;
        cfg.neighbours   	= neighbours;
        
        cfg.clusteralpha  	= 0.05; % !!
        cfg.minnbchan     	= 0; % !!
        cfg.alpha        	= 0.025;
        
        cfg.numrandomization        = 1000;
        cfg.design        	= design;
        
        i                 	= i +1;
        ix1              	= list_test(ntest,1);
        ix2              	= list_test(ntest,2);
        
        cfg.latency       	= [-0.1 3.5];
        %         cfg.frequency               = cfg.latency;
        
        list_name{i,1}      = [lock_list{nlock} ' '  cue_list{ix1} ' v ' cue_list{ix2}];
        stat{i}                     = ft_freqstatistics(cfg, alldata{:,nlock,ix1},alldata{:,nlock,ix2});
        [min_p(i), p_val{i}]        = h_pValSort(stat{i});
        
        list_name{i,2}      = min_p(i);
        
    end
end

keep alldata *_list stat list_name min_p

close all; figure;
nrow                    	= 3;
ncol                      	= 3;
i                        	= 0;
plimit                      = 0.15;

for ntest = 1:length(stat)
    
    if list_name{ntest,2} < plimit
        
        nw_stat             = stat{ntest};
        nw_stat.mask        = nw_stat.prob < plimit;
        
        for nchan = 1:length(nw_stat.label)
            
            flg             = length(unique(nw_stat.mask(nchan,:)));
            
            if flg > 1
                
                cfg                 = [];
                cfg.colormap        = brewermap(256, '*RdBu');
                cfg.channel         = nchan;
                cfg.parameter       = 'stat';
                cfg.maskparameter	= 'mask';
                cfg.maskstyle       = 'outline';
                cfg.zlim            = [-5 5];
                cfg.colorbar        ='yes';
                
                i = i+1;
                subplot(nrow,ncol,i);
                ft_singleplotTFR(cfg,nw_stat);
                
                ylabel({nw_stat.label{nchan}, ['p= ' num2str(round(list_name{ntest,2},3))]});
                title(list_name{ntest,1});
                
                vct_plt     = [0 1.5 3];
                vline(vct_plt,'--k');
                xticklabels({'1st G' '2nd Cue' '2nd G'});
                xticks(vct_plt);
                set(gca,'FontSize',14,'FontName', 'Calibri');
                
            end
        end
    end
end

keep alldata *_list stat list_name min_p