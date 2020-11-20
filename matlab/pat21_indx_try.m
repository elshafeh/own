clear ; clc ;

dataOcc     = 2;
dataAud     = -3;
dataMean    = mean([dataOcc dataAud]);
corrIndex   = (dataAud-dataOcc)./(dataMean);
