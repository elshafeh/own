clear ; clc ;

% group{1} = {'oc1','oc10','oc11','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9'};
% group{2} = {'yc19','yc20','yc21','yc22','yc23','yc24','yc26','yc27'};

group{1} = {'oc1','oc10','oc11','oc2','oc3','oc4','oc5','oc6','oc7','oc8','oc9'};
group{2} = {'yc19','yc20','yc21','yc22','yc23','yc24','yc26','yc27'};
% group{3} = {'fp1','fp2','fp3','fp4','fp5','fp6','fp7'};

pos_tot  = [];

for g = 1:length(group)
    for sb = 1:length(group{g});
        
        suj         = group{g}{sb};
        direc_raw   = dir(['../../pat.meeg/rawdata/' suj '/*ds']);
        pos_suj     = [];
        
        for b = 1:size(direc_raw,1)
            dsName      = ['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG22/pat.meeg/rawdata/' suj '/' direc_raw(b).name];
            posnameout  = ['../../pat.meeg/data/' suj '/pos/' direc_raw(b).name '.code.pos'];
            pos_single  = load(posnameout);
            nbloc       = strsplit(direc_raw(b).name,'_');  nbloc = nbloc{4}; nbloc = strsplit(nbloc,'.') ; nbloc = str2double(nbloc{1});
            pos_single  = PrepAtt2_funk_prepare(pos_single,sb,nbloc,g);
            pos_single  = PrepAtt2_funk_behav_recode(pos_single);
            pos_suj     = [pos_suj;pos_single] ; clear pos_single;
        end
        
        pos_tot  = [pos_tot;pos_suj] ; clear pos_suj ;
        
    end
end

behav_summary       = PrepAtt2_funk_behav_summary(pos_tot);
behav_summary        = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS' ;'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON' ;'disON';'tarON';'CLASS';'idx_group'});

clearvars -except behav_summary ;

PrepAtt2_funk_behav_quadplot_rt(behav_summary);
PrepAtt2_funk_NoDisCueEffect(behav_summary);
PrepAtt2_fun_Dis_Effect(behav_summary,1);
PrepAtt2_fun_Dis_Effect(behav_summary,2);
PrepAtt2_funk_RTEvolve(behav_summary);
PrepAtt2_funk_behav_quadplot_perc(behav_summary);