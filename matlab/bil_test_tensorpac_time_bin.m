clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

<<<<<<< HEAD
if isunix
    load /project/3015079.01/data/sub001/virt/sub001.virtualelectrode.wallis.mat;
else
    load P:/3015079.01/data/sub001/virt/sub001.virtualelectrode.wallis.mat;
end
=======
load ~/Dropbox/project_me/data/bil/virt/sub001.virtualelectrode.wallis.mat
>>>>>>> f7fa33757076df20223970f03ce355556bd4b93d
chan_list   = data.label; clear data;

for nsuj = 1:length(suj_list)
    
    bin_list                              	= {'bin1' 'bin5'};
    list_low                             	= {'1t3Hz' '3t5Hz'};
    
    for nfreq = 1:length(list_low)
        for ncond = 1:2
            
            freq                            = [];
            freq.powspctrm              	= [];
            
            for nchan = 1:22
                
                subjectName              	= suj_list{nsuj};
                
<<<<<<< HEAD
                if isunix
                    fname                	= ['/project/3015079.01/data/' subjectName '/pac/' subjectName];
                else
                    fname                	= ['P:/3015079.01/data/' subjectName '/pac/' subjectName];
                end
                
                fname                    	= [fname  '.wallis.' list_low{nfreq} '.chan' num2str(nchan) '.gc.itcorrect.' bin_list{ncond} '.pac.mat'];
=======
                fname                    	= '/Users/heshamelshafei/Dropbox/project_me/data/bil/virt/';%['/project/3015079.01/data/' subjectName '/pac/' subjectName];
                fname                    	= [fname subjectName '.wallis.' list_low{nfreq} '.chan' num2str(nchan) '.gc.' bin_list{ncond} '.pac.mat'];
>>>>>>> f7fa33757076df20223970f03ce355556bd4b93d
                fprintf('loading %s\n',fname);
                load(fname);
                
                freq.powspctrm(nchan,:,:) 	= py_pac.powspctrm;
                freq.time                	= py_pac.time;
                freq.freq               	= py_pac.freq;
                freq.label              	= chan_list;
                freq.dimord               	= 'chan_freq_time';
                
            end
            
            t1                            	= find(round(freq.time,3) == round(-0.4,3));
            t2                            	= find(round(freq.time,3) == round(-0.2,3));
            bsl                           	= mean(freq.powspctrm(:,:,t1:t2),3);
            
            % apply baseline correction
            freq.powspctrm                  = (freq.powspctrm - bsl) ./ bsl;
            
            alldata{nsuj,nfreq,ncond}    	= freq; clear freq bsl t1 t2;clc;
                        
        end
    end
end

keep alldata list_*

%%

<<<<<<< HEAD
% for ntest = 1:size(alldata,2)
%     
%     cfg                                   	= [];
%     cfg.statistic                         	= 'ft_statfun_depsamplesT';
%     cfg.method                          	= 'montecarlo';
%     cfg.correctm                         	= 'cluster';
%     cfg.clusteralpha                      	= 0.05;
%     cfg.latency                          	= [-0.5 5.5];
%     cfg.frequency                        	= [7 35];
%     cfg.clusterstatistic                  	= 'maxsum';
%     cfg.minnbchan                          	= 0;
%     cfg.tail                             	= 0;
%     cfg.clustertail                       	= cfg.tail;
%     cfg.alpha                             	= 0.025;
%     cfg.numrandomization                    = 1000;
%     cfg.uvar                            	= 1;
%     cfg.ivar                             	= 2;
%     
%     nbsuj                               	= size(alldata,1);
%     [design,neighbours]                 	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
%     
%     cfg.design                          	= design;
%     cfg.neighbours                          = neighbours;
%     
%     stat{ntest}                           	= ft_freqstatistics(cfg, alldata{:,ntest,1}, alldata{:,ntest,2});
%     [min_p(ntest),p_val{ntest}]             = h_pValSort(stat{ntest});
%     
% end

load ../data/stat/bil.1t3Hz.pac4paper.mat
=======
for ntest = 1:size(alldata,2)
    
    cfg                                   	= [];
    cfg.statistic                         	= 'ft_statfun_depsamplesT';
    cfg.method                          	= 'montecarlo';
    cfg.correctm                         	= 'cluster';
    cfg.clusteralpha                      	= 0.05;
    cfg.latency                          	= [-0.1 5.5];
    cfg.frequency                        	= [6 35];
    cfg.clusterstatistic                  	= 'maxsum';
    cfg.minnbchan                          	= 0;
    cfg.tail                             	= 0;
    cfg.clustertail                       	= cfg.tail;
    cfg.alpha                             	= 0.025;
    cfg.numrandomization                    = 1000;
    cfg.uvar                            	= 1;
    cfg.ivar                             	= 2;
    
    nbsuj                               	= size(alldata,1);
    [design,neighbours]                 	= h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');
    
    cfg.design                          	= design;
    cfg.neighbours                          = neighbours;
    
    stat{ntest}                           	= ft_freqstatistics(cfg, alldata{:,ntest,1}, alldata{:,ntest,2});
    [min_p(ntest),p_val{ntest}]             = h_pValSort(stat{ntest});
    
end
>>>>>>> f7fa33757076df20223970f03ce355556bd4b93d

%%

figure;

i                                           = 0;
nrow                                        = 3;
ncol                                        = 4;

plimit                                      = 0.3;
z_lim                                       = 5;

for ntest = 1:length(stat)
    
    statplot                             	= stat{ntest};
    statplot.mask                           = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        iy                               	= unique(tmp);
        iy                                 	= iy(iy~=0);
        iy                                 	= iy(~isnan(iy));
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.stat(nchan,:,:);
        ix                               	= unique(tmp);
        ix                                 	= ix(ix~=0);
        ix                                 	= ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                             	= i + 1;
            
            cfg                            	= [];
            cfg.colormap                  	= brewermap(256, 'RdBu');
            cfg.channel                   	= nchan;
            cfg.parameter                  	= 'stat';
            cfg.maskstyle               	= 'opacity';
            cfg.maskparameter           	= 'mask';
            cfg.maskalpha                	= 0.3;
            
            cfg.zlim                      	= [-z_lim z_lim];
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = statplot.time([1 end]);
            nme                           	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            
            ylabel(nme);
            xlabel('Time');
            title({list_low{ntest},['p = ' num2str(round(min(min(iy)),3))]});
            
            xticks([0 1.5 3 4.5 5.5]);
            xticklabels({'cue1' 'gab1' 'cue2' 'gab2' 'RT'});
            vline([0 1.5 3 4.5 5.5],'--k');
            
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            plot(statplot.freq,avg_over_time,'LineWidth',2);
            xlabel('Frequency');
            set(gca,'FontSize',10,'FontName', 'Calibri');
            xlim(statplot.freq([1 end]));
            ylabel('t values');
            
            
        end
    end
end