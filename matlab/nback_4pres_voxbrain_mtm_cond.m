clear; global ft_default; close all;
ft_default.spmversion = 'spm12';

list_suj          	= [1:33 35:36 38:44 46:51];

% load('J:temp\nback\data\voxbrain\preproc\sub1.session1.brain1vox.mat');
% list_chan         	= h_grouplabel(data,'no');
% list_chan           = list_chan(:,1);
% nroi=24;data.label{list_chan{nroi,2}}

list_chan           = {'Amygdala','Basal ganglia','Cingulate gryus','fusiform gyrus','Hippocampus','Inferior frontal gyrus',...
    'Insular gyrus','Inferior pareital lobule','Inferior temporal gyrus','lateral occipital cortex','Middle frontal gyrus','Middle temporal gyrus', ...
    'MedioVentral Occipital cortex','Orbital gryus','Paracentral lobule','Precuneus','Parhippocampal Gyrus','Postcentral gyrus',...
    'Precentral gyrus','Superior Frontal Gyrus','Superior parietal Lobule','Superior temporal gyrus','Thalamus','Posterior superior temporal sulcus'};

keep list_*

for nsuj  = 1:length(list_suj)
    
    list_cond                	= {'decoding.0back','decoding.1back'};
    list_freq               	= 1:30;
    
    for ncond = 1:length(list_cond)
        for nfreq  = 1:length(list_freq)
            tmp     = [];
            
            flist   = dir(['P:/3015079.01/nback/vox_auc/sub' num2str(list_suj(nsuj)) '.sess*.' ...
                list_cond{ncond} '.' num2str(list_freq(nfreq)) 'Hz.lockedon.all.bsl.excl.bychan.auc.mat']);
            
            for nf = 1:length(flist)
                fname       	= [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %50s\n',fname);
                load(fname);
                tmp(nf,:,:)     = scores; clear scores
            end
            
            pow(:,nfreq,:)      = squeeze(nanmean(tmp,1)); clear tmp;
            
        end
        
        
        freq                  	= [];
        freq.time            	= time_axis;
        freq.label             	= list_chan;
        freq.freq              	= list_freq;
        freq.powspctrm        	= pow;
        freq.dimord          	= 'chan_freq_time';
        
        alldata{nsuj,ncond}   	= freq; clear freq pow;
        
    end
    
    alldata{nsuj,3} = alldata{nsuj,1};
    alldata{nsuj,3}.powspctrm(:)= 0.5;
    
end

keep alldata list_*;

list_cond           = {'0and2','1and2','chance'};

cfg                 = [];
cfg.statistic       = 'ft_statfun_depsamplesT';
cfg.method          = 'montecarlo';
cfg.correctm        = 'cluster';
cfg.clusteralpha    = 0.05;
cfg.latency         = [-0.1 1.5];
cfg.channel         = [3 4 6 8 9 10 11 12 13 15 16 18 19 20 21 22 24];
cfg.frequency       = [3 30];
cfg.clusterstatistic= 'maxsum';
cfg.minnbchan       = 0;
cfg.tail            = 0;
cfg.clustertail     = 0;
cfg.alpha           = 0.025;
cfg.numrandomization= 1000;
cfg.uvar            = 1;
cfg.ivar            = 2;

nbsuj               = size(alldata,1);
[design,neighbours] = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg.design          = design;
cfg.neighbours      = neighbours;

list_test           = [1 3; 2 3; 1 2];

for nt = 1:size(list_test,1)
    stat{nt}        = ft_freqstatistics(cfg, alldata{:,list_test(nt,1)}, alldata{:,list_test(nt,2)});
    list_test_name{nt}          = [list_cond{list_test(nt,1)} ' v ' list_cond{list_test(nt,2)}];
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]	= h_pValSort(stat{ntest});
    stat{ntest}              	= rmfield(stat{ntest},'negdistribution');
    stat{ntest}              	= rmfield(stat{ntest},'posdistribution');
end


for ntest = 1:length(stat)
    
    figure;
    
    list_nrow                   = [6 3 4];
    list_zlim                   = [5 2 3];
    
    i                           = 0;
    nrow                        = list_nrow(ntest);
    ncol                        = 6;
    
    plimit                      = 0.1;
    
    statplot                    = stat{ntest};
    statplot.mask               = statplot.prob < plimit;
    
    for nchan = 1:length(statplot.label)
        
        tmp                     = statplot.mask(nchan,:,:) .* statplot.prob(nchan,:,:);
        iy                      = unique(tmp);
        iy                   	= iy(iy~=0);
        iy                      = iy(~isnan(iy));
        
        tmp                     = statplot.mask(nchan,:,:) .* statplot.stat(nchan,:,:);
        ix                    	= unique(tmp);
        ix                   	= ix(ix~=0);
        ix                   	= ix(~isnan(ix));
        
        if ~isempty(ix)
            
            i                 	= i + 1;
            
            val                 = list_zlim(ntest);
            
            cfg                	= [];
            cfg.colormap      	= brewermap(256, '*RdBu');
            cfg.channel        	= nchan;
            cfg.parameter      	= 'stat';
            cfg.maskparameter 	= 'mask';
            cfg.maskstyle     	= 'outline';
            cfg.zlim           	= [-5 5];
            cfg.ylim            = statplot.freq([1 end]);
            cfg.xlim            = [-0.2 2];
            cfg.colorbar        = 'no';
            nme              	= statplot.label{nchan};
            
            subplot(nrow,ncol,i)
            ft_singleplotTFR(cfg,statplot);
            vline(0,'--k');
            
            %' ' statplot.label{nc}
            ylabel({[list_test_name{ntest}],[' p = ' num2str(round(min(min(iy)),3))]});
            %             xlabel('Time');
            title(statplot.label{nchan});
            
            %             c           = colorbar;
            %             c.Ticks     = cfg.zlim;
            %             c.FontSize  = 10;
            
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            avg_over_time                 	= squeeze(nanmean(tmp,3));
            i                   = i + 1;
            subplot(nrow,ncol,i)
            
            plot(statplot.freq,avg_over_time,'k','LineWidth',2);
            xlabel('Frequency');
            grid on;
            set(gca,'FontSize',10,'FontName', 'Calibri');
            xlim(statplot.freq([1 end]));
            ylim([0 val]);
            yticks([0 val]);
            ylabel('t values');
            
        end
    end
    
end