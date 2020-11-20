clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

behav_table                     = readtable('../doc/bil.behavioralReport.n34.keep.cor.keep.rt.txt');

load ../data/bil_goodsubjectlist.27feb20.mat

load /Users/heshamelshafei/Dropbox/project_me/data/bil/virt/sub001.virtualelectrode.wallis.mat;
chan_list = data.label; clear data;

for nsuj = 1:length(suj_list)
    
    list_cond                   = {'1t2Hz' '2t3Hz' '3t4Hz' '4t5Hz' '3t5Hz'};
    
    for ncond = 1:length(list_cond)
        
        freq                    = [];
        
        for nchan = 1:22
            
            subjectName      	= suj_list{nsuj};
            
            fname              	= ['~/Dropbox/project_me/data/bil/virt/' subjectName '.wallis.' ...
                list_cond{ncond} '.chan' num2str(nchan) '.gc.correct.pac.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);

            freq.powspctrm(nchan,:,:)           = py_pac.powspctrm;
            freq.time          	= py_pac.time;
            freq.freq         	= py_pac.freq;
            freq.label         	= chan_list;
            freq.dimord      	= 'chan_freq_time';
            
        end
        
        t1                    	= find(round(freq.time,3) == round(-0.4,3));
        t2                    	= find(round(freq.time,3) == round(-0.2,3));
        bsl                   	= mean(freq.powspctrm(:,:,t1:t2),3);
        
        % apply baseline correction
        freq.powspctrm       	= freq.powspctrm - bsl;
        alldata{nsuj,ncond}   	= freq; clear freq bsl t1 t2;clc;
        
    end
    
    find_suj             	= behav_table(strcmp(behav_table.suj,subjectName),:);
    find_correct        	= find_suj(find_suj.corr_rep == 1,:);
    allbehav{nsuj,1}    	= median(find_correct.react_time);
    allbehav{nsuj,2}       	= height(find_correct) ./ height(find_suj); clear find_*
    
    list_behav          	= {'mean rt' 'mean perc'};
    
    
end

keep all* list_*

%%

cfg                         = [];
cfg.method                  = 'montecarlo';
cfg.latency                 = [0 5.5];
cfg.frequency               = [7 30];
cfg.statistic               = 'ft_statfun_correlationT';
cfg.clusterstatistics       = 'maxsum';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 500;
cfg.ivar                    = 1;

i                           = 0;

for ncue = 1:size(alldata,2)
    for nbehav = 1:size(allbehav,2)
                
        nb_suj                  = size(alldata,1);
        cfg.type                = 'Spearman';
        cfg.design(1,1:nb_suj)	= [allbehav{:,nbehav}];
        
        [~,neighbours]          = h_create_design_neighbours(nb_suj,alldata{1,nbehav},'gfp','t');
        cfg.neighbours          = neighbours;
        
        i                       = i + 1;
        
        stat{i}                 = ft_freqstatistics(cfg, alldata{:,ncue});
        [min_p(i),p_val{i}]     = h_pValSort(stat{i});
        
        list_test{i}            = {[list_cond{ncue} ' with ' list_behav{nbehav}]};
        list_index{i,1}         = ncue;
        list_index{i,2}         = nbehav;
        
        
    end
end

keep all* list_* min_p p_val stat

%%

figure;

i                                           = 0;
nrow                                        = 4;
ncol                                        = 2;

plimit                                      = 0.2;
z_lim                                       = 5;

for ntest = 1:length(stat)
    
    statplot                             	= stat{ntest};
    statplot.mask                           = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        iy                               	= unique(tmp);
        iy                                 	= iy(iy~=0);
        iy                                 	= iy(~isnan(iy));
        
        tmp                             	= statplot.mask(nchan,:,:) .* statplot.rho(nchan,:,:);
        ix                               	= unique(tmp);
        ix                                 	= ix(ix~=0);
        ix                                 	= ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                             	= i + 1;
            
            cfg                            	= [];
            cfg.colormap                  	= brewermap(256, '*RdBu');
            cfg.channel                   	= nchan;
            cfg.parameter                  	= 'prob';
            cfg.maskparameter            	= 'mask';
            cfg.maskstyle                  	= 'outline';
            
            cfg.zlim                      	= [10e-9 plimit];
            cfg.ylim                        = statplot.freq([1 end]);
            cfg.xlim                        = statplot.time([1 end]);
            nme                           	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            
            ylabel(nme);
            xlabel('Time');
            title(list_test{ntest}); 
            
            
            xticks([0 1.5 3 4.5 5.5]);
            xticklabels({'1st cue' '1st gab' '2nd cue' '2nd gab' 'mean RT'});
            vline([0 1.5 3 4.5 5.5],'--k');
            
            set(gca,'FontSize',14,'FontName', 'Calibri');
            
            i                               = i + 1;
            subplot(nrow,ncol,i)
            avg_over_time                 	= squeeze(nanmean(tmp,3));            
            plot(statplot.freq,avg_over_time,'LineWidth',2);
            xlabel('Frequency');
            set(gca,'FontSize',14,'FontName', 'Calibri');
            xlim(statplot.freq([1 end]));
            ylabel('rho');
            title(['p = ' num2str(round(min(min(iy)),3))]);
            
        end
    end
end