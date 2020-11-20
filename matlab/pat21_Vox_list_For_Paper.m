clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/stat/NewSourceDpssStat.mat

for frq = 1:2
    for tm = 1:2
        
        vox_list{frq,tm} = FindSigClusters(stat{frq,tm},0.05);
        
    end
end

load ../data/yctot/stat/CorrSingAgZeroCorr.mat

for ntest = 1:2
    for cnd_bsl = 1:2
        vox_list{ntest,cnd_bsl} = FindSigClusters(stat{ntest,cnd_bsl},0.05);
        [min_p(ntest,cnd_bsl),p_val{ntest,cnd_bsl}]                  =   h_pValSort(stat{ntest,cnd_bsl});
        
    end
end