function dataMinvoked = h_removeEvoked(data)

dataMinvoked = data ;

avg = ft_timelockanalysis([],data);

for n = 1:length(dataMinvoked.trial)
    dataMinvoked.trial{n} = dataMinvoked.trial{n}-avg.avg;
end