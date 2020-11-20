clear ; clc ; dleiftrip_addpath ;

load ../data/template/source_struct_template_MNIpos.mat;
load ../data/yctot/rt/rt_CnD_adapt.mat ;

template_source = source ; clear source ;

suj_list = [1:4 8:17];

cnd_time = {{'.m600m200','.p600p1000'}};

for sb = 1:14
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_freq = {'11t15'} ;
    
    for cf = 1
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) ...
                    '.CnD' cnd_time{cf}{ix} '.' cnd_freq{cf} 'Hz' ...
                     '.NewSource.mat']);
                
                fname = fname.name;
                fprintf('Loading %50s\n',fname);
                load(['../data/source/' fname]);
                
                source = nanmean(source,2);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            tmp{ix}     = mean([src_carr{1} src_carr{2} src_carr{3}],2);
            
            clear src_carr
            
        end
        
        powpow                       = (tmp{2}-tmp{1})./tmp{1};
        DataMat2Corr(sb,cf,:)        = powpow;
        
        clear powpow
        
    end
end

load ../data/yctot/rt/rt_CnD_adapt.mat ;

rtCorrMat(:,1)  = cellfun(@median,rt_all);
% rtCorrMat(:,2)  = cellfun(@mean,rt_all);

clearvars -except DataMat2Corr rtCorrMat template_source ;

for rt = 1
    for f = 1
        
        [rho,p] = corr(squeeze(DataMat2Corr(:,f,:)),rtCorrMat(:,rt), 'type', 'Pearson');
        mask    = p < 0.05;

        source{rt,f}.pow        = rho .* mask ;
        source{rt,f}.dim        = template_source.dim;
        source{rt,f}.pos        = template_source.pos;
        
        vox_list{rt,f}                = FindSigVoxels(source{rt,f});
        
        source_int{rt,f}        = h_interpolate(source{rt,f});
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'pow';
        cfg.colorbar            = 'yes';
        %         cfg.nslices             = 1;
        %         cfg.slicerange          = [70 80];
        cfg.funcolorlim         = [-1 1];
        ft_sourceplot(cfg,source_int{rt,f});clc;
        
    end
end

% for f = 1:2
%     gavg.pow                = squeeze(mean(DataMat2Corr(:,f,:),1));
%     gavg.dim                = template_source.dim;
%     gavg.pos                = template_source.pos;
%     
%     gavg_int                = h_interpolate(gavg);
%     
%     cfg                     = [];
%     cfg.method              = 'slice';
%     cfg.funparameter        = 'pow';
%     cfg.colorbar            = 'no';
%     %     cfg.nslices             = 1;
%     %     cfg.slicerange          = [70 80];
%     cfg.funcolorlim         = [-0.1 0.1];
%     ft_sourceplot(cfg,gavg_int);clc;
%     
% end