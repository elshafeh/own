function freq_prepare = h_prepare_pac_tensor(fname,name_chan,name_cue,name_method,normalize)

fprintf('Loading %30s\n',fname);
load(fname)

freq_prepare.freq                                   = py_pac.vec_amp;
freq_prepare.time                                   = py_pac.vec_pha;

m_pac                                               = squeeze(py_pac.xpac);
m_pac                                               = squeeze(mean(m_pac,3));

if strcmp(normalize,'yes')
    m_pac                                           = 0.5 .* (log((1+m_pac)./(1-m_pac)));
end

freq_prepare.powspctrm(1,:,:)                       = m_pac;

freq_prepare.label                                  = {[name_chan '_' name_cue '_' name_method]};
freq_prepare.dimord                                 = 'chan_freq_time';

clear seymour_pac

cfg                                                 = [];
cfg.latency                                         = [5 15];
cfg.frequency                                       = [50 110];
freq_prepare                                        = ft_selectdata(cfg,freq_prepare);