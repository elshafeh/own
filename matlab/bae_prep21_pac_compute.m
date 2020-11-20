clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

suj_list                                = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                 = ['yc' num2str(suj_list(sb))] ;
    
    list_cue                            = {'RCnD','LCnD','CnD','NCnD'};
    list_ix_cue                         = {2,1,0:2,0};
    list_ix_tar                         = {[2 4],[1 3],1:4,1:4};
    list_ix_dis                         = {0,0,0,0};
    
    ext_essai                           = 'prep21.AV';
    dir_data                            = '../../PAT_MEG21/pat.field/data/';
    
    fname                               = [dir_data suj '.CnD.' ext_essai '.1t20Hz.m800p2000msCov.mat'];
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    chan_to_select            = 4;
    
    cfg                       = [];
    cfg.channel               = chan_to_select;
    virtsens                  = ft_selectdata(cfg,virtsens);
    
    virtsens                  = h_removeEvoked(virtsens); %% !!
    
    original_virtsens_pha     = virtsens ; clear virtsens;
    
    fname                     = [dir_data suj '.CnD.' ext_essai '.50t120Hz.m800p2000msCov.mat'];
    
    fprintf('Loading %30s\n',fname);
    load(fname);
    
    cfg                       = [];
    cfg.channel               = chan_to_select;
    virtsens                  = ft_selectdata(cfg,virtsens);
    
    virtsens                  = h_removeEvoked(virtsens); %% !!
    
    original_virtsens_amp     = virtsens ; clear virtsens;
    
    for ncue = 1:length(list_cue)
        trial_index{ncue}     = h_chooseTrial(original_virtsens_pha,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
    end
    
    list_method              = {'PLV','tort','ozkurt','canolty'};
    
    %     list_time                = [-0.3 -0.15 0 0.15 0.3 0.45 0.6 0.75 0.9 -1 0.2 -0.6 0.6];
    %     list_wind                = [0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.8 0.8 0.4 0.4];
    
    list_time                = [0.88 0.76 0.64 0.52 0.40 0.28 0.16 0.04 -0.08 -0.2 -0.32 -0.6 0.6];
    list_wind                = [0.12 0.12 0.12 0.12 0.12 0.12 0.12 0.12 0.12 0.12 0.12 0.4 0.4];
    
    list_toi                 = list_time;
    list_toi(2,:)            = list_time + list_wind ;
    chan_list                = 1;
    
    cfg                      = [];
    pha_freq_vec             = [5 19];
    amp_freq_vec             = [50 110];
    pha_step                 = 1;
    amp_step                 = 10;
    
    [mpac,mpac_norm,mpac_surr]      = separate_calc_MI_optimised(original_virtsens_pha,original_virtsens_amp, ...
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
                    
                    clc;
                    
                    if list_time(ntime) < 0
                        ext_time    = ['m' num2str(abs(list_time(ntime))*1000) 'm' num2str(abs(list_time(ntime)+list_wind(ntime))*1000)];
                    else
                        ext_time    = ['p' num2str(abs(list_time(ntime))*1000) 'p' num2str(abs(list_time(ntime)+list_wind(ntime))*1000)];
                    end
                    
                    fname_ext1      = [dir_data suj '.' list_cue{ncue} '.' ext_essai];
                    
                    fname_ext2      = ['.' ext_time '.' original_virtsens_pha.label{chan_list(nchan)} '.' list_method{nmethod} '.optimisedPACMinEvoked.mat'];
                    
                    fprintf('Saving %30s\n',[fname_ext1 fname_ext2]);
                    
                    save([fname_ext1 fname_ext2],'seymour_pac','-v7.3');
                    
                    clear seymour_pac fname_*
                    
                end
            end
        end
    end
end