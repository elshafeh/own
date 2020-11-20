clear;

list_modality                   = {'vis','aud'};
list_feat                       = {'noise.side','noise.left.type','noise.right.type'};

for nmod = 1:length(list_modality)
    for nfeat = 1:length(list_feat)
        
        list_file               = dir(['../data/decode/*.' list_modality{nmod} '.b*.' list_feat{nfeat} '.auc.mat']);
        
        for nfile = 1:length(list_file)
            
            fname               = [list_file(nfile).folder '/' list_file(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            tmp(nfile,:)        = scores; clear scores;
                
        end
        
        avg                     = [];
        avg.label               = {'auc'};
        avg.dimord              = 'chan_time';
        avg.time                = time_axis;
        avg.avg                 = mean(tmp,1);
        
        alldata{nmod,nfeat}     = avg; clear avg;
        
    end
end

keep alldata list_feat list_modality

for nfeat = 1:size(alldata,2)
    
    subplot(2,2,nfeat);
    
    cfg                     = [];
    %     list_color              = 'br';
    cfg.linewidth           = 2;
    %     cfg.linecolor           = list_color(nmod);
    cfg.xlim                = [-0.5 1];
    ft_singleplotER(cfg,alldata{:,nfeat});
    
    vline(0,'-k');
    hline(0.5,'-k');
    
    xlabel('Time (s)');
    ylabel('AUC');
    
    title(list_feat{nfeat});
    set(gca,'FontSize',20,'FontName', 'Calibri');
    
    legend(list_modality);
    
end