function has_peak=detect_trials_with_peak(data)


%Average power spectrum over all channels

scalp_pow=squeeze(mean(data.powspctrm,2));

has_peak=false(size(scalp_pow,1),1);
for trl=1:size(scalp_pow,1)
    pks=findpeaks(squeeze(scalp_pow(trl,:)));
    if ~isempty(pks)
        has_peak(trl)=true;
    end
end