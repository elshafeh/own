clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                          	= suj_list{nsuj};
    list_cond                               = {'itc.bin1' 'itc.bin5'};
    
    for ncond = 1:length(list_cond)
        
        fname                               = ['~/Dropbox/project_me/data/bil/virt/' subjectName '.wallis.' list_cond{ncond} '.plv.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        test_done                        	= {};
        chan_label                       	= {};
        data                            	= [];
        i                                   = 0;
        
        for xi = [1] % [9 13 16]
            for yi = 1:length(coh.label)
                
                if xi ~= yi
                    
                    str_check_1         	= [num2str(xi) '.' num2str(yi)];
                    str_fnd_1             	= find(strcmp(test_done,str_check_1));
                    
                    str_check_2            	= [num2str(yi) '.' num2str(xi)];
                    str_fnd_2            	= find(strcmp(test_done,str_check_2));
                    
                    
                    if isempty(str_fnd_1) && isempty(str_fnd_2)
                        
                        i                   = i + 1;
                        
                        tmp             	= squeeze(coh.cohspctrm(xi,yi,:,:,:));
                        data(i,:,:)         = tmp; clear tmp;
                        test_done           = [test_done; [num2str(xi) '.' num2str(yi)]; [num2str(yi) '.' num2str(xi)]];
                        chan_label          = [chan_label; [coh.label{xi} ' to ' coh.label{yi}]];
                        
                    end
                    
                end
                
            end
        end
        
        keep coh data nsuj suj_list ncond list_cond subjectName chan_label alldata
        
        freq                                = [];
        freq.powspctrm                      = data; clear data;
        freq.freq                           = coh.freq;
        freq.time                           = coh.time;
        freq.label                          = chan_label;
        freq.dimord                         = 'chan_freq_time';
        
        alldata{nsuj,ncond}                 = freq ; clear freq chan_label;
        
    end
    
end

keep alldata list_cond

%%

list_test                               = [1 2];
list_name                               = {};
i                                       = 0;

for ntest = 1:size(list_test,1)
    
    nsuj                                = size(alldata,1);
    [design,neighbours]                 = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;
    
    cfg                                 = [];
    cfg.clusterstatistic                = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                        = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                            = 1;cfg.ivar = 2;
    cfg.tail                            = 0;cfg.clustertail  = 0;
    cfg.neighbours                      = neighbours;
    
    cfg.clusteralpha                    = 0.05; % !!
    cfg.minnbchan                       = 0; % !!
    cfg.alpha                           = 0.025;
    
    cfg.numrandomization                = 500;
    cfg.design                          = design;
    
    i                                   = i +1;
    ix1                                 = list_test(ntest,1);
    ix2                                 = list_test(ntest,2);
    
    cfg.latency                         = [0 5.5];
    cfg.frequency                       = [2 35];
    
    list_name{i}                        = [[list_cond{ix1}] ' versus ' [list_cond{ix2}]];
    stat{i}                             = ft_freqstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]                = h_pValSort(stat{i});
    
end

%%

close all;

plimit                                  = 0.2;

figure;
nrow                                    = 2;
ncol                                    = 2;
i                                       = 0;

for ntest = 1:length(stat)
    
    ix1                                 = list_test(ntest,1);
    ix2                                 = list_test(ntest,2);
    
    if min_p(ntest) < plimit
        
        
        statplot                     	= stat{ntest};
        statplot.mask                   = statplot.prob < plimit;
        
        for nchan = 1:length(statplot.label)
            
            tmp                        	= statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
            iy                        	= unique(tmp);
            iy                       	= iy(iy~=0);
            iy                          = iy(~isnan(iy));
            
            tmp                       	= statplot.mask(nchan,:,:) .* statplot.stat(nchan,:,:);
            ix                      	= unique(tmp);
            ix                      	= ix(ix~=0);
            ix                          = ix(~isnan(ix));
            
            if ~isempty(ix)
                
                i                             	= i + 1;
                
                cfg                   	= [];
                cfg.colormap          	= brewermap(256, '*RdBu');
                cfg.channel           	= nchan;
                cfg.parameter         	= 'stat';
                cfg.maskparameter     	= 'mask';
                cfg.maskstyle       	= 'outline';
                cfg.ylim             	= statplot.freq([1 end]);
                cfg.xlim             	= statplot.time([1 end]);
                
                subplot(nrow,ncol,i);
                ft_singleplotTFR(cfg,statplot);
                
                title({list_name{ntest},statplot.label{nchan}});
                ylabel([' p = ' num2str(round(min(min(iy)),3))]);
                vct_plt                 = [0 1.5 3 4.5 5.5];
                
                vline(vct_plt,'--k');
                xticklabels({'Cue1' 'Gab1' 'Cue2' 'Gab2' 'RT'}); % '1st Cue'
                xticks(vct_plt);
                
                set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
                
                
            end
        end
    end
end