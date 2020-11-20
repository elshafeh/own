function PLF_out = mbon_PhaseLockingFactor_source(source_mom)

PLF_out         = nan(length(source_mom),1);

for nvox = 1:length(source_mom)
    if ~isempty(source_mom{nvox})
        data                    = source_mom{nvox};
        ang                     = angle(data);                               % Computes the angles, in radians
        PLF                     = squeeze(abs((sum(cos(ang) + 1i*sin(ang))))/size(data,2));% Computes the PLF
        PLF_out(nvox,1)         = PLF; clear PLF ang data
    end
end