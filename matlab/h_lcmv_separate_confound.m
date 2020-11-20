function [source,source_name] = h_lcmv_separate_confound(cfg_in,data_in,hc_data)

cfg                         = [];
cfg.toilim                  = cfg_in.time_of_interest;
nw_data                     = ft_redefinetrial(cfg,data_in);
nw_hc_data                  = ft_redefinetrial(cfg,hc_data);

cfg                         = [];
cfg.covariance              = 'yes';
cfg.covariancewindow        = cfg_in.time_of_interest;
cfg.keeptrials              = 'yes';
avg                         = ft_timelockanalysis(cfg,nw_data);

cfg                         = [];
cfg.method                  = 'lcmv';
cfg.sourcemodel             = cfg_in.leadfield;
cfg.headmodel               = cfg_in.vol;
cfg.lcmv.keepfilter         = 'yes';
cfg.lcmv.fixedori           = 'yes';
cfg.lcmv.projectnoise       = 'yes';
cfg.lcmv.keepmom            = 'yes';
cfg.lcmv.projectmom         = 'yes';
cfg.lcmv.lambda             = '5%' ;
cfg.sourcemodel.filter    	= cfg_in.spatialfilter;
cfg.rawtrial                = 'yes';
cfg.keeptrials              = 'yes';
source                      =  ft_sourceanalysis(cfg, avg);

source.trial                = rmfield(source.trial,'label');
regr                        = h_remove_hc_confound(nw_hc_data,source);

source                      = nanmean(regr.pow,2);

tm_pnt{1}                   = cfg_in.time_of_interest(1);
tm_pnt{2}                   = cfg_in.time_of_interest(2);

for nt = 1:length(tm_pnt)
    if tm_pnt{nt} <= 0
        tm_ext{nt}          = ['m' num2str(abs(tm_pnt{nt})*1000)];
    else
        tm_ext{nt}          = ['p' num2str(abs(tm_pnt{nt})*1000)];
    end
end

source_name                 = [tm_ext{1} tm_ext{2} 'ms.regress'];
