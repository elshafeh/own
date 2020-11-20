function freq_prepare = h_prepare_pac_seymour(fname,name_chan,name_cue,name_method,normalize)

fprintf('Loading %30s\n',fname);
load(fname)

m_pac                                               = seymour_pac.mpac;

if strcmp(normalize,'yes')
    m_pac                                               = 0.5 .* (log((1+m_pac)./(1-m_pac)));
end

freq_prepare.powspctrm(1,:,:)                       = m_pac;
freq_prepare.freq                                   = seymour_pac.amp_freq_vec;
freq_prepare.time                                   = seymour_pac.pha_freq_vec;

freq_prepare.label                                  = {[name_chan '_' name_cue '_' name_method]};
freq_prepare.dimord                                 = 'chan_freq_time';

cfg                                                 = [];
cfg.latency                                         = [5 15];
cfg.frequency                                       = [50 110];
freq_prepare                                        = ft_selectdata(cfg,freq_prepare);