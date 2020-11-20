clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list                        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for sb = 1:length(suj_list)
    
    suj                         = suj_list{sb};
    
    list_cue                    = {'CnD','RCnD','LCnD','NCnD'};
    list_ix_cue                 = {0:2,2,1,0};
    list_ix_tar                 = {1:4,1:4,1:4,1:4};
    list_ix_dis                 = {0,0,0,0};
    
    dir_data                    = '../data/paper_data/';
    ext_essai                   = 'prep21.AV';
    fname                       = [dir_data suj '.CnD.' ext_essai '.1t20Hz.m800p2000msCov.mat']; fprintf('Loading %30s\n',fname);  load(fname);
    
    slct_channel                = 4;
    cfg                         = []; cfg.channel                 = slct_channel; virtsens                    = ft_selectdata(cfg,virtsens);
    virtsens                    = h_removeEvoked(virtsens); %% !!
    
    original_virtsens_pha       = virtsens ; clear virtsens;
    
    fname                       = [dir_data suj '.CnD.' ext_essai '.50t120Hz.m800p2000msCov.mat']; fprintf('Loading %30s\n',fname);  load(fname);
    cfg                         = []; cfg.channel                 = slct_channel; virtsens                    = ft_selectdata(cfg,virtsens);
    virtsens                    = h_removeEvoked(virtsens); %% !!
    
    original_virtsens_amp       = virtsens ; clear virtsens;
    
    for ncue = 1:length(list_cue)
        trial_index{ncue}     = h_chooseTrial(original_virtsens_pha,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
    end
    
    list_method                 = {'ozkurt'};
    
    list_time                   = [-0.6 0.6];
    list_wind                   = [0.4 0.4];
    
    list_toi                    = list_time;
    list_toi(2,:)               = list_time + list_wind;
    chan_list                   = 1;
    
    pha_freq_vec                = [7 20];
    amp_freq_vec                = [50 110];
    pha_step                    = 1;
    amp_step                    = 2;
    
    ext_freq                    = ['low.' num2str(pha_freq_vec(1)) 't' num2str(pha_freq_vec(2)) '.high2step.' num2str(amp_freq_vec(1)) 't' num2str(amp_freq_vec(2))];
    
    [mpac,mpac_norm,mpac_surr,mpac_std]  = separate_calc_MI_optimised(original_virtsens_pha,original_virtsens_amp, ...
        list_toi,pha_freq_vec,amp_freq_vec,'no','yes',list_method,pha_step,amp_step,chan_list,trial_index);
    
    for ncue = 1:length(list_cue)
        for ntime = 1:length(list_toi)
            for nmethod = 1:length(list_method)
                for nchan = 1:length(chan_list)
                    
                    seymour_pac.pha_freq_vec         = pha_freq_vec(1):pha_step:pha_freq_vec(2);
                    seymour_pac.amp_freq_vec         = amp_freq_vec(1):amp_step:amp_freq_vec(2);
                    seymour_pac.mpac                 = mpac{nchan,ncue,ntime,nmethod};
                    seymour_pac.mpac_norm            = mpac_norm{nchan,ncue,ntime,nmethod};
                    seymour_pac.mpac_surr            = mpac_surr{nchan,ncue,ntime,nmethod};
                    seymour_pac.mpac_std             = mpac_std{nchan,ncue,ntime,nmethod};
                    clc;
                    
                    if list_time(ntime) < 0
                        ext_time    = ['m' num2str(abs(list_time(ntime))*1000) 'm' num2str(abs(list_time(ntime)+list_wind(ntime))*1000)];
                    else
                        ext_time    = ['p' num2str(abs(list_time(ntime))*1000) 'p' num2str(abs(list_time(ntime)+list_wind(ntime))*1000)];
                    end
                    
                    fname_ext1      = [dir_data suj '.' list_cue{ncue} '.' ext_essai];
                    
                    fname_ext2      = ['.' ext_time '.' ext_freq '.' original_virtsens_pha.label{chan_list(nchan)} '.' list_method{nmethod} '.optimisedPACMinEvoked.mat'];
                    
                    fprintf('Saving %30s\n',[fname_ext1 fname_ext2]);
                    
                    save([fname_ext1 fname_ext2],'seymour_pac','-v7.3');
                    
                    clear seymour_pac fname_*
                    
                end
            end
        end
    end
end