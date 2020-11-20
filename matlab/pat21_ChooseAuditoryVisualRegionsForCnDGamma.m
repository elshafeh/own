clear ; clc ; dleiftrip_addpath;

load ../data/yctot/stat/NewSourceDpssStat.mat

atlas           = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');
source          = [];
reg_indx        = [49:54 79:82];
reg_list        = {'OccSupL','OccSupR','OccMidL','OccMidR','OccInfL','OccInfR' , ...
    'HgL','HgR','stgL','stgR'};

list_time       = {'1','2','3'};
list_freq       = {'lo','hi'};

audvis_vox      = [];
audvis_list     = {};

for nroi = 1:length(reg_indx)
    for nfreq = 1:size(stat,1)
        for ntime = 1:size(stat,2)
            
            if (strcmp(list_freq{nfreq},'lo') && ~strcmp(reg_list{nroi}(1),'O')) || (strcmp(list_freq{nfreq},'hi') && strcmp(reg_list{nroi}(1),'O'))
                
                [~,tmp]         = h_findStatMaxVoxelPerRegion(stat{nfreq,ntime},0.05,reg_indx(nroi),5);clc;
                
                audvis_vox      = [audvis_vox;tmp];
                
                for x = 1:length(tmp)
                    new_label       = [reg_list{nroi} '_' list_time{ntime} list_freq{nfreq} num2str(x)];
                    audvis_list{end+1,1} = new_label ;
                end
                
                clear new_label x tmp;
                
            end
            
        end
    end
end

clearvars -except audvis_vox audvis_list;

% for nroi = 1:length(reg_list)
%     slct{nroi} = unique(bmatrix{nroi});
% end
% indx_arsenal = [];
% list_arsenal = {};
% for nroi = 1:length(reg_list)
%     indx_arsenal = [indx_arsenal; slct{nroi} repmat(nroi,length(slct{nroi}),1)];
% end
% clearvars -except *arsenal*

save('../data/yctot/index/CnDAudVis4Gamma.mat','audvis_list','audvis_vox');

load ../data/template/source_struct_template_MNIpos.mat ;

source                               = rmfield(source,'freq');
source                               = rmfield(source,'method');
source                               = rmfield(source,'cumtapcnt');
source.pow                           = source.avg.pow;
source                               = rmfield(source,'avg');
source.pow(:,:)                      = NaN ;

for n = 1:length(audvis_vox)
    source.pow(audvis_vox(n),:)          = n ;
end

cfg                     =   [];
cfg.method              =   'surface';
cfg.funparameter        =   'pow';
cfg.funcolorlim         =   [0 length(audvis_vox)];
cfg.opacitylim          =   [0 length(audvis_vox)];
cfg.opacitymap          =   'rampup';
cfg.colorbar            =   'off';
cfg.camlight            =   'no';
cfg.projthresh          =   0.2;
cfg.projmethod          =   'nearest';
cfg.surffile            =   'surface_white_both.mat';
cfg.surfinflated        =   'surface_inflated_both_caret.mat';
% ft_sourceplot(cfg, source);