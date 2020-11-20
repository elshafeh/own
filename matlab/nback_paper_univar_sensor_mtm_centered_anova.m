clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];
allpeaks                                        = [];

for nsuj = 1:length(suj_list)
    load(['J:/temp/nback/data/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                            = apeak; clear apeak;
    allpeaks(nsuj,2)                            = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)                = nanmean(allpeaks(:,2));

keep suj_list allpeaks

test_band                                       = 'alpha';

for nsuj = 1:length(suj_list)
    
    subjectName                                 = ['sub' num2str(suj_list(nsuj))];clc;
    
    for nback = [0 1 2]
        
        % load data from both sessions
        check_name                              = dir(['J:/temp/nback/data/tf_sens/' subjectName '.sess*.' num2str(nback) 'back.5t30Hz.1HzStep.AvgTrials.sens.mat']);
        
        for nf = 1:length(check_name)
            
            fname                               = [check_name(nf).folder filesep check_name(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            % baseline-correct
            cfg                                 = [];
            cfg.baseline                        = [-0.4 -0.2];
            cfg.baselinetype                    = 'relchange';
            freq_comb                           = ft_freqbaseline(cfg,freq_comb);
            
            tmp{nf}                             = freq_comb; clear freq_comb;
            
        end
        
        % avearge both sessions
        freq                                    = ft_freqgrandaverage([],tmp{:}); clear tmp nf check_name;
        
        switch test_band
            case 'alpha'
                bnd_width                     	= 1;
                apeak                           = allpeaks(nsuj,1);
                xi                             	= find(round(freq.freq) == round(apeak - bnd_width));
                yi                            	= find(round(freq.freq) == round(apeak + bnd_width));
            case 'beta'
                bnd_width                      	= 2;
                apeak                           = allpeaks(nsuj,2);
                xi                            	= find(round(freq.freq) == round(apeak - bnd_width));
                yi                             	= find(round(freq.freq) == round(apeak + bnd_width));
        end
        
        
        avg                                     = [];
        avg.avg                                 = squeeze(mean(freq.powspctrm(:,xi:yi,:),2));
        avg.label                               = freq.label;
        avg.dimord                              = 'chan_time';
        avg.time                                = freq.time; clear freq;
        
        alldata{nsuj,nback+1}                 	= avg; clear avg;
        
    end
end

keep alldata test_band

% compute anova
cfg                        	= [];
cfg.latency              	= [-0.1 1.5];

switch test_band
    case 'alpha'
        cfg.minnbchan     	= 4;
    case 'beta'
        cfg.minnbchan    	= 3;
end

stat                      	= h_anova(cfg,alldata);

save(['../data/stat/anova/nback.univar.sensor.' test_band '.mat'],'stat');

statplot                    = [];
statplot.time               = stat.time;
statplot.label              = stat.label;
statplot.dimord             = stat.dimord;
statplot.avg                = stat.mask .* stat.stat;

% plot results

figure;
nrow                            = 2;
ncol                            = 4;

cfg                             = [];
cfg.layout                      = 'neuromag306cmb.lay';
cfg.zlim                        = [0 20];
cfg.colormap                    = brewermap(256,'*RdBu');
cfg.marker                      = 'off';
cfg.comment                     = 'no';
cfg.colorbar                    = 'yes';
subplot(nrow,ncol,1);
ft_topoplotER(cfg,statplot);
title(['p = ' num2str(stat.posclusters(1).prob,3)]);

switch test_band
    case 'alpha'
        list_chan               = {'MEG1632+1633','MEG1842+1843','MEG1912+1913','MEG1922+1923','MEG1942+1943','MEG2012+2013','MEG2022+2023', ...
            'MEG2032+2033','MEG2042+2043','MEG2112+2113','MEG2232+2233','MEG2312+2313','MEG2322+2323','MEG2342+2343','MEG2442+2443','MEG2512+2513'};
    case 'beta'
        list_chan               = {'MEG0732+0733', 'MEG0742+0743','MEG1822+1823', 'MEG1832+1833', 'MEG1842+1843', 'MEG2212+2213', 'MEG2232+2233', 'MEG2242+2243'};
end

cfg                             = [];
cfg.channel                     = list_chan;
subplot(nrow,ncol,2);
ft_singleplotER(cfg,statplot);
xlim(statplot.time([1 end]));
ax	= gca;
lm  = ax.YAxis.Limits([1 end]);
ylim(round(lm));
yticks(round(lm));
vline(0,'-k');title('');

cfg                             = [];
cfg.channel                     = list_chan;
cfg.time_limit                  = stat.time([1 end]);
cfg.color                       = 'rgb';
cfg.z_limit                     = [-0.2 0.2];
cfg.linewidth                   = 10;
subplot(nrow,ncol,3);
h_plotSingleERFstat_selectChannel_nobox(cfg,stat,alldata);
xlim(statplot.time([1 end]));
vline(0,'--k');
hline(0,'--k');

cfg.z_limit = [-0.1 0.1];

for ncluster = 1%:length(stat.posclusters)
    
    find_chan = [];
    for nc = 1:length(list_chan)
        find_chan               = [find_chan; find(strcmp(list_chan{nc},stat.label))];
    end

    vct                         = mean(double(stat.mask(find_chan,:)),1);
    flg                         = find(vct ~=0);
    
    time_win                    = flg([1 end]);
    data_plot                   = [];
    
    for nsub = 1:size(alldata,1)
        for ncond = 1:size(alldata,2)
            data_plot(nsub,ncond)       = mean(mean(alldata{nsub,ncond}.avg(find_chan,time_win)));
        end
    end
    
    [h1,p1]                           	= ttest(data_plot(:,1),data_plot(:,2));
    [h2,p2]                           	= ttest(data_plot(:,1),data_plot(:,3));
    [h3,p3]                           	= ttest(data_plot(:,2),data_plot(:,3));
    
    
    mean_data                   = nanmean(data_plot,1);
    bounds                      = nanstd(data_plot, [], 1);
    bounds_sem                  = bounds ./ sqrt(size(data_plot,1));
    
    subplot(nrow,ncol,3+ncluster);
    errorbar(mean_data,bounds_sem,'-ks');
    
    xlim([0 4]);
    xticks([1 2 3]);
    xticklabels({'0Back','1Back','2Back'});
    title(['p1= ' num2str(round(p1,3)) ' p2= ' num2str(round(p2,3)) ' p3= ' num2str(round(p3,3))]);
    
    ylim(cfg.z_limit);
    yticks(cfg.z_limit);
    
end