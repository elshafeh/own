clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for n_suj = 1:length(suj_list)
    
    list_freq                       = {'alpha1Hz.virt.demean','beta3Hz.virt.demean'};
    
    for n_freq = 1:length(list_freq)
        
        list_condition              = {'0v1B','0v2B','1v2B','0Ball','1Ball','2Ball' }; % 
        
        for n_con = 1:length(list_condition)
            
            fname                   = ['../data/decode_data/virt/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.' list_freq{n_freq}];
            fname                   = [fname '.auc.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(n_con,:)            = scores; clear scores;
            
        end
        
        new_list_condition          = {'0 vs 1','0 vs 2','1 vs 2','0 vs all','1 vs all','2 vs all'}; % 
        new_list_freq               = {'α ± 1Hz','β ± 3Hz'};
        
        avg                         = [];
        avg.label                   = new_list_condition;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        avg.avg                     = tmp; clear tmp;
        
        alldata{n_suj,n_freq}       = avg; clear avg;
        
    end
end

keep alldata list_* new_*;

figure;

i                                   = 0;

nrow                                = length(alldata{1,1}.label);
ncol                                = length(new_list_freq);

for nchan = 1:length(alldata{1,1}.label)
    for n_freq = 1:length(new_list_freq)
        
        i                           = i+1;
        subplot(nrow,ncol,i)
        
        cfg                         = [];
        cfg.color                   = 'kkkk';
        cfg.label                   = nchan;
        cfg.color                   = cfg.color(n_freq);
        cfg.plot_single             = 'no';
        
        cfg.vline                   = [0 2 4];
        cfg.hline                   = 0.5;
        cfg.xlim                    = [-1 6];
        
        %         ylist                       = [0.65 0.65 0.55];
        %         cfg.ylim                    = [0.48 ylist(nchan)];
        
        h_plot_erf(cfg,alldata(:,n_freq));
        
        if isfield(cfg,'ylim')
            yticks(cfg.ylim)
        end
        
        xlabel('Time (s)')
        ylabel('AUC')
        
        title([alldata{1,1}.label{nchan} ' ' new_list_freq{n_freq}]);
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
    end
    
end