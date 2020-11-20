% reference : http://www.fieldtriptoolbox.org/tutorial/salzburg?s[]=virtual&s[]=sensors

cfg                 = []; 
cfg.interpmethod    = 'nearest'; 
cfg.parameter       = 'tissue'; 
stat_atlas          = ft_sourceinterpolate(cfg, atlas, source_diff);

% how to find using atlas

load ../data/template/template_grid_1cm.mat

x                   =   find(ismember(atlas.tissuelabel,'Heschl_L'));
indxHGL             =   find(stat_atlas.tissue==x);
template_grid       =   ft_convert_units(template_grid,'mm');% ensure no unit mismatch

% Next, we normalise the individual MRI

norm                =   ft_volumenormalise([],mri);
posHGL              =   template_grid.pos(indxHGL,:);                       % xyz positions in mni coordinates
posback             =   ft_warp_apply(norm.params,posHGL,'sn2individual');
btiposHGL           =   ft_warp_apply(pinv(norm.initial),posback);          % xyz positions in individual coordinates

% Now we create a source model for these particular locations only.

cfg                 =   [];
cfg.vol             =   hdm;
cfg.channel         =   dataica.label;  
cfg.grid.pos        =   [btiposHGL]./10;% units of m
cfg.grad            =   dataica.grad;
sourcemodel_virt    =   ft_prepare_leadfield(cfg);

% keep covariance in the output

cfg                     =   [];
cfg.channel             =   dataica.label;
cfg.covariance          =   'yes';
cfg.covariancewindow    =   [0 1]; 
avg                     =   ft_timelockanalysis(cfg,dataica);

cfg                     =   [];
cfg.method              =   'lcmv';
cfg.grid                =   sourcemodel_virt;
cfg.vol                 =   hdm;
cfg.lcmv.keepfilter     =   'yes';
cfg.lcmv.fixedori       =   'yes';
cfg.lcmv.lamda          =   '5%';
source                  =   ft_sourceanalysis(cfg, avg);

spatialfilter=cat(1,source.avg.filter{:});

virtsens=[];
for i=1:length(dataica.trial)

    virtsens.trial{i}=spatialfilter*dataica.trial{i};
 
end;

virtsens.time       =   dataica.time;
virtsens.fsample    =   dataica.fsample;

indx=[indxFML;indxHGL;indxHGR];

for i=1:length(virtsens.trial{1}(:,1))
    virtsens.label{i}=[num2str(i)];
end;

cfg.channel = virtsens.label(17:19); % left heschl by 3
virtsensHGL = ft_selectdata(cfg,virtsens);
virtsensHGL.label = {'HGL'};

virtsensparcel=virtsensHGL ; % ft_appenddata([],virtsensHGL);

cfg=[];
tlkvc=ft_timelockanalysis(cfg, virtsensparcel);
figure;

for i=1:length(tlkvc.label)
    cfg=[];
    cfg.channel = tlkvc.label{i};
    cfg.parameter = 'avg';
    cfg.xlim    = [-.1 1];
 
    subplot(2,2,i);ft_singleplotER(cfg,tlkvc);
end;