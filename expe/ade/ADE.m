% -- Initiate Session Information & Create Parameters file
% Hesham Wednesday 13 Mar 2019 ; eyetracking modifications - Additya - 5 Aug 2019

% clear everyhting except eyetracker variables
clearvars -except useEyetrack el cal  ; clc;
addpath(['Functions' filesep]);

tic;
Info                    = ade_start;
P                       = ade_parameters(Info);

%% EYE tracker specifications

if strcmp(Info.experiment,'expe') && strcmp(Info.runtype,'run') && Info.runnumber == 1
    
    global el useEyetrack
    % Start Eyetracking
    [el,exitFlag]                               = rd_eyeLink('eyestart', P.window, Info.eyefile);
    useEyetrack                                 = 0;
    if exitFlag, return; end

    % Calibrate eye tracker
    [cal,exitFlag]                              = rd_eyeLink('calibrate', P.window, el);
    if exitFlag, return; end

    % Start recording
    rd_eyeLink('startrecording',P.window, el);
    useEyetrack                                 = 1;

end

%% TRIAL presentation

currentThresh           = NaN((min(P.nTrials)*(P.nBlock)-1),1); % staircase is collapsed for left and right
TrialCount              = 0;        % staircase is collapsed for left and right

for n_block = 1:P.nBlock
    
    if strcmp(Info.experiment,'stair') && n_block > 1
        y = 0;
    else
        ade_presentpause(P,Info);
    end
    
    correctInaRow   = 0; % staircase is collapsed for left and right
    
    P.bitsi.clearResponses();
    P.bitsi.sendTrigger(221); % start block trigger
    
    for n_trial = 1:P.nTrials(n_block)
        
        P.bitsi.clearResponses();
        P.bitsi.sendTrigger(222); % start trial trigger
        WaitSecs(P.PresentationITI(n_block,n_trial));
        
        TrialSide                                               = P.PresentationSide(n_block,n_trial);
        TrialType                                               = P.PresentationType(n_block,n_trial);
        TrialInst                                               = P.PresentationInst(n_block,n_trial);
        TrialNois                                               = P.PresentationNois(n_block,n_trial);
        
        TargetCode                                              = P.TargCode(n_block,n_trial);
        
        Info.block(n_block).trial(n_trial).number               = n_trial;
        Info.block(n_block).trial(n_trial).type                 = TrialType;
        Info.block(n_block).trial(n_trial).side                 = TrialSide ;
        Info.block(n_block).trial(n_trial).inst                 = TrialInst;
        Info.block(n_block).trial(n_trial).nois                 = TrialNois;
        
        if strcmp(Info.experiment,'stair')
            
            TrialCount                                          = TrialCount+1;
            [currentThresh]                                     = ade_pre_staircase_calcul(P,Info,currentThresh,TrialCount);
            noisecontrast                                       = currentThresh(TrialCount);
            
        else
            
            if TrialNois == 0
                noisecontrast                                   = P.StartingThreshold;
            else
                noisecontrast                                   = Info.Threshold;
            end
            
        end
        
        Info.block(n_block).trial(n_trial).difference           = noisecontrast;
        
        if strcmp(Info.modality,'vis')
            target_presented                                    = ade_trial_vis(P,TrialSide,TrialType,noisecontrast,TargetCode);
        elseif strcmp(Info.modality,'aud')
            target_presented                                    = ade_trial_aud(P, TrialSide,TrialType,noisecontrast,TargetCode);
        end
        
        clear noisecontrast
        
        [Info,RT,final_report,correct_report]                   = ade_post_target(P,Info,TrialInst,n_block,n_trial);
        
        if strcmp(Info.experiment,'stair')
            [correctInaRow,currentThresh]                       = ade_post_staircase_calcul(P,correctInaRow,currentThresh,TrialCount,correct_report);
        end
        
        Info.block(n_block).trial(n_trial).RT                   = RT; clear RT;
        Info.block(n_block).trial(n_trial).response             = final_report; clear Report final_report;
        Info.block(n_block).trial(n_trial).target               = target_presented; clear target_presented;
        
        if strcmp(Info.runtype,'train')
            WaitSecs(0.1);
        end
        
        % -- end trial
        my_fixationpoint(P,P.Black);
        Screen('Flip', P.window);
        P.bitsi.sendTrigger(223); % end trial trigger
        P.bitsi.clearResponses();
        
    end
    
    Info.threshold_report{n_block}      = currentThresh;
    Info.count_report{n_block}          = TrialCount;
    
    if strcmp(Info.experiment,'stair')
        ade_present_text(P,'End of Block\n\nGood Job!')
        WaitSecs(P.pausewait);
    else
        Info.block(n_block).sleep       = ade_sleepy_questionnaire(P,Info);
        WaitSecs(P.pausewait);
    end
    
    ade_endblock(P)
    
end

Info.tTotal             = toc;
Info.tFinish            = {datestr(clock)};
Info                    = ade_finish(Info,P);

if strcmp(Info.experiment,'stair')
    ade_plot_staircase(Info)
else
    ade_print_behavior(Info)
end

%% END experiment to save data eye tracking data
if Info.runnumber == 9
    if useEyetrack, rd_eyeLink('eyestop', P.window, {Info.eyefile, pwd}); end
end 