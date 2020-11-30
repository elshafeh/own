function P = ade_param_structure(P,Info)
% Task and block structure

if strcmp(Info.experiment,'stair')
    
    if strcmp(Info.runtype,'train')
        P.nBlock    = 1;
        P.nTrials   = 10;
    elseif strcmp(Info.runtype,'run')
        P.nBlock    = 4;
        P.nTrials   = [40 40 40 40];
    elseif strcmp(Info.runtype,'extra')
        P.nBlock    = 1;
        P.nTrials   = 40;
    end
    
elseif strcmp(Info.experiment,'expe')
    
    if strcmp(Info.runtype,'train')
        P.nBlock    = 1;
        P.nTrials   = 24;
    elseif strcmp(Info.runtype,'run')
        P.nBlock    = 1;
        P.nTrials   = 96;
    end
    
end

P.numdown                               = 2;          % number of corrent items in a row to go down (2 step up so num=1)

if strcmp(Info.modality,'aud')
    
    P.stepsize                          = 2.5;          % step size of SNR decrease
    
    if strcmp(Info.experiment,'expe') || ischar(Info.Threshold)
        P.StartingThreshold             = 50;         % StartingThreshold
    else
        P.StartingThreshold             = round(Info.Threshold,1);
    end
    
elseif strcmp(Info.modality,'vis')
    
    P.stepsize                          = -0.2;        % step size of SNR decrease
    
    if strcmp(Info.experiment,'expe') || ischar(Info.Threshold)
        P.StartingThreshold             = 0.2;           % StartingThreshold
    else
        P.StartingThreshold             = Info.Threshold;
    end
end

P.experiment                            = Info.experiment;
P.runtype                               = Info.runtype;

rand_vector                             = ade_CreateRandTrials(P);

P.PresentationSide                      = rand_vector.side;
P.PresentationType                      = rand_vector.type;
P.PresentationInst                      = rand_vector.inst;
P.PresentationNois                      = rand_vector.nois;

P                                       = ade_codfiy_stim(P,Info);