clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}    = allsuj(2:15,1);
suj_group{3}    = allsuj(2:15,2);

suj_list        = [suj_group{1};suj_group{2};suj_group{3}];
suj_list        = unique(suj_list);

for sb = 2:length(suj_list)
    
    suj     = suj_list{sb};
    
    
    vox_size            = 0.5;
    
    cond_main           = 'CnD';
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']); load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
    
    % create common filter
    
    cfg                     = [];
    cfg.toilim              = [-0.8 2];
    poi                     = ft_redefinetrial(cfg, data_elan);
    
    ext_time                = ['m' num2str(abs(cfg.toilim(1))*1000) 'p' num2str((cfg.toilim(2))*1000)];
    
    cfg                     = [];
    cfg.method              = 'mtmfft'; cfg.output              = 'fourier'; cfg.keeptrials          = 'yes';
    cfg.foi                 = 10;
    cfg.tapsmofrq           = 5;
    freqCommon              = ft_freqanalysis(cfg,poi);
    
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
    
    name_extra      = '';
    
    FnameFilterOut = [suj '.' cond_main '.' ext_freq '.' ext_time '.PCCommonFilter' name_extra num2str(vox_size) 'cm'];
    
    fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
    
    save(['../data/' suj '/field/' FnameFilterOut '.mat'],'com_filter','-v7.3');  clear leadfield com_filter data_elan vol grid com_filter
    
end