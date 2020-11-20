clear ; clc ;

suj_list = [1:4 8:17];

load ../data/yctot/stat4roi.mat

atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

cfg                 = [];cfg.interpmethod    = 'nearest';cfg.parameter       = 'tissue';stat_atlas          = ft_sourceinterpolate(cfg, atlas, stat);

load ../data/template/template_grid_1cm.mat

roi = {'Heschl_L','Heschl_R','Temporal_Sup_L','Temporal_Sup_R'};

template_grid       =   ft_convert_units(template_grid,'mm');

posH = [];

for d = 1:length(roi)
    x                       =   find(ismember(atlas.tissuelabel,roi{d}));
    indxH                   =   find(stat_atlas.tissue==x);
    posH                    =   [posH;template_grid.pos(indxH,:) repmat(d,size(template_grid.pos(indxH,:),1),1)];                       % xyz positions in mni coordinates
end

clearvars -except posH suj_list;clc;

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))];
    
    mri                     =   ft_read_mri(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/mri/processed/' suj '_T1_converted_V2.mri']);
    norm                    =   ft_volumenormalise([],mri);
    posb                    =   ft_warp_apply(norm.params,posH(:,1:3),'sn2individual');
    btiposH                 =   ft_warp_apply(pinv(norm.initial),posb);          % xyz positions in individual coordinates
    
    load(['../data/' suj '/elan/' suj '.pt1.NDIS1.mat']);
    
    load(['../data/' suj '/headfield/' suj '.VolGrid.1cm.mat']);
    
    hdm = vol; clear vol ;
    
    cfg                     =   [];
    cfg.vol                 =   hdm;
    cfg.channel             =   data_elan.label;
    cfg.grid.pos            =   btiposH./10;% units of m
    cfg.grad                =   data_elan.grad;
    sourcemodel             =   ft_prepare_leadfield(cfg);
    
    clear mri norm posb data_elan
    
    for b = 1:3
        
        cnd = {'RCnD','LCnD','NCnD'};
        
        data = {} ; freq = {} ;
        
        for c = 1:3
            
            fname_in = [suj '.pt' num2str(b) '.' cnd{c}];
            fprintf('\n\nLoading %50s \n\n',fname_in);
            load(['../data/' suj '/elan/' fname_in '.mat'])
            data{c}         = data_elan ;
            clear data_elan
            
        end
        
        data{end+1} = ft_appenddata([],data{:});
        
        for d = 1:4
            
            cfg                 = [];
            cfg.toi             = -2:0.05:2;
            cfg.method          = 'wavelet';
            cfg.output          = 'powandcsd';
            cfg.foi             =  5:1:15;
            cfg.width           =  7 ;
            cfg.gwidth          =  4 ;
            tmp                 = ft_freqanalysis(cfg,data{d});
            
            cfg = [];
            cfg.baseline        = [-0.7 0.2];
            cfg.baselinetype    = 'relchange';
            freq{d}             = ft_freqbaseline(cfg,tmp);
            
            cfg             = [];
            cfg.frequency   = [7 14];
            cfg.avgoverfreq = 'yes';
            freq{d}         = ft_selectdata(cfg,freq{d});
            
            freq{d}.labelcmb = tmp.labelcmb;
            
            clear tmp
            
        end
        
        % Create common filter
        
        cfg             = [];
        cfg.latency     = [-0.7 1.2];
        cfg.avgovertime = 'yes';
        freq_com        = ft_selectdata(cfg,freq{4});
        
        cfg                     = [];
        cfg.method              = 'dics';
        cfg.frequency           = freq_com.freq;
        cfg.latency             = freq_com.time;
        cfg.grid                = sourcemodel;
        cfg.headmodel           = hdm;
        cfg.dics.projectnoise   = 'yes';
        cfg.dics.lambda         = '5%';
        cfg.dics.keepfilter     = 'yes';
        source_com              = ft_sourceanalysis(cfg,freq_desc);
        
        cfg             = [];
        cfg.toilim      = [0.8 0.85];
        poi             = ft_redefinetrial(cfg, data_elan);
        
        cfg                     = [];
        cfg.method              = 'mtmfft';
        cfg.foi                 = 11;
        cfg.tapsmofrq           = 20;
        cfg.output              = 'powandcsd';
        freq_fft                = ft_freqanalysis(cfg,poi);
        
    end
    
end