clear ; clc ;

ix_f = 0 ;

for ext_freq = {'8t10Hz','12t14Hz'};
    
    ix_f = ix_f + 1;
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        sourceAppend = [];
        list_time = {'m600m200','p600p1000'};
        
        for prt = 1:3
            
            for cnd = 1:2
                
                fname = dir(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/*.pt' num2str(prt) ...
                    '*.CnD.KT.*' ext_freq{:} '*' list_time{cnd} ...
                    '.bsl.5mm.source.mat']);
                
                fname = fname.name;
                
                fprintf('Loading %50s\n',fname);
                
                load(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/' fname]);
                
                source_carr{cnd} = source ; clear source ;
                
            end
            
            relchange = (source_carr{2} - source_carr{1}) ./ source_carr{1};
            
            sourceAppend = [ sourceAppend relchange];
            
            clear relchange sourc_carr
            
        end
        
        load ../data/yctot/rt_CnD_adapt.mat
        
        fprintf('Calculating Correlation\n');
        
        [rho,p]     = corr(sourceAppend',rt_all{sb} , 'type', 'Spearman');
        
        %         isig        = find(p>0.05 & ~isnan(p));
        %         rho(isig)   = 0 ;
        
        rhoF        = .5.*log((1+rho)./(1-rho));
        
        source_avg{sb,ix_f}.pow = rhoF ;
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        source_avg{sb,ix_f}.pos    = source.pos;
        source_avg{sb,ix_f}.dim    = source.dim;
        source_avg{sb,ix_f}.inside = source.inside;
        
        clear rho rhoF avg
        
    end
    
    clearvars -except ext_freq ix_f source_avg indx_tot
    
end

load ../data/template/source_struct_template_MNIpos.mat
indx_tot = h_createIndexfieldtrip(source); clear source ;
% indx_tot(indx_tot(:,2) > 78 & indx_tot(:,2) < 83,:) = [];


% indx_tot(indx_tot(:,2) == 50,:) = [];
% indx_tot(indx_tot(:,2) == 52,:) = [];
% indx_tot(indx_tot(:,2) == 54,:) = [];

% load ../data/template/source_struct_template_MNIpos.mat
% indx  = h_createIndexfieldtrip(source); clear source ;
% load ../../../PAT_MEG/Fieldtripping/data/yctot/ArsenalIndex.mat;
% 
% for n = 1:length(indx)
%     if ~isempty(indx_tot(indx_tot(:,1)==indx(n,1)))
%         indx(n,:) = 0;
%     end
% end

% indx_tot = indx(indx(:,1)~=0,:);

for ix_f = 1:2
    for sb = 1:14
        source_avg{sb,ix_f}.pow(indx_tot(:,1)) = 0 ;
    end
end

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusteralpha        =   0.05;             % First Threshold
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;
cfg.tail                =   0;
cfg.clustertail         =   0;
nsuj                    =   size(source_avg,1);
cfg.design(1,:)         =   [1:nsuj 1:nsuj];
cfg.design(2,:)         =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;
stat                    = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2});

stat_int = h_interpolate(stat);

stat_int.mask           = stat_int.prob < 0.05;
cfg                     = [];
cfg.method              = 'slice';
cfg.funparameter        = 'stat';
cfg.maskparameter       = 'mask';
cfg.nslices             = 16;
cfg.slicerange          = [70 84];
cfg.funcolorlim         = [-3 3];
ft_sourceplot(cfg,stat_int);clc;

for c = 1:2
    gavg{c} = ft_sourcegrandaverage([],source_avg{:,1});
    gint{c} = h_interpolate(gavg{c});
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'pow';
    cfg.nslices             = 16;
    cfg.slicerange          = [70 84];
    cfg.funcolorlim         = [-0.05 0.05];
    ft_sourceplot(cfg,gint{c});clc;
end