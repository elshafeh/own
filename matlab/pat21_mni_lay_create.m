clear ; clc ; 

load ../data/stock/template_grid_0.5cm.mat;

atlas           = ft_read_atlas('~/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
source          = template_grid;

[indxH]      	= h_createIndexfieldtrip(source.pos,atlas); clc ;
whereWeLook     = indxH(indxH(:,2) < 91,1);

for n = 1:length(source.pos)
    sens_all_label{n} = ['vx' num2str(n)];
end

source.inside   = source.inside(indxH(indxH(:,2) < 91,1),:);
source.pos      = source.pos(indxH(indxH(:,2) < 91,1),:);

sens.label      = sens_all_label(whereWeLook);
sens.unit       = 'cm';
sens.elecpos    = source.pos;
sens.chanpos    = source.pos;

clear source;

cfg             = [];
cfg.elec        = sens;
lay             = ft_prepare_layout(cfg);

save('MNI_lay.mat','lay');

cfg                 =   [];
cfg.method          =   'triangulation' ;
cfg.layout          =   'MNI_lay.mat' ;
cfg.sens            =   sens ;
neighbours          =   ft_prepare_neighbours(cfg); clc ; 

clear new_neighbours

for n = 1 :length(sens_all_label)
    
    new_neighbours(n).label             = sens_all_label{n};
    
    ix                                  = find(whereWeLook==n);

    if ~isempty(ix)
        new_neighbours(n).neighblabel       = neighbours(ix).neighblabel;
    end
end

neighbours = new_neighbours ;

save('MNI_neighbours.mat','neighbours');