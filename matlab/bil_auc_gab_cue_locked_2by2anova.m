clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    
    frequency_list          = {'broadband' 'theta.minus1f' 'alpha.minus1f' 'beta.minus1f' 'gamma.minus1f'};
    decoding_list           = {'freq' 'ori'};
    cue_list                = {'cue.pre.freq' 'cue.pre.ori' 'cue.retro.*' };
    
    lock_list               = decoding_list; 
    
    for nfreq = 1:length(frequency_list)
        for nlock = 1:length(lock_list)
            for ncue = 1:length(cue_list)
                
                avg      	= [];
                avg.avg   	= [];
                
                flist       = dir(['~/Dropbox/project_me/data/bil/decode/' subjectName '.1stgab.lock.' frequency_list{nfreq} ...
                    '.centered.' cue_list{ncue}  '.decoding.1stgab.' lock_list{nlock} '.correct.ninjauc.bsl.mat']);
                
                for nf = 1:length(flist)
                    fname 	= [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    avg.avg	= [avg.avg;scores]; clear sources;
                end
                
                
                avg.avg     = mean(avg.avg,1);
                avg.label 	= lock_list(nlock); 
                avg.dimord 	= 'chan_time';
                avg.time   	= time_axis;
                
                alldata{nsuj,nfreq,nlock,ncue}         = avg; clear avg;
                
                allchance{nsuj,nfreq}       = alldata{nsuj,nfreq,1};
                rnd_vct                     = 0.495:0.0001:0.505;
                
                for nc = 1:size(allchance{nsuj,nfreq}.avg,1)
                    for nt = 1:size(allchance{nsuj,nfreq} .avg,2)
                        allchance{nsuj,nfreq} .avg(nc,nt)    	= rnd_vct(randi(length(rnd_vct)));
                    end
                end
                
            end
        end
    end
end

keep alldata *_list allchance

list_test                               = [1 2; 1 3; 2 3];

list_name                               = {};
i                                       = 0;

for nfreq= 1:size(alldata,2)
    for nlock = 1:size(alldata,3)
        for ntest = 1:size(list_test,1)
            
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
            
            i                           = i +1;
            ix1                         = list_test(ntest,1);
            ix2                         = list_test(ntest,2);
            
            cfg.latency                 = [-0.1 1.5];
            
            list_name{i,1}          	= [frequency_list{nfreq} ' ' lock_list{nlock} ' '  cue_list{ix1} ' v ' cue_list{ix2}];
            stat{i}                     = ft_timelockstatistics(cfg, alldata{:,nfreq,nlock,ix1},alldata{:,nfreq,nlock,ix2});
            [min_p(i), p_val{i}]        = h_pValSort(stat{i});
            
            list_name{i,2}          	= min_p(i);
            list_name{i,3}          	= nfreq;
            list_name{i,4}          	= nlock;
            
            list_name{i,5}          	= ix1;
            list_name{i,6}          	= ix2;
            
            
        end
    end
end

keep alldata *_list stat list_name min_p

close all; figure;
nrow                    	= 4;
ncol                      	= 3;
i                        	= 0;
zlimit                    	= [0.45 0.8];
plimit                      = 0.15;

for ntest = 1:length(stat)
    
    if list_name{ntest,2} < plimit
        
        ifrq                = list_name{ntest,3};
        ilock               = list_name{ntest,4};
        i1                  = list_name{ntest,5};
        i2                  = list_name{ntest,6};
        
        nw_stat             = stat{ntest};
        nw_stat.mask        = nw_stat.prob < plimit;
        
        for nchan = 1:length(nw_stat.label)
            
            flg             = length(unique(nw_stat.mask(nchan,:)));
            
            if flg > 1
                
                cfg         	= [];
                cfg.channel    	= nchan;
                cfg.time_limit 	= nw_stat.time([1 end]);
                cfg.color     	= 'br';
                cfg.z_limit    	= zlimit;
                cfg.linewidth  	= 10;
                
                i = i+1;
                subplot(nrow,ncol,i);
                h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,squeeze(alldata(:,ifrq,ilock,[i1 i2])));
                
                ylabel({nw_stat.label{nchan}, ['p= ' num2str(round(list_name{ntest,2},3))]});
                title(list_name{ntest,1});
                
                vct_plt     = [0 1.5 3 4];
                
                vline(vct_plt,'--k');
                xticklabels({'1st G' '2nd Cue' '2nd G' 'RT'});
                xticks(vct_plt);
                
                hline(0.5,'--k');
                
            end
        end
    end
end

keep alldata *_list stat list_name min_p