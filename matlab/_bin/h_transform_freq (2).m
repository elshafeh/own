function new_freq = h_transform_freq(freq,chan_index,chan_list)

pow                         = [];

for nroi = 1:length(chan_list) 
    
    indx                    = chan_index{nroi};
    pow                     = [pow;mean(freq.powspctrm(indx,:,:),1)];

    %     tmp{nroi}               = freq;
    %     tmp{nroi}.label         = {chan_list{nroi}};
    %     tmp{nroi}.powspctrm     = pow; clear pow;
    
end

new_freq                    = freq;
new_freq.powspctrm          = pow; clear pow;
new_freq.label              = chan_list;

% cfg                     = [];
% cfg.parameter           = 'powspctrm';
% cfg.appenddim           = 'chan';
% new_freq                = ft_appendfreq(cfg,tmp{:});

% if isfield(new_freq,'powspctrm')
% else
%     ix_pow              = [];
%     for nroi = 1:length(chan_list)
%         ix_pow          = cat(1,ix_pow,tmp{nroi}.powspctrm);
%     end
%
%     new_freq.powspctrm  = ix_pow;
%
% end
%
% if isfield(freq,'trialinfo')
%     new_freq.trialinfo  = freq.trialinfo;
% end