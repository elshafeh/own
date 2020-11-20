cfg=[];
cfg.grid.warpmni='yes';
cfg.grid.template=sourcemodel;
cfg.grid.nonlinear='yes';
%cfg.grid.inside=sourcemodel.inside;
cfg.mri=mriF;
cfg.grid.unit='m';
grid=ft_prepare_sourcemodel(cfg);
%ft_plot_vol(hdm, 'edgecolor', 'none', 'facealpha', .8);
%ft_plot_mesh(grid.pos(grid.inside,:))
%%
cfg=[];
cfg.grid=grid;
cfg.headmodel=hdm;
cfg.normalize='yes';
lf=ft_prepare_leadfield(cfg, dataall);
%%
cfg=[];
cfg.preproc.lpfiler='yes';
cfg.preproc.lpfreq=30;
cfg.preproc.lpfilttype='firws';
cfg.covariance='yes';
cfg.covariancewindow=[-.3 .4];
data_avg=ft_timelockanalysis(cfg, dataall);
%%
cfg=[];
cfg.method='lcmv';
cfg.headmodel.unit='m';
cfg.grid=grid;
cfg.lcmv.keepfilter='yes';
cfg.lcmv.fixedori='yes';
cfg.lcmv.lambda='10%';
lcmvall=ft_sourceanalysis(cfg, data_avg);
%%
load(['/mnt/obob/staff/gdemarchi/DataAnalysis/testFT2py/sens_decode_' num2str(subjnum) '.mat'])
beamfilts=cat(1, lcmvall.avg.filter{:});
data_source=[];
data_source.label=cellstr(num2str([1:size(beamfilts,1)]'));
data_source.avg=beamfilts*sens_decode.avg;
data_source.time=sens_decode.time;
data_source.dimord='chan_time';