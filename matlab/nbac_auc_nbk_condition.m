clear ;

i                       = 0;

for nsuj = [1:33 35:36 38:44 46:51]
    
    i                               = i +1;
    tmp                             = [];
    
    for n_ext = 1:2
        
        list_ext                    = {'stk.exl.auc','auc'};
        list_condition              = {'0v1B','0v2B','1v2B'};
        
        for n_con = 1:length(list_condition)
            
            fname                   = ['../data/decode_data/nback/sub' num2str(nsuj) '.' list_condition{n_con} '.' list_ext{n_ext} '.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(n_con,:)            = scores; clear scores;
            
        end
        
        list_condition              = {'0 versus 1 Back','0 versus 2 Back','1 versus 2 Back'};
        
        load nbk_time_axis.mat
        
        avg                         = [];
        avg.label                   = list_condition;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        avg.avg                     = tmp; clear tmp;
        
        alldata{i,n_ext}            = avg; clear avg;
        
    end
end

keep alldata;

figure;

for nchan = 1:length(alldata{1,1}.label)
    
    subplot(2,2,nchan)
    hold on;
    
    for n_ext = 1:2
        
        cfg                         = [];
        cfg.color                   = 'kr';
        cfg.label                   = nchan;
        cfg.color                   = cfg.color(n_ext);
        cfg.plot_single             = 'no';
        
        cfg.vline                   = [0 2 4];
        cfg.hline                   = 0.5;
        
        cfg.xlim                    = [-0.2 6];
        cfg.ylim                    = [0.49 0.65];
        
        h_plot_erf(cfg,alldata(:,n_ext));
        
    end
    
    yticks(cfg.ylim)
    
    xlabel('Time (s)')
    ylabel('AUC')
    
    title(alldata{1,1}.label{nchan});
    set(gca,'FontSize',20,'FontName', 'Calibri');
    
end
