clear ; 

addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

suj_list        = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj             = ['yc' num2str(suj_list(sb))];
    
    mat_name        = ['/Volumes/heshamshung/Fieldtripping6Dec2018/data/paper_data/' suj '.CnD.prep21.maxAVMsepVoxels.1t120Hz.m800p2000msCov.mat'];
    fprintf('Loading %s\n',mat_name);
    load(mat_name);
    
    cfg             = [];
    cfg.trials      = h_chooseTrial(virtsens,1:2,0,1:4);
    cfg.channel     = 11:30;
    cfg.latency     = [-1 3];
    virtsens        = ft_selectdata(cfg,virtsens);
    
    dir_out         = ['../data/sfn_data/' suj '/'];
    mkdir(dir_out);
    
    py_name_out     = [dir_out  suj '.CnD.prep21.PaperAudSepVoxels.1t120Hz.m800p2000msCov'];
    
    h_field2py_decode(virtsens,py_name_out); clear virtsens;
    
end