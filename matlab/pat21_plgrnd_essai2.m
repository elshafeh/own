clear;clc;

for sb = 1
    
    for prt = 1:3
        
        suj_list = [1:4 8:17];
        
        st_point = [-0.6 0.6];
        
        lck = 'CnD' ;
        suj = ['yc' num2str(suj_list(sb))] ;
        
        fname_in = [suj '.pt' num2str(prt) '.' lck];
        fprintf('\n\nLoading %50s \n\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        data = data_elan ;
        
        clear data_elan
        
        % Select period of interests
        
        tim_win = 0.4;
        
        for timep = 1:length(st_point)
            
            lm1 = st_point(timep)-0.015;
            lm2 = st_point(timep)+tim_win+0.015;
            
            cfg             = [];
            cfg.toilim      = [lm1 lm2];
            poi             = ft_redefinetrial(cfg, data);
            
            % Fourrier transform
            
            f_focus = 9;
            f_tap   = 2;
            
            cfg            = [];
            cfg.method     = 'mtmfft';
            cfg.output     = 'fourier';
            cfg.keeptrials = 'yes';
            cfg.tapsmofrq  = f_tap;
            cfg.foi        = f_focus;
            freq           = ft_freqanalysis(cfg,poi);
            
            load(['../data/' suj '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
            load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
            
            %             load(['../data/' suj '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.1cm.mat']);
            %             load(['../data/' suj  '/headfield/' suj '.VolGrid.1cm.mat']);
            
            load ../data/yctot/index/conMaIndx.mat ;
            
            cfg                   = [];
            cfg.frequency         = freq.freq;
            cfg.method            = 'pcc';
            cfg.grid.pos          = leadfield.pos(indx_tot(1:10,1),:);
            cfg.headmodel         = vol;
            cfg.keeptrials        = 'yes';
            cfg.pcc.lambda        = '10%';
            cfg.pcc.projectnoise  = 'yes';
            cfg.pcc.keepfilter    = 'yes';
            cfg.pcc.fixedori      = 'yes';
            cfg.pcc.keepmom       = 'yes';
            source{sb,prt,timep}  = ft_sourceanalysis(cfg, freq);
            
            clear freq poi
            
        end
        
    end
    
end

clearvars -except source

for ix_cnd = 1:2
    
    source_appnd{ix_cnd}                = [];
    %     source_appnd{ix_cnd}.dim            = source{1,1,1}.dim ;
    source_appnd{ix_cnd}.pos            = source{1,1,1}.pos ;
    source_appnd{ix_cnd}.freq           = source{1,1,1}.freq ;
    source_appnd{ix_cnd}.method         = source{1,1,1}.method ;
    source_appnd{ix_cnd}.inside         = source{1,1,1}.inside ;
    
    for ii = 1:length(source{1,1,1}.avg.mom)
        
        x = source{1,1,ix_cnd}.avg.mom{ii};
        y = source{1,2,ix_cnd}.avg.mom{ii};
        z = source{1,3,ix_cnd}.avg.mom{ii};
        
        source_appnd{ix_cnd}.avg.mom{ii,1}   = cat(2,x,y,z);
        
        clear x y z
        
    end
    
    source_appnd{ix_cnd}.trialinfo = [source{1,1,ix_cnd}.trialinfo ;source{1,2,ix_cnd}.trialinfo ;source{1,3,ix_cnd}.trialinfo];
    %     source_appnd{ix_cnd}.cumtapcnt = [source{1,1,ix_cnd}.cumtapcnt ;source{1,2,ix_cnd}.cumtapcnt ;source{1,3,ix_cnd}.cumtapcnt];
    
    cfg                     = [];
    cfg.method              = 'coh';
    cfg.complex             = 'absimag';
    source_conn{ix_cnd}     = ft_connectivityanalysis(cfg, source_appnd{ix_cnd});
    
end

clear ii ix_cnd

% source_conn_bsl.cohspctrm = reshape(source_conn_bsl.cohspctrm,102,102);
% source_conn_act.cohspctrm = reshape(source_conn_act.cohspctrm,102,102);

% figure;imagesc(source_conn_bsl.cohspctrm);
% figure;imagesc(source_conn_act.cohspctrm);
% figure;imagesc(source_conn_act.cohspctrm - source_conn_bsl.cohspctrm);zlim([0 0.5]);

% atlas = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii'); clc ;

load atlas_MMP1.0_4k.mat

cfg                 = [];
cfg.interpmethod    = 'nearest';
cfg.parameter       = 'all';
at2source           = ft_sourceinterpolate(cfg, atlas, source_conn{1});
source2at           = ft_sourceinterpolate(cfg, source_conn{1}, atlas);

at2source.pos = source_conn{1}.pos;

cfg                 = [];
cfg.parcellation    = 'parcellation';
cfg.parameter       = 'cohspctrm';
source_parc         = ft_sourceparcellate(cfg, source_conn{1}, at2source);

cfg                 = [];
cfg.inputcoord      = 'mni';
cfg.roi             = atlas.parcellationlabel;
cfg.atlas           = atlas ; 
mask                = ft_volumelookup(cfg, source_conn_bsl);