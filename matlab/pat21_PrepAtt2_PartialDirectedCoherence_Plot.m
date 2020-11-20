clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    fprintf('Loading data for %s\n',suj);
    fname_in         = ['../data/tfr/' suj '.CnD.RamaBigCov.4TimeWin1Pdc2Grang.mat'];
    load(fname_in);
    
    if sb == 1
        gavg_pdc = conn_pdc ;
        
    else
        
        for nt = 1:4
            for nc = 1:2
                gavg_pdc{nt,nc}.pdcspctrm = cat(4,gavg_pdc{nt,nc}.pdcspctrm,conn_pdc{nt,nc}.pdcspctrm);
            end
        end
    end
end

clearvars -except gavg_pdc

for nt = 1:4
    for nc = 1:2
        gavg_pdc{nt,nc}.pdcspctrm = squeeze(mean(gavg_pdc{nt,nc}.pdcspctrm,4));
    end
end

clearvars -except gavg_pdc

for nt = 3:4
    for nc = 1:2
        gavg_pdc{nt,nc}.pdcspctrm = gavg_pdc{nt,nc}.pdcspctrm - gavg_pdc{1,nc}.pdcspctrm;
    end
end

clearvars -except gavg_pdc

cfg           = [];
cfg.parameter = 'pdcspctrm';
cfg.xlim      = [1 15];
cfg.zlim      = [-0.5 0.5];
for nt = 1:3
    figure;
    ft_connectivityplot(cfg, gavg_pdc{nt,:});
end