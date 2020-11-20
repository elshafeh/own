clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj         = suj_list{sb};
    
    list_cue    = {'1'};
    list_ix_cue = {0:2};
    list_ix_tar = {1:4};
    list_ix_dis = {1};
    
    for ext_essai   = {'fDIS.broadAud','DIS.broadAud'}
        
        fname       = ['../data/' suj '/field/' suj '.' ext_essai{:} '.1t20Hz.m200p800msCov.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        virtsens                  = h_removeEvoked(virtsens); %% !!
        
        original_virtsens_pha     = virtsens ; clear virtsens;
        
        fname       = ['../data/' suj '/field/' suj '.' ext_essai{:} '.50t120Hz.m200p800msCov.mat'];
        
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        virtsens                  = h_removeEvoked(virtsens); %% !!
        
        original_virtsens_amp     = virtsens ; clear virtsens;
        
        for ncue = 1:length(list_cue)
            trial_index{ncue}     = h_chooseTrial(original_virtsens_pha,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        end
        
        list_method             = {'canolty','plv','tort'};
        
        list_time               = 0.35;
        list_wind               = 0.3;
        
        list_toi                = list_time;
        list_toi(2,:)           = list_time + list_wind ;
        chan_list               = 1:length(original_virtsens_pha.label);
        
        cfg                      = [];
        pha_freq_vec             = [5 20];
        amp_freq_vec             = [50 120];
        pha_step                 = 1;
        amp_step                 = 5;
        
        [mpac,mpac_norm,mpac_surr]      = separate_calc_MI_optimised(original_virtsens_pha,original_virtsens_amp, ...
            list_toi,pha_freq_vec,amp_freq_vec,'no','yes',list_method,pha_step,amp_step,chan_list,trial_index);
        
        for ncue = 1:length(list_cue)
            for ntime = 1:size(list_toi,2)
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
                        
                        fname_ext1      = ['../data/' suj '/field/' suj '.' list_cue{ncue} ext_essai{:}];
                        
                        fname_ext2      = ['.' ext_time '.' original_virtsens_pha.label{chan_list(nchan)} '.' list_method{nmethod} '.optimisedPACMinEvoked.mat'];
                        
                        fprintf('Saving %30s\n',[fname_ext1 fname_ext2]);
                        
                        save([fname_ext1 fname_ext2],'seymour_pac','-v7.3');
                        
                        clear seymour_pac fname_*
                        
                    end
                end
            end
        end
    end
end