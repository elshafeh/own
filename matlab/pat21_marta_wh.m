clear ;clc ;
 
% load ../data/new_rama_data/yc1.CnD.NewRama.1t20Hz.m800p2000msCov.audR.mat
% 
% cfg                 = [];
% cfg.latency         = [-0.6 0.6];
% data                = ft_selectdata(cfg,virtsens);
% 
% cfg                 = [];
% cfg.toi             = data.time{1}(1):0.05:data.time{1}(end);
% cfg.method          = 'mtmconvol';
% cfg.output          = 'pow';
% cfg.taper           = 'hanning';
% cfg.foi             = 2:2:30;
% cfg.t_ftimwin       = ones(length(cfg.foi),1)*0.4;
% 
% freq                = ft_freqanalysis(cfg,data);
% 
% cfg                 = [];
% cfg.baseline        = [-0.3 -0.1];
% cfg.baselinetype    = 'relchange';
% freq_bsl            = ft_freqbaseline(cfg,freq);
% 
% cfg=[];
% % cfg.xlim = [-0.3 0.3];
% cfg.zlim=[-0.1 0.1];
% ft_singleplotTFR(cfg,freq_bsl)

for sub = 1:14
    
    for ncue = 1:2
        
        all_sub_data{sub,cond} = sub*ncue ;
        
    end
end

% [vol, grid]         = marta_headmodel(mri_filename);
%
% hdr                 = ft_read_header(meg_name);
%
%
% cfg                 = [];
% cfg.grid            = grid;
% cfg.headmodel       = vol;
% cfg.channel         = 'MEG';
% cfg.grad            = hdr.grad;
% leadfield           = ft_prepare_leadfield(cfg); % u need leadfield + vol % leadfield comes from vol+grid+header