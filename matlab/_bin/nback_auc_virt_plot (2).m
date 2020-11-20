clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for n_suj = 1:length(suj_list)
    
    list_freq                       = {'alpha1Hz','beta3Hz'};
    
    for n_freq = 1:length(list_freq)
        
        list_condition              = {'0v1B','0v2B','1v2B'};
        
        for n_con = 1:length(list_condition)
            
            fname                   = ['../../data/decode/new_virt/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.brainbroadband.mtmavg.' list_freq{n_freq}];
            
            %             if n_con > 1
            fname               = [fname '.bslcorrected.auc.bychan.mat'];
            %             else
            %                 fname               = [fname '.demean.all.auc.bychan.mat'];
            %             end
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            if size(scores,1) > 1
                %                 if n_con > 1
                scores              = mean(scores,1);
                %                 else
                %                     scores              = scores(randi(150),:);
                %                 end
            end
            
            tmp(n_con,:)            = scores; clear scores;
            
        end
        
        new_list_condition          = {'0 vs 1','0 vs 2','1 vs 2'};%,'0 vs all','1 vs all','2 vs all'}; %
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

nrow                                = length(alldata{1,1}.label);%length(new_list_freq);
ncol                                = 1;%

for nchan = 1:length(alldata{1,1}.label)
    
    i                           = i+1;
    subplot(nrow,ncol,i);
    hold on;
    
    for n_freq = 1:length(new_list_freq)
        
        cfg                         = [];
        cfg.color                   = 'brk';
        cfg.label                   = nchan;
        cfg.color                   = cfg.color(n_freq);
        cfg.plot_single             = 'no';
        
        cfg.vline                   = [0 2 4];
        cfg.hline                   = 0.5;
        cfg.xlim                    = [-0.2 5.5];
        
        %         ylist                       = [0.7 0.6 0.6];
        cfg.ylim                    = [0.499 0.515];
        
        h_plot_erf(cfg,alldata(:,n_freq));
        
        if isfield(cfg,'ylim')
            yticks(cfg.ylim)
        end
        
        xlabel('Time (s)')
        ylabel('AUC')
        
        title([alldata{1,1}.label{nchan} ]);%' ' new_list_freq{n_freq}]);
        %         set(gca,'FontSize',20,'FontName', 'Calibri');
        
    end
    
end