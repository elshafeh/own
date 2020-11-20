clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

suj_group{2}    = {'uc5' 'yc17' 'yc18' 'uc6' 'uc7' 'uc8' 'yc19' 'uc9' ...
    'uc10' 'yc6' 'yc5' 'yc9' 'yc20' 'yc21' 'yc12' 'uc1' 'uc4' 'yc16' 'yc4'};
suj_group{3}    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{4}    = allsuj(2:15,1);
suj_group{5}    = allsuj(2:15,2);

suj_list        = [suj_group{1};suj_group{2}';suj_group{3}';suj_group{4};suj_group{5}];
suj_list        = unique(suj_list);

for sb = 1:length(suj_list)
    
    suj              = suj_list{sb};
    
    for cond_main = {'DIS','fDIS'}
        
        fname            = ['../data/' suj '/field/' suj '.' cond_main{:} '.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        cfg              = [];
        cfg.channel      = {'MLC17', 'MLC25', 'MLF67', 'MLP44', 'MLP45', 'MLP56', 'MLP57', 'MLT14', ...
            'MLT15', 'MLT25', 'MRC17', 'MRF66', 'MRF67', 'MRP57', 'MRT13', 'MRT14', 'MRT24'};
        cfg.avgoverchan  = 'yes';
        data_elan        = ft_selectdata(cfg,data_elan);
        data_elan.label  = {'SensAvg'};
        
        cfg              = [];
        cfg.output       = 'fourier';
        cfg.method       = 'mtmconvol';
        cfg.taper        = 'hanning';
        cfg.foi          = 1:1:120;
        cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
        cfg.toi          = -2:.01:2;
        cfg.keeptrials   ='yes';
        freq             = ft_freqanalysis(cfg,data_elan);
        
        cfg               = [];
        cfg.index         = 'all';
        cfg.indexchan     = 'all';
        cfg.alpha         = 0.05;
        cfg.freq          = [1 120];
        cfg.time          = [-2 2];
        phase_lock        = mbon_PhaseLockingFactor(freq, cfg);
        
        %         cfg               = [];
        %         cfg.zlim          = [0 0.5];
        %         cfg.xlim          = [-0.2 2];
        %         cfg.ylim          = [1 120];
        %         cfg.parameter     = 'powspctrm';
        %         cfg.maskparameter = 'mask';
        %         cfg.maskstyle     = 'opacity';
        %         cfg.maskalpha     = 0.5;
        %         ft_singleplotTFR(cfg,phase_lock);
        
        save(['../data/' suj '/field/' suj '.' cond_main{:} '.leftRightSens.PhaseLockingValueAndFreq.mat'],'phase_lock','freq');
        
    end
end