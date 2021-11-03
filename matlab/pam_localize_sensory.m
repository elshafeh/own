clear;

for nsuj = 2:21
    
    sujname                         = ['yc' num2str(nsuj)];
    
    dir_in                          = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
    dir_out                         = '~/Dropbox/project_me/data/pam/erf/';
    check_files                     = dir(['~/Dropbox/project_me/data/pam/erf/' sujname '*erf.mat']);
    
    if length(check_files) < 2
        
        for ext_data = {'CnD' 'nDT'}
            
            fname_in                = [dir_in sujname '.' ext_data{:} '.mat'];
            fprintf('loading %s\n',fname_in);
            load(fname_in);
            
            % for some reason last trial is off
            if strcmp(ext_data{:},'nDT')
                data_elan.trial 	= data_elan.trial(1:end-1);
                data_elan.time   	= data_elan.time(1:end-1);
                data_elan.trialinfo(length(data_elan.trialinfo))        = [];
                data_elan.sampleinfo(length(data_elan.sampleinfo),:)  	= [];
            end
            
            % -- low pass filtering
            cfg                  	= [];
            cfg.demean            	= 'yes';
            cfg.baselinewindow    	= [-0.1 0];
            cfg.lpfilter           	= 'yes';
            cfg.lpfreq           	= 20;
            data_axial           	= ft_preprocessing(cfg,data_elan);
            
            % -- compute avg
            cfg                     = [];
            avg                     = ft_timelockanalysis(cfg, data_axial);
            
            % -- combine planar
            cfg                     = [];
            cfg.feedback            = 'yes';
            cfg.method              = 'template';
            cfg.neighbours          = ft_prepare_neighbours(cfg, avg); close all;
            cfg.planarmethod        = 'sincos';
            avg_planar              = ft_megplanar(cfg, avg);
            avg_comb                = ft_combineplanar([],avg_planar);
            avg_comb                = rmfield(avg_comb,'cfg');
            
            fname_out           	= [dir_out sujname '.' ext_data{:} '.erf.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'avg_comb','-v7.3');
            
            clear avg_comb
            
        end
        
        
    end
end