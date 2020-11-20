clear ; close all;

suj_list                            =  [1:4 8:17];
for ns = 1:length(suj_list)
    
    list_data                       = {'meg','eeg'};
    
    for ndata = 1:length(list_data)
        
        
        list_feat                   = {'inf.unf','left.right','left.inf','right.inf'};
        
        for nfeat = 1:length(list_feat)
            
            dir_data                = '../data/decode/auc/';
            ext_file                = '.auc.mat';
            
            if strcmp(list_data{ndata},'eeg')
                
                fname               = [dir_data 'yc' num2str(suj_list(ns)) '.CnD.' list_data{ndata} '.' list_feat{nfeat} ext_file];
                fprintf('loading %s\n',fname);
                load(fname);
                
                tmp(nfeat,:)        = scores; clear scores;
                
            else
                
                for np = 1:3
                    fname           = [dir_data 'yc' num2str(suj_list(ns)) '.pt' num2str(np) '.CnD.' list_data{ndata} '.' list_feat{nfeat} ext_file];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    sc_carr(np,:)   = scores ; clear scores;
                end
                
                tmp(nfeat,:)        = mean(sc_carr,1); clear sc_carr;
                
            end
            
        end
        
        list_feat                   = {'INF VS UNF','LEFT VS RIGHT','LEFT VS UNF','RIGHT VS UNF'};
        scores                      = tmp; clear tmp;
        
        %         fname                   = ['/Volumes/heshamshung/alpha_compare/preproc_data/yc' num2str(suj_list(ns)) '.' list_orig{ndata} '.sngl.dwn100.mat'];
        %         fprintf('loading %s\n',fname);
        %         load(fname);
        %         lm1                     = find(round(data.time{1},2) == round(-0.1,2));
        %         lm2                     = find(round(data.time{1},2) == round(2,2));
        
        avg                         = [];
        avg.label                   = list_feat;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        avg.avg                     = scores;
        
        alldata{ns,ndata}           = avg;
        
        keep alldata ns suj_list list_*;
        
        fprintf('\n');
        
    end
end


for nchan = 1:length(alldata{1,1}.label)
    
    subplot(2,2,nchan);
    hold on;
    
    for ndata   = 1:2
        
        cfg                     = [];
        cfg.color               = 'br';
        cfg.label               = nchan;
        cfg.color               = cfg.color(ndata);
        cfg.plot_single         = 'no';
        
        cfg.vline               = [0 1.2];
        cfg.hline               = 0.5;
        
        cfg.xlim                = [-0.1 2];
        cfg.ylim                = [0.48 0.75];
        
        h_plot_erf(cfg,alldata(:,ndata));
        
        xticks([0 0.4 0.8 1.2 1.6 2])
        list_name                   = {'Cue Onset','0.4','0.8','Target Onset','1.6','2'};
        xticklabels(list_name);
        
        yticks([0.5 0.7])
        
        xlabel('Time (s)')
        ylabel('AUC')
        
        title(alldata{1,1}.label{nchan});
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
    end
end