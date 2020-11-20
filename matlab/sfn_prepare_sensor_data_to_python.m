clear ; 

addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

suj_list        = 10:17; % [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj             = ['yc' num2str(suj_list(sb))];
    
    for prt = 1:3
        
        fname_in                                        = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.CnD.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        data_part{prt}                                  = data_elan; clear data_elan;
        
    end
    
    data_elan       = ft_appenddata([],data_part{:}); clear data_part;
    
    cfg             = [];
    cfg.trials      = h_chooseTrial(data_elan,1:2,0,1:4);
    cfg.latency     = [-1 3];
    data_elan        = ft_selectdata(cfg,data_elan);
    
    dir_out         = ['../data/sfn_data/' suj '/'];
    mkdir(dir_out);
    
    py_name_out     = [dir_out  suj '.CnD.prep21.Sensor'];
    
    h_field2py_decode(data_elan,py_name_out); clear virtsens;
    
end