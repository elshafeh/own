clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

if isunix
    project_dir              	= '/project/3015079.01/';
    start_dir                	= '/project/';
else
    project_dir              	= 'P:/3015079.01/';
    start_dir               	= 'P:/';
end

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    
    frequency_list              = {'broadband' 'theta' 'alpha' 'beta' 'gamma'}; % 
    decoding_list               = {'freq' 'ori'};
    cue_list                    = {'pre.freq' 'pre.ori' 'retro.ori' 'retro.freq'};
    lock_list                   = decoding_list; 
    
    for nfreq = 1:length(frequency_list)
        for nlock = 1:length(decoding_list)
            for ncue = 1:length(cue_list)
                
                pow             = [];
                ext_file        = '.correct.ninj.bsl.timegen.mat';
                
                if strcmp(frequency_list{nfreq},'broadband')
                    flist       = dir(['~/Dropbox/project_me/data/bil/decode/' subjectName '.1stgab.lock.' frequency_list{nfreq} ...
                        '.centered.cue.' cue_list{ncue}  '.decoding.1stgab.' decoding_list{nlock} ext_file]);
                else
                    flist       = dir(['~/Dropbox/project_me/data/bil/decode/' subjectName '.1stgab.lock.' frequency_list{nfreq} ...
                        '.minus1f.centered.cue.' cue_list{ncue}  '.decoding.1stgab.' decoding_list{nlock} ext_file]);
                end
                
                for nf = 1:length(flist)
                    fname 	= [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    pow(nf,:,:)	= scores; clear sources;
                end
                
                t1            	= find(round(time_axis,3) == round(0.1,3));
                t2           	= find(round(time_axis,3) == round(0.4,3));
                
                avg           	= [];
                avg.avg        	= [squeeze(mean(pow(:,t1:t2,:),2))]';
                avg.label       = decoding_list(nlock);
                avg.dimord      = 'chan_time';
                avg.time        = time_axis;
                
                alldata{nsuj,nfreq,nlock,ncue}         = avg; clear avg;
                
                
            end
        end
    end
end

%%

keep alldata *_list

list_test                               = [1 2; 1 3; 1 4; 2 3; 2 4;3 4];
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

            cfg.latency                 = [-0.1 3];
            
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

%%

close all; figure;


nrow                        = 4;
ncol                        = 4;

i                        	= 0;
zlimit                    	= [0.4 1; 0.4 1];
plimit                      = 0.11;

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
                cfg.z_limit    	= zlimit(ilock,:);
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
                
                set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
                
            end
        end
    end
end

keep alldata *_list stat list_name min_p