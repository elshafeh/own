clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj     = suj_list{sb};
    vox_size            = 0.5;
    cond_main           = 'CnD';
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
    load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    fname_in            = ['../data/' suj '/field/' suj '.' cond_main '.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
    
    big_elan            = data_elan ; clear data_elan ;
    
    for name_extra      = {'100SlctMinEvoked'}
        
        load(['../data/' suj '/field/' suj '.CnD.5t15Hz.m800p2000.PCCommonFilter' name_extra{:} num2str(vox_size) 'cm.mat']);
        
        cfg                     = [];
        data_elan               = ft_selectdata(cfg, big_elan);
        
        tlist                   = [-0.6 0.6];
        flist                   = 9;
        twin                    = 0.4;
        tpad                    = 0.025;
        fpad                    = 2;
        
        for f = 1:length(flist)
            for t = 1:length(tlist)
                
                list_ix_cue_side            = {'N'};
                list_ix_cue_code            = {0};
                list_ix_dis_code            = {0};
                list_ix_tar_code            = {1:4};
                
                for ncue = 1:length(list_ix_cue_side)
                    
                    cfg                     = [];
                    cfg.toilim              = [tlist(t)-tpad tlist(t)+tpad+twin];
                    cfg.trials              = h_chooseTrial(data_elan,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
                    poi                     = ft_redefinetrial(cfg, data_elan);
                    
                    if strcmp(name_extra{:},'100SlctMinEvoked')
                        poi                     = h_removeEvoked(poi);
                    end
                    
                    cfg                     = [];
                    cfg.method              = 'mtmfft';
                    cfg.output              = 'fourier';
                    cfg.keeptrials          = 'yes';
                    cfg.foi                 = flist(f);
                    cfg.tapsmofrq           = fpad;
                    freq                    = ft_freqanalysis(cfg,poi);
                    
                    if tlist(t) < 0
                        ext_ext= 'm';
                    else
                        ext_ext='p';
                    end
                    
                    ext_time              = [ext_ext num2str(abs(tlist(t)*1000)) ext_ext num2str(abs((tlist(t)+twin)*1000))];
                    ext_freq              = [num2str(flist(f)-cfg.tapsmofrq) 't' num2str(flist(f)+cfg.tapsmofrq) 'Hz'];
                    
                    cfg                   = [];
                    cfg.frequency         = freq.freq;
                    cfg.method            = 'pcc';
                    cfg.grid              = leadfield;
                    cfg.grid.filter       = com_filter;
                    cfg.headmodel         = vol;
                    cfg.keeptrials        = 'yes';
                    cfg.pcc.lambda        = '10%';
                    cfg.pcc.projectnoise  = 'yes';
                    source                = ft_sourceanalysis(cfg, freq);
                    source.pos            = grid.MNI_pos;
                    
                    source                = rmfield(source,'cfg');
                    source                = rmfield(source,'method');
                    source                = rmfield(source,'trialinfo');
                    source                = rmfield(source,'freq');
                    
                    ext_name              = [suj '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.OriginalPCC' name_extra{:} num2str(vox_size) 'cm'];
                    
                    fprintf('Saving %s\n',ext_name);
                    
                    save(['../data/' suj '/field/' ext_name '.mat'],'source','-v7.3');
                    
                    clear source freq
                    
                end
            end
        end
    end
    clear leadfield com_filter data_elan vol grid
    
end