clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

list_chan               = [];

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    
    if isunix
        subject_folder  = ['/project/3015079.01/data/' subjectName];
    else
        subject_folder  = ['P:/3015079.01/data/' subjectName];
    end
    
    fname               = [subject_folder '/erf/' subjectName '.gratinglock.demean.erfComb.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    fname            	= [subject_folder '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                     = [];
    cfg.channel             = max_chan;
    cfg.avgoverchan         = 'yes';
    tmp                     = ft_selectdata(cfg,avg_comb);
    
    time_axis               = avg_comb.time;
    alldata(nsuj,:)         = tmp.avg; clear tmp avg_comb max_chan;
    
    
end

keep alldata time_axis

%%

subplot(2,2,1)

mean_data               = nanmean(alldata,1);
bounds                  = nanstd(alldata, [], 1);
bounds_sem              = bounds ./ sqrt(size(alldata,1));
boundedline(time_axis, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent

xlim([-0.1 1]);
xticks([0 0.2 0.4 0.6 0.8 1]);
ylim([0 2e-13]);
yticks([0 2e-13]);
vline(0,'--k');
vline(0.2,'--k');