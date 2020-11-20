clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj                                         = suj_list{sb};
    vox_size                                    = 0.5;
    cond_main                                   = {'DIS','fDIS'};
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
    load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    for n_main = 1:length(cond_main)
        
        fname_in                                    = ['../data/' suj '/field/' suj '.' cond_main{n_main} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        data_carrier{n_main} = data_elan ; clear data_elan ;
        
    end
    
    data_concat             = ft_appenddata([],data_carrier{:});
    
    cfg                     = [];
    cfg.toilim              = [-0.2 0.8];
    poi                     = ft_redefinetrial(cfg, data_concat);
    
    ext_time                = ['m' num2str(abs(cfg.toilim(1))*1000) 'p' num2str((cfg.toilim(2))*1000)];
    
    cfg                     = [];
    cfg.method              = 'mtmfft'; cfg.output              = 'fourier'; cfg.keeptrials          = 'yes';
    cfg.foi                 = 10;
    cfg.tapsmofrq           = 4;
    cfg.taper               = 'hanning';
    freqCommon              = ft_freqanalysis(cfg,data_concat);
    
    ext_freq                = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];
    
    cfg                     = [];
    cfg.frequency           = freqCommon.freq;
    cfg.method              = 'pcc';
    cfg.grid                = leadfield;
    cfg.headmodel           = vol;
    cfg.keeptrials          = 'yes'; cfg.pcc.lambda          = '10%'; cfg.pcc.projectnoise    = 'yes'; cfg.pcc.keepfilter      = 'yes'; cfg.pcc.fixedori        = 'yes';
    source                  = ft_sourceanalysis(cfg, freqCommon);
    com_filter              = source.avg.filter;
    
    clear source freqCommon
    
    name_extra      = 'Hanning';
    
    FnameFilterOut = [suj '.' cond_main{:} '.' ext_freq '.' ext_time '.PCCommonFilter' name_extra num2str(vox_size) 'cm'];
    
    fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
    
    save(['../data/' suj '/field/' FnameFilterOut '.mat'],'com_filter','-v7.3');
    
    tlist                                   = 0.35;
    twin                                    = 0.3;
    tpad                                    = 0;

    flist                                   = 10;
    fpad                                    = 3;
    
    for n_main = 1:length(cond_main)
        
        data_elan                               = data_carrier{n_main};
        
        for nfreq = 1:length(flist)
            for ntime = 1:length(tlist)
                
                list_ix_cue_side                = {'1'};
                list_ix_cue_code                = {0:2};
                list_ix_dis_code                = {1:2};
                list_ix_tar_code                = {1:4};
                
                for ncue = 1:length(list_ix_cue_side)
                    
                    cfg                         = [];
                    cfg.toilim                  = [tlist(ntime)-tpad tlist(ntime)+tpad+twin(ntime)];
                    cfg.trials                  = h_chooseTrial(data_elan,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
                    poi                         = ft_redefinetrial(cfg, data_elan);
                    
                    poi                         = h_removeEvoked(poi);
                    
                    cfg                         = [];
                    cfg.method                  = 'mtmfft';
                    cfg.output                  = 'fourier';
                    cfg.keeptrials              = 'yes';
                    cfg.taper                   = 'hanning';
                    cfg.foi                     = flist(nfreq);
                    cfg.tapsmofrq               = fpad(nfreq);
                    freq                        = ft_freqanalysis(cfg,poi);
                    
                    if tlist(ntime) < 0
                        ext_ext= 'm';
                    else
                        ext_ext='p';
                    end
                    
                    ext_time                    = [ext_ext num2str(abs(tlist(ntime)*1000)) ext_ext num2str(abs((tlist(ntime)+twin(ntime))*1000))];
                    ext_freq                    = [num2str(flist(nfreq)-cfg.tapsmofrq) 't' num2str(flist(nfreq)+cfg.tapsmofrq) 'Hz'];
                    
                    cfg                         = [];
                    cfg.frequency               = freq.freq;
                    cfg.method                  = 'pcc';
                    cfg.grid                    = leadfield;
                    cfg.grid.filter             = com_filter;
                    cfg.headmodel               = vol;
                    cfg.keeptrials              = 'yes';
                    cfg.pcc.lambda              = '10%';
                    cfg.pcc.projectnoise        = 'yes';
                    source                      = ft_sourceanalysis(cfg, freq);
                    source.pos                  = grid.MNI_pos;
                    
                    source                      = rmfield(source,'cfg'); source  = rmfield(source,'method'); source = rmfield(source,'trialinfo'); source = rmfield(source,'freq');
                    
                    name_extra                  = 'HanningMinEvoked';
                    
                    ext_name                    = [suj '.' list_ix_cue_side{ncue} cond_main{n_main} '.' ext_time '.' ext_freq '.OriginalPCC' name_extra num2str(vox_size) 'cm'];
                    
                    fprintf('Saving %s\n',ext_name);
                    
                    save(['../data/' suj '/field/' ext_name '.mat'],'source','-v7.3');
                    
                end
            end
        end
    end
    
    clear leadfield com_filter data_elan vol grid
    
end