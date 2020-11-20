clear ;

for ns = [1:4 8:17]
    
    dir_out                             = ['/Volumes/heshamshung/alpha_compare/lcmv_mtm/yc' num2str(ns)];
    mkdir(dir_out)
    
    list_orig                           = {'CnD.com90roi.eeg','CnD.com90roi.meg'};
    
    for ndata = 1:length(list_orig)
        
        % load data
        fname                           = ['/Volumes/heshamshung/alpha_compare/lcmv/yc' num2str(ns) '.' list_orig{ndata} '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        orig_data                       = data; clear data;
        
        cfg                             = [];
        cfg.channel                     = [1 2 19 20 43:70 79:90];
        orig_data                       = ft_selectdata(cfg,orig_data);
        
        if isfield(orig_data,'cfg')
            orig_data                   = rmfield(orig_data,'cfg');
        end
        
        time_width                      = 0.03;
        freq_width                      = 1;
        
        time_list                       = -1:time_width:2.5;
        freq_list                       = 1:freq_width:30;
        
        cfg                             = [] ;
        cfg.output                      = 'pow';
        cfg.method                      = 'mtmconvol';
        cfg.keeptrials                  = 'yes';
        cfg.taper                       = 'hanning';
        cfg.pad                         = 'nextpow2';
        
        cfg.toi                         = time_list;
        
        cfg.foi                         = freq_list;
        cfg.t_ftimwin                   = ones(length(cfg.foi),1).*0.5;
        cfg.tapsmofrq                   = 0.2 *cfg.foi;
        freq                            = ft_freqanalysis(cfg,orig_data);
        
        freq.powspctrm(isnan(freq.powspctrm)) = 0;
        
        for nf = 1:length(freq_list)
            
            data                        = orig_data;
            
            for xi = 1:length(data.trial)
                data.trial{xi}          = squeeze(freq.powspctrm(xi,:,nf,:));
                data.time{xi}           = freq.time;
            end
                        
            fname_out                   = [dir_out '/yc' num2str(ns) '.' list_orig{ndata}  '.' num2str(round(freq.freq(nf))) 'Hz.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'data');toc;
            
            clear data;clc;
            
        end
        
        
    end
    
    keep ns
    
end