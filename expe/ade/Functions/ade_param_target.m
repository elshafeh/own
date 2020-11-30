function P = ade_param_target(P,Info)

%%  Auditory targets parameters
% this loads the auditory pure tones for the staircase!
% it arranges them in (1) ascending order 'low then high' and (2)
% descending order 'high then low' with a pre-defined inter-tone gap

P.feedback                  = 0.1;
P.instructionwait           = 1; % this is delay when instructions are displayed for the main task
P.pausewait                 = 1; % this delay avoid a weird error where first stimulus in a block is presented twice

P.ProbeWait                 = 0.8;  % time period between target presentation and probe

if strcmp(Info.experiment,'expe')
    P.ITI_min               = 2;    % minimum inter-trial-interval
    P.ITI_max               = 2.5;  % maximum inter-trial-interval
else 
    P.ITI_min               = 1;    % minimum inter-trial-interval
    P.ITI_max               = 1.1;  % maximum inter-trial-interval
end

P.ITI_all               = (P.ITI_max-P.ITI_min).*rand(1000,1) + P.ITI_min; % create vector with random ITI between minimum and maximum 

for nblock = 1:(P.nBlock)
    for ntrial = 1:(P.nTrials(nblock))
        P.PresentationITI(nblock,ntrial)   = P.ITI_all(randi(length(P.ITI_all))); % for main experiment
    end
end

if isfield(Info,'SemiToneDifference')
    P.SemiToneDifference    = Info.SemiToneDifference;
else
    P.SemiToneDifference    = 3;
end

if strcmp(Info.modality,'vis')
    P.SemiToneDifference    = 3;
end

P.ToneDuration              = 0.05;

load ade_all_soundwaves_0p1step.mat
P.toneFs                    = 44100;
P.AllSoundWav               = AllSounds{P.SemiToneDifference};

if strcmp(Info.experiment,'expe')
    
    for TrialType = 1:2
        
        ix_tar              = [P.AllSoundWav{TrialType}{:,2}];
        
        cut_file            = find(round(ix_tar,1) == round(Info.Threshold,1));
        
        find_noise_freq     = find(round(ix_tar,1) == round(50,1));
        
        vctr                = [cut_file-1:cut_file+1 find_noise_freq]; 
        
        tmptmp{TrialType}   = P.AllSoundWav{TrialType}(vctr,:);
        
        clear vctr;
        
    end
    
    P.AllSoundWav                   = tmptmp;
    
end

    

InitializePsychSound;

PsychPortAudio('Close');

if IsLinux
    P.pahandle                  = PsychPortAudio('Open', [], [], 0, P.toneFs,2);%PsychPortAudio('Open',5, [], 2, P.toneFs, 2, 0); 
end
%%  Visual targets parameters

ifi                         = Screen('GetFlipInterval', P.window);

P.VistargOri                = [-45 45]; % 1 for left and 2 for right
P.VistargTimeSecs           = 0.05;       % 50ms grating target
P.VistargTimeFrames         = round(P.VistargTimeSecs / ifi);
P.Viswaitframes             = 1;
P.Viscontrast               = 1;       %100% contrast
P.VisgratingSizePix         = 50;      % Half size of the grating texture
P.Visf                      = 0.03;    % Grating cycles/pixel

P.Visp                      = ceil(1/P.Visf); % pixels/cycle, rounded up.
P.Visfr                     = P.Visf*2*pi;
P.visiblesize               = 2*P.VisgratingSizePix+1;
P.srcRect                   = [0 0 P.visiblesize P.visiblesize]; % Definition of the drawn source rectangle on the screen: