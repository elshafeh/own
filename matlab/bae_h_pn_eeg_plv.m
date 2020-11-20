function [plv] = h_pn_eeg_plv(source,vox_slct)

numChannels     = size(source, 1);
plv             = zeros(length(vox_slct), numChannels);
Ntrials         = size(source,2);

ft_progress('init','text',    'Computing Phase Locking Value...');

for channelCount = 1:length(vox_slct)
        
    ft_progress(channelCount/length(vox_slct), 'Processing voxel %d from %d\n', channelCount, length(vox_slct));

    channelData = squeeze(source(vox_slct(channelCount),:));
    
    for compareChannelCount = 1:numChannels
        
        compareChannelData = squeeze(source(compareChannelCount, :));
                    
        plv(channelCount, compareChannelCount) = abs(sum(exp(1i*(channelData(:,:) - compareChannelData(:,:))), 2))/Ntrials;
        
    end
end