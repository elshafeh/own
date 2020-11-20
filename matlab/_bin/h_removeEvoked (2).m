function min_evoked = h_removeEvoked(data_original)

min_evoked  = data_original ;
avg         = ft_timelockanalysis([],min_evoked);

for ni = 1:length(min_evoked.trial)
    min_evoked.trial{ni} = min_evoked.trial{ni} - avg.avg;
end

% figure;
% subplot(2,1,1)
% ft_singleplotER([],data_original); title('Before');
% subplot(2,1,2)
% ft_singleplotER([],min_evoked); title('after');