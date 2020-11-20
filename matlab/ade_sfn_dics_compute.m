clear ; clc;

[file,path]                         = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

for nm = 1:length(list_modality)
    
    list_suj                        = goodsubjects{nm};
    
    for ns = 1:length(list_suj)
        
        subjectName                 = list_suj{ns};
        modality                    = list_modality{nm};
        
        dir_data                    = ['../data/' subjectName '/mri/'];
        
        fname                       = [dir_data subjectName '_' modality '_leadfield.mat'];
        fprintf('loading %s \n',fname);
        load(fname);
        
        fname                       = [dir_data subjectName '_gridVol.mat'];
        fprintf('loading %s \n',fname);
        load(fname);
        
        fname                       = ['../data/' subjectName '/preprocessed/' subjectName '_secondreject_postica_' modality '.mat'];
        fprintf('loading %s \n',fname);
        load(fname);
        
        fname                       = ['../data/' subjectName '/tf/' subjectName '_sfn.fft_' modality '.peak.mat'];
        fprintf('loading %s \n',fname);
        load(fname);
        
        fname                       = ['../data/' subjectName '/tf/' subjectName '_sfn.fft_' modality '.binsummary.mat'];
        fprintf('loading %s \n',fname);
        load(fname);
        
        % compute common filter
        cfg                         = [];
        cfg.toilim                  = [-0.5 0];
        data_common                 = ft_redefinetrial(cfg, secondreject_postica);
        
        cfg                         = [];
        cfg.method                  = 'mtmfft';
        
        cfg.pad                     = 3 ;
        cfg.taper                   = 'hanning';
        cfg.tapsmofrq               = 0 ;

        cfg.foi                     = alpha(1);
        
        cfg.output                  = 'powandcsd';
        cfg.taper                   = 'hanning';
        freq                        = ft_freqanalysis(cfg,data_common); clc ;
        
        cfg                         = [];
        cfg.method                  = 'dics';
        cfg.frequency               = freq.freq;
        cfg.grid                    = leadfield;
        cfg.headmodel               = vol;
        cfg.dics.keepfilter         = 'yes';
        cfg.dics.fixedori           = 'yes';
        cfg.dics.projectnoise       = 'yes';
        cfg.dics.lambda             = '5%';
        source                      = ft_sourceanalysis(cfg, freq);
        
        com_filter                  = source.avg.filter;
        
        clear freq data_in
        
        fname                       = ['../data/' subjectName '/preprocessed/' subjectName '_hc_data_' modality '.mat'];
        load(fname);
        
        for nb = 1:size(bin_summary.bins,2)
            
            cfg                     = [];
            cfg.trials              = bin_summary.bins(:,nb);
            data                    = ft_selectdata(cfg, data_common);
            headpos                 = ft_selectdata(cfg, hc_data);
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            
            cfg.pad                 = 3 ;
            cfg.taper               = 'hanning';
            cfg.tapsmofrq           = 0 ;
            
            cfg.foi                 = alpha(1);
            
            cfg.keeptrials          = 'yes';
            cfg.output              = 'powandcsd';
            cfg.taper               = 'hanning';
            freq                    = ft_freqanalysis(cfg,data);
            
            cfg                     = [];
            cfg.method              = 'dics';
            cfg.frequency           = freq.freq;
            cfg.grid                = leadfield;
            cfg.grid.filter         = com_filter ;
            cfg.headmodel           = vol;
            cfg.dics.fixedori       = 'yes';
            cfg.dics.projectnoise   = 'yes';
            cfg.dics.lambda         = '5%';
            cfg.rawtrial            = 'yes';
            source                  = ft_sourceanalysis(cfg, freq);
            source                  = rmfield(source,'cfg');
            
            regr                    = h_remove_hc_confound(headpos,source);
            regr                    = rmfield(regr,'cfg');
            
            source                  = regr;
            source.pow              = nanmean(source.pow,2);
            
            dir_out                 = ['../data/' subjectName '/source/'];
            mkdir(dir_out);
            
            fname                   = [dir_out subjectName '.' modality '.sfn.powerpeak.dicsRegress.b' num2str(nb) '.mat'];
            fprintf('saving %s \n',fname);
            save(fname,'source','-v7.3');
            
            clear source freq data regr headpos;
            
        end
    end
end