clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);
%
% suj_group{2}    = {'uc5' 'yc17' 'yc18' 'uc6' 'uc7' 'uc8' 'yc19' 'uc9' ...
%     'uc10' 'yc6' 'yc5' 'yc9' 'yc20' 'yc21' 'yc12' 'uc1' 'uc4' 'yc16' 'yc4'};
% suj_group{3}    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
%     'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
%
% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{4}    = allsuj(2:15,1);
% suj_group{5}    = allsuj(2:15,2);
%
% suj_list        = [suj_group{1};suj_group{2}';suj_group{3}';suj_group{4};suj_group{5}];
% suj_list        = unique(suj_list);

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

[~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{3}        = suj_group{3}(2:22);
suj_list            = [suj_group{1};suj_group{2};suj_group{3}]; suj_list = unique(suj_list);

for sb = 1:length(suj_list)
    
    suj     = suj_list{sb};
    
    list_cue    = {'RCnD','LCnD','NRCnD','NLCnD','CnD','NCnD'};
    list_ix_cue = {2,1,0,0,0:2,0};
    list_ix_tar = {[2 4],[1 3],[2 4],[1 3],1:4,1:4};
    list_ix_dis = {0,0,0,0,0,0};
    
    load(['../data/' suj '/field/' suj '.CnD.100Slct.RLNRNL.mat']);
    
    ext_essai   = 'broadAreas';
    
    fname       = ['../data/' suj '/field/' suj '.CnD.' ext_essai '.1t20Hz.m800p2000msCov.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    original_virtsens_pha     = virtsens ; clear virtsens;
    
    fname       = ['../data/' suj '/field/' suj '.CnD.' ext_essai '.50t120Hz.m800p2000msCov.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    original_virtsens_amp     = virtsens ; clear virtsens;
    
    for ncue = 1:length(list_cue)
        
        list_method             = {'PLV'}; 
        list_time               = [-1 0.2 -0.6 0.2 0.6];
        list_wind               = [0.8 0.8 0.4 0.4 0.4];
        
        for chan = 1:length(original_virtsens_pha.label)
            
            cfg                         = [];
            cfg.channel                 = chan;
            cfg.trials                  = h_chooseTrial(original_virtsens_pha,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
            chan_slct_virtsens_pha      = ft_selectdata(cfg,original_virtsens_pha);
            chan_slct_virtsens_amp      = ft_selectdata(cfg,original_virtsens_amp);
            
            for nme = 1:length(list_method)
                for ntime = 1:size(list_time,2)
                                        
                    pha_freq_vec                    = [5 15];
                    amp_freq_vec                    = [50 120];
                    
                    pha_step                        = 1;
                    amp_step                        = 5;
                    
                    [mpac,mpac_norm,mpac_surr]      = separate_calc_MI('',chan_slct_virtsens_pha,chan_slct_virtsens_amp, ...
                        [list_time(ntime) list_time(ntime)+list_wind(ntime)],pha_freq_vec,amp_freq_vec,'no','yes',list_method{nme},pha_step,amp_step);
                    
                    seymour_pac.pha_freq_vec         = pha_freq_vec(1):pha_step:pha_freq_vec(2);
                    seymour_pac.amp_freq_vec         = amp_freq_vec(1):amp_step:amp_freq_vec(2);
                    seymour_pac.mpac                 = mpac;
                    seymour_pac.mpac_norm            = mpac_norm;
                    seymour_pac.mpac_surr            = mpac_surr;
                    
                    clear mpac*
                    
                    clc;
                    
                    if list_time(ntime) < 0
                        ext_time    = ['m' num2str(abs(list_time(ntime))*1000) 'm' num2str(abs(list_time(ntime)+list_wind(ntime))*1000)];
                    else
                        ext_time    = ['p' num2str(abs(list_time(ntime))*1000) 'p' num2str(abs(list_time(ntime)+list_wind(ntime))*1000)];
                    end
                    
                    fname_ext1  = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' ext_essai];
                    
                    fname_ext2  = ['.' ext_time '.' chan_slct_virtsens_pha.label{1} '.' list_method{nme} '.PAC.mat'];
                    
                    fprintf('Saving %30s\n',[fname_ext1 fname_ext2]);
                    save([fname_ext1 fname_ext2],'seymour_pac','-v7.3');

                    clear seymour_pac fname_*
                    
                end
            end
        end
    end
end