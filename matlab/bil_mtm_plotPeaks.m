clear ; close all;

suj_list                                = dir('../data/sub*/tf/*mtmconvol.comb.mat');
% suj_list                                = dir('../data/sub*/tf/*mtmconvol.mat');

for ns = 1:length(suj_list)
    
    fname                               = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % this finds the freq structure loaded
    find_var                            = whos;
    find_var                            = {find_var.name};
    find_var                            = find(strcmp(find_var,'freq_axial'));
    
    cfg                                 = [];
    cfg.baseline                        = [-0.4 -0.2];
    cfg.baselinetype                    = 'relchange';
    
    if isempty(find_var)
        freq                            = ft_freqbaseline(cfg,freq_comb);
    else
        freq                            = ft_freqbaseline(cfg,freq_axial);
    end
    
    clear freq_*
    
    list_window                         = 0; %[0 1.5 3 4.5];
    list_width                          = 6; %[1.5 1.5 1.5 2.5];
    
    cfg                                 = [];
    cfg.frequency                       = [1 50];
    
    for nt = 1:length(list_window)
        
        ix1                             = list_window(nt);
        time_window                     = list_width(nt);
        ix2                             = ix1+time_window;
        cfg.latency                     = [ix1 ix2];
        alldata{ns,nt}                  = ft_selectdata(cfg,freq);
        
    end
    
    clear freq;
    
end

keep alldata; clc;

list_chan                               = {'all','M*O*','M*P*','M*T*','M*F*','M*C*'};
i                                       = 0;
ncol                                    = 2;
nrow                                    = length(list_chan) * size(alldata,2);

for nt = 1:size(alldata,2)
    for nc = 1:length(list_chan)
        
        data_avg                        = {};
        
        for ns = 1:size(alldata,1)
            
            cfg                         = [];
            cfg.channel                 = list_chan{nc};
            cfg.avgoverchan             = 'yes';
            data_chan                   = ft_selectdata(cfg,alldata{ns,nt});
            
            data_avg{ns,1}              = [];
            data_avg{ns,1}.label        = list_chan(nc);
            data_avg{ns,1}.dimord       = 'chan_time';
            
            data_avg{ns,1}.time         = data_chan.freq;
            data_avg{ns,1}.avg          = [nanmean(squeeze(data_chan.powspctrm),2)]';
            
            data_avg{ns,2}              = data_avg{ns,1};
            data_avg{ns,2}.time         = data_chan.time;
            data_avg{ns,2}.avg          = [nanmean(squeeze(data_chan.powspctrm),1)];
            
            clear data_chan
            
        end
        
        cfg                             = [];
        cfg.plot_single                 = 'no';
        cfg.xlim                        = [data_avg{ns,1}.time(1) data_avg{ns,1}.time(end)];
        cfg.hline                       = 0;
        %         cfg.zerolim                     = 'minzero';
        i                               = i + 1;
        subplot(nrow,ncol,i);
        h_plot_erf(cfg,data_avg(:,1));
        title([list_chan{nc} ' ' num2str(nt)]);
        
        %         cfg.zerolim                     = 'zeromax';
        %         i                               = i + 1;
        %         subplot(nrow,ncol,i);
        %         h_plot_erf(cfg,data_avg(:,1));
        
        cfg.vline                       = [0 1.5 3 4.5];
        cfg.xlim                        = [data_avg{ns,2}.time(1) data_avg{ns,2}.time(end)];
        i                               = i + 1;
        subplot(nrow,ncol,i);
        h_plot_erf(cfg,data_avg(:,2));
        
    end
end