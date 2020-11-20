clear; global ft_default; close all;
ft_default.spmversion = 'spm12';

clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

list_suj                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(list_suj)
    load(['J:/temp/nback/data/peak/sub' num2str(list_suj(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

% load('J:temp\nback\data\voxbrain\preproc\sub1.session1.brain1vox.mat');
% list_chan         	= h_grouplabel(data,'no');
% list_chan           = list_chan(:,1);
% nroi=24;data.label{list_chan{nroi,2}}

keep list_* allpeaks

for nsuj  = 1:length(list_suj)
    
    list_color                    	= 'kmy';
    list_cond                       = {'decoding.0back','decoding.1back'};
    list_freq                       = 1:30;
    
    for ncond = 1:length(list_cond)
        
        
        list_chan                   = {'Amygdala','Basal ganglia','Cingulate gryus','fusiform gyrus','Hippocampus','Inferior frontal gyrus',...
            'Insular gyrus','Inferior pareital lobule','Inferior temporal gyrus','lateral occipital cortex','Middle frontal gyrus','Middle temporal gyrus', ...
            'MedioVentral Occipital cortex','Orbital gryus','Paracentral lobule','Precuneus','Parhippocampal Gyrus','Postcentral gyrus',...
            'Precentral gyrus','Superior Frontal Gyrus','Superior parietal Lobule','Superior temporal gyrus','Thalamus','Posterior superior temporal sulcus'};
        
        pow                         = [];
        
        for nfreq  = 1:length(list_freq)
            
            tmp     = [];
            
            flist   = dir(['P:/3015079.01/nback/vox_auc/sub' num2str(list_suj(nsuj)) '.sess*.' ...
                list_cond{ncond} '.' num2str(list_freq(nfreq)) 'Hz.lockedon.all.bsl.excl.bychan.auc.mat']);
            
            for nf = 1:length(flist)
                fname               = [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %50s\n',fname);
                load(fname);
                tmp(nf,:,:)         = scores; clear scores
            end
            
            pow(:,nfreq,:)          = squeeze(tmp); clear tmp;
            
        end
        
        slct_chan                   = [3 4 6 8 9 10 11 12 13 15 16 18 19 20 21 22 24];
        pow                         = pow(slct_chan,:,:);
        list_chan                   = list_chan(slct_chan);
        
        list_name                   = {'alpha peak ± 1Hz','beta peak ± 2Hz'};
        list_peak                   = [allpeaks(nsuj,1) allpeaks(nsuj,2)];
        list_width                  = [1 2 3];
        
        list_final                  = {};
        tmp                         = [];
        
        for np = 1:length(list_peak)
            
            xi                      = find(round(list_freq) == round(list_peak(np) - list_width(np)));
            yi                      = find(round(list_freq) == round(list_peak(np) + list_width(np)));
            
            zi                      = squeeze(pow(:,xi:yi,:)); clear xi yi;
            
            if size(zi,3) == 1
                tmp                 = [tmp; squeeze(nanmean(zi,1))];
            else
                tmp                 = [tmp;squeeze(nanmean(zi,2))];
            end
            
            clear zi;
            
            for luc = 1:length(list_chan)
                list_final{end+1}  	= [list_name{np} ' ' list_chan{luc}];
            end
            
        end
        
        avg                         = [];
        avg.label                   = list_final; clear list_final list_name
        avg.avg                     = tmp; clear tmp;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        
        alldata{nsuj,ncond}         = avg; clear avg;
        
    end
    
    alldata{nsuj,3}                	= alldata{nsuj,1};
    
    vct                             = alldata{nsuj,3}.avg;
    for xi = 1:size(vct,1)
        for yi = 1:size(vct,2)
            
            ln_rnd                  = [0.49:0.001:0.51];
            rnd_nb                  = randi(length(ln_rnd));
            vct(xi,yi)              = ln_rnd(rnd_nb);
            
        end
    end
    
    alldata{nsuj,3}.avg             = vct; clear vct;
    
end

keep alldata list_*;

list_cond                           = {'0and2','1and2','chance'};

cfg                                 = [];
cfg.statistic                       = 'ft_statfun_depsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;

cfg.latency                         = [-0.2 1.5];

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

list_test                           = [1 3; 2 3; 1 2];

for ntest = 1:size(list_test,1)
    stat{ntest}                    	= ft_timelockstatistics(cfg, alldata{:,list_test(ntest,1)}, alldata{:,list_test(ntest,2)});
    list_test_name{ntest}         	= [list_cond{list_test(ntest,1)} ' v ' list_cond{list_test(ntest,2)}];
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}] 	= h_pValSort(stat{ntest});
    stat{ntest}                    	= rmfield(stat{ntest},'negdistribution');
    stat{ntest}                  	= rmfield(stat{ntest},'posdistribution');
end


for ntest = 1:length(stat)
    
    list_nrow                       = [4 2 3];
    figure;
    
    i                            	= 0;
    nrow                         	= list_nrow(ntest);
    ncol                           	= 6;
    z_limit                         = [0.49 0.6];
    plimit                       	= 0.1;
    
    stat{ntest}.mask            	= stat{ntest}.prob < plimit;
    
    for nchan = 1:length(stat{1}.label)
        
        tmp                         = stat{ntest}.mask(nchan,:,:) .* stat{ntest}.prob(nchan,:,:);
        ix                          = unique(tmp);
        ix                          = ix(ix~=0);
        
        if ~isempty(ix)
            
            i                       = i + 1;
            subplot(nrow,ncol,i)
            
            nme                     = stat{ntest}.label{nchan};
            
            cfg                     = [];
            cfg.channel             = stat{ntest}.label{nchan};
            cfg.p_threshold        	= plimit;
            
            cfg.z_limit             = z_limit;
            cfg.time_limit          =stat{ntest}.time([1 end]);
            
            ix1                     = list_test(ntest,1);
            ix2                     = list_test(ntest,2);
            
            cfg.color            	= list_color([ix1 ix2]);
            
            h_plotSingleERFstat_selectChannel(cfg,stat{ntest},squeeze(alldata(:,[ix1 ix2])));
            
            legend({list_cond{ix1},'',list_cond{ix2},''});
            
            title([stat{ntest}.label{nchan}])
            ylabel([' p = ' num2str(round(min(ix),3))]);
            set(gca,'FontSize',10,'FontName', 'Calibri');
            
            hline(0.5,'--k');
            vline(0,'--k');
            
        end
    end
end