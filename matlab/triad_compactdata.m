clear;

[~,suj_list,~]      = xlsread('../doc/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list            = suj_list(2:22);

for nsuj = 2:length(suj_list)
   
    sujname         = suj_list{nsuj};
    
    for list_ext = {'CnD' 'DIS' 'fDIS'}
        
        fname_in                = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' sujname '.' list_ext{:} '.mat'];
        fprintf('loading%s\n',fname_in);
        load(fname_in);
        
        % save in single precision to save space
        cfg                     = [];
        cfg.precision        	= 'single';
        data                  	= ft_preprocessing(cfg,data_elan);
        
        % DownSample to 300Hz
        cfg                  	= [];
        cfg.resamplefs       	= 300;
        cfg.detrend          	= 'no';
        cfg.demean           	= 'no';
        data                   	= ft_resampledata(cfg, data); 
        
        fname_out              	= ['/Volumes/heshamshung/triad/preproc/' sujname '.' list_ext{:} '.dwn.single.mat'];
        fprintf('\nSaving %s\n',fname_out);
        save(fname_out,'data','-v7.3');
        
        clear data
        
    end
end