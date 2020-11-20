function tf_masked(data,stat,f0, f1,t0,t1,chn_list,alphaOpacity,alpha_threshold,zlim)
% data  : the powspctrm data
% stat : stats (doesn't matter if there aren't the same dimensions
% f0 f1 : [begin end ] frequency of interest (in the powspctrm data)
% t0 t1 : [begin end ] time of interest (in the powspctrm data)
% chn_list : channel of interest e.g. chn_list={'MLF56';'MLF66';'MLF67'}
% alphaOpacity : the parameter for the intensity of opacity
% alpha_threshold : the threshold of alpha in your stats

stat.mask=stat.prob<alpha_threshold;

cfg             =   [];
cfg.channel     =   chn_list;
cfg.avgoverchan =   'yes';
data_tmp        =  ft_selectdata(cfg,data);

tmp_chn_list =  find(ismember(data.label,cfg.channel));
data_tmp.mask=zeros(size(data_tmp.powspctrm));

indx_f1 = find(round(data_tmp.freq)==round(stat.freq(1)));
indx_f2 = find(round(data_tmp.freq)==round(stat.freq(end)));
indx_t1 = find(round(data_tmp.time,3)==round(stat.time(1),3));
indx_t2 = find(round(data_tmp.time,3)==round(stat.time(end),3));

data_tmp.mask(1,indx_f1:indx_f2,indx_t1:indx_t2)=stat.mask(tmp_chn_list,:,:);  % average across channel>0s
data_tmp.mask=data_tmp.mask>0;
data_tmp.label={chn_list};

cfg               = [];
cfg.channel       = chn_list;
cfg.colorbar      = 'yes';
cfg.maskparameter = 'mask';                 % use significance to mask the power
cfg.maskalpha     = alphaOpacity;           % make non-significant regions 30% visible
cfg.zlim          = zlim;
ft_singleplotTFR(cfg,data_tmp);