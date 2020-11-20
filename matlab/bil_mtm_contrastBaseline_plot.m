clear;

[file,path]                 = uigetfile('../results/stat/*.mat');
fname_out                   = fullfile(path,file);
load(fname_out);

[min_p, p_val]              = h_pValSort(stat);

i                           = 0;

cluster_sign                = [];

for n = 1:size(p_val,2)
    
    p                       = p_val(1,n);
    p_limit                 = 0.1;
    
    if p < p_limit
        
        i                   = i + 1;
        lm                  = 0.0000000001;
        statplot{i}         = h_plotStat(stat,p-lm,p+lm);
        
        cluster_sign(i)     = p_val(2,n);
        
        if cluster_sign(i) == 1
            statplot{i}.powspctrm(statplot{i}.powspctrm<0) = 0;
        else
            statplot{i}.powspctrm(statplot{i}.powspctrm>0) = 0;
        end
        
    end
    
end

keep statplot stat min_p p_val cluster_sign

for ni = [-1 1]
    
    slct                        = find(cluster_sign == ni);
    nrow                        = length(slct);
    ncol                        = 3;
    i                           = 0;
    
    if ~isempty(slct)
        figure;
    end
    
    for n = 1:length(slct)
        
        data                    = statplot{slct(n)};
        
        cfg                     = [];
        cfg.layout              = 'CTF275_helmet.mat';
        cfg.marker              = 'off';
        cfg.comment             = 'no';
        cfg.colormap            = brewermap(256, '*RdBu');
        cfg.colorbar            = 'no';
        cfg.zlim                = 'maxabs';
        
        i                       = i + 1;
        subplot(nrow,ncol,i)
        ft_topoplotTFR(cfg, data);
        
        i                       = i + 1;
        subplot(nrow,ncol,i)
        
        avg                     = nanmean(squeeze(nanmean(data.powspctrm,1)),1);
        plot(data.time,avg,'-k','LineWidth',2); clear avg;
        %     ylim([-0.6 0]);
        
        for nv = [1.5 3 4.5]
            vline(nv,'--k');
        end
        
        i                       = i + 1;
        subplot(nrow,ncol,i)
        
        avg                     = [nanmean(squeeze(nanmean(data.powspctrm,1)),2)]';
        plot(data.freq,avg,'-r','LineWidth',2); clear avg;
        %     ylim([-0.2 0]);
        
        %     for nv = 10:40
        %         vline(nv,'--k');
        %     end
        
    end
    
end