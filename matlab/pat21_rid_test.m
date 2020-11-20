clear ; clc ; dleiftrip_addpath ;

for sb = 1
    
    suj_list                    = [1:4 8:17];
    suj                         = ['yc' num2str(suj_list(sb))];
    ext_essai                   = 'CnD.RamaBigCov';
    
    fprintf('Loading %s\n',suj);
    load(['../data/all_data/' suj '.CnD.RamaBigCov.mat'])
    
    sig1 = squeeze(virtsens.trial{1}(88,:));
    sig2 = squeeze(virtsens.trial{1}(88,:));
        
    [phdif,pc,Rx,Ry] = rid_rihaczek_bivariate_phacoh(sig1,sig1,delta);
    
end