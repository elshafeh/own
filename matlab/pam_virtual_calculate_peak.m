clc;
clear;

for nsuj = 2:21
    
    sujname                             = ['yc' num2str(nsuj)];
    
    fname                               = ['~/Dropbox/project_me/data/pam/virt/' sujname '.CnD.virtualelectrode.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    list_modality                       = {'vis' 'aud' 'mot'};
    list_hemisphere                     = {'Left' 'Right'};
    
    list_window                         = [-0.9858 0; 0.21 1.2];
    list_window_name                    = {'precue' 'cuetarget'};
    
    peak_data                           = [];
    i                                   = 0;
    
    for ntime = 1:size(list_window,1)
        
        list_cue                        = {'unf' 'left' 'right'};
        
        for ncue = 1:length(list_cue)
            
            cfg                       	= [];
            cfg.toilim                	= list_window(ntime,:);
            data_select               	= ft_redefinetrial(cfg,data);
            
            code_base                   = data_select.trialinfo - 1000;
            code_cue                    = floor(code_base/100); % get cue
            
            cfg                       	= [] ;
            cfg.channel                 = {'*loc*'};
            cfg.trials                  = find(code_cue == ncue -1);
            cfg.output                	= 'pow';
            cfg.method               	= 'mtmfft';
            cfg.keeptrials            	= 'no';
            cfg.pad                  	= 10;
            cfg.taper                	= 'hanning';
            cfg.foi                   	= 1:1/cfg.pad:20;
            cfg.tapsmofrq              	= 0;
            freq                       	= ft_freqanalysis(cfg,data_select);
            freq                      	= rmfield(freq,'cfg');
            
            dir_data                 	= '~/Dropbox/project_me/data/pam/fft/';
            fname_out                	= [dir_data sujname '.CnD.virtualelectrode.' list_window_name{ntime} '.' list_cue{ncue} '.fft.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'peak_data');
            
            for nmod = [1 2 3]
                for nhemi = [1 2]
                    
                    cfg                 = [];
                    cfg.channel         = {[list_modality{nmod} '*' list_hemisphere{nhemi}(1) '*']};
                    freq_peak           = ft_selectdata(cfg,freq);
                    
                    cfg             	= [];
                    cfg.method       	= 'maxabs';
                    cfg.foi            	= [7 15];
                    apeak              	= alpha_peak(cfg,freq_peak);
                    
                    i                   = i + 1;
                    peak_data(i).sub    = sujname;
                    peak_data(i).mod    = list_modality{nmod};
                    peak_data(i).hemi 	= lower(list_hemisphere{nhemi});
                    peak_data(i).wind 	= list_window_name{ntime};
                    
                    peak_data(i).cue 	= list_cue{ncue};
                    
                    if strcmp(peak_data(i).cue,'unf')
                        peak_data(i).cue_cat 	= 'unf';
                    else
                        peak_data(i).cue_cat 	= 'inf';
                    end
                    
                    cue                 = lower(list_cue{ncue});
                    hemi                = lower(list_hemisphere{nhemi});
                    
                    if strcmp(cue,hemi)
                        peak_data(i).pos       = 'ipsi';
                    else
                        if strcmp(cue,'unf')
                            peak_data(i).pos   = 'unf';
                        else
                            peak_data(i).pos   = 'contra';
                        end
                    end
                    
                    peak_data(i).peak 	= apeak(1);
                    
                    
                end
            end
        end
    end
    
    peak_data                       = struct2table(peak_data);
    
    dir_data                        = '~/Dropbox/project_me/data/pam/peak/';
    fname_out                       = [dir_data sujname '.alpha.peak.1s.pre.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'peak_data');
    
end

pam_virtual_peak2R;