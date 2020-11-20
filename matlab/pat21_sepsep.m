clear ; clc ; dleiftrip_addpath

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    load(['../data/all_data/' suj '.CnD.RamaBigCovSlct.mat']);
    
    cfg         = [];
    cfg.channel = [find(strcmp(virtsens.label,'audL')) find(strcmp(virtsens.label,'audR'))];
    virtsens    = ft_selectdata(cfg,virtsens);
    virtsens    = rmfield(virtsens,'cfg');
    
    save(['../data/all_data/' suj '.CnD.RamaBigCovSlctAuditory.mat'],'virtsens','-v7.3');
    
    clear virtsens;
    
end