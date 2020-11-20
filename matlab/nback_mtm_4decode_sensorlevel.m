clear ;

for nsuj = [1:33 35:36 38:44 46:51]
    
    for nsess = [1 2]
        
        fname                       = ['P:/3015039.05/nback/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        %         orig_data{nsess}            = data; clear data;
        %         data                        = ft_appenddata([],orig_data{:});
        %         data                        = rmfield(data,'cfg');
        %         dirdata                     = '/project/3015039.05/nback/nback_12/';
        %         fname_out                   = [dirdata 'sub' num2str(nsuj) '.sess12.mat'];
        %         fprintf('Saving %s\n',fname_out);
        %         tic;save(fname_out,'data');toc;
        
        index                       = data.trialinfo;
        fname_out                	= ['P:/3015039.05/nback/nback_' num2str(nsess) '/sub' num2str(nsuj) '.sess' num2str(nsess) '.trialinfo.mat'];
        save(fname_out,'index'); clear index;
        
        orig_data                   = data; clear data;
        
        time_width                  = 0.02;
        freq_width                  = 1;
        
        time_list                   = -1.5:time_width:2;
        freq_list                   = 1:freq_width:30;
        
        cfg                         = [] ;
        cfg.output                  = 'pow';
        cfg.method                  = 'mtmconvol';
        cfg.keeptrials              = 'yes';
        cfg.taper                   = 'hanning';
        cfg.pad                     = 'nextpow2';
        cfg.toi                     = time_list;
        cfg.foi                     = freq_list;
        cfg.t_ftimwin               = 5./cfg.foi;
        cfg.tapsmofrq               = 0.1 *cfg.foi;
        freq                        = ft_freqanalysis(cfg,orig_data);
        
        % - % the idea here is to save each frequency as fieldtrip epoched data
        % structure
        
        for nf = 1:length(freq_list)
            
            data                    = orig_data;
            
            for xi = 1:length(data.trial)
                data.trial{xi}      = squeeze(freq.powspctrm(xi,:,nf,:));
                data.time{xi}       = freq.time;
            end
            
            dirdata                	= 'P:/3015039.05/nback/tf/';
            fname_out               = [dirdata 'sub' num2str(nsuj) '.sess' num2str(nsess) '.' num2str(round(freq.freq(nf))) 'Hz.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'data');toc;
            
            clear data index;clc;
            
        end
        
        keep nsuj
        
    end
end