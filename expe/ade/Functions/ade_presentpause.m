function ade_presentpause(P,Info)

if ~strcmp(Info.experiment,'expe')
    noisecontrast = P.StartingThreshold;
else
    noisecontrast = Info.Threshold;
end



WaitSecs(P.instructionwait);

if strcmp(Info.modality,'vis')
    
    list_type           = {'left','right'};
    
    for itype = 1:2
        
        InstructionPausetext           = ['This is the ' list_type{itype} ' tilted gabor'];
        ade_present_text(P,InstructionPausetext);
        WaitSecs(P.instructionwait);
        
        for iside = 1:2
            ade_trial_vis(P,iside,itype,noisecontrast,77);
            WaitSecs(P.instructionwait);
        end
        
    end
    
elseif strcmp(Info.modality,'aud')
    
    list_type                      = {'low','high'};
    
    for itype = 1:2
        
        InstructionPausetext           = ['This is the ' list_type{itype} ' pitch tone'];
        ade_present_text(P,InstructionPausetext);
        WaitSecs(P.instructionwait);
        
        ade_trial_aud(P,3,itype,noisecontrast,77); % P , side , type (left/right)
        WaitSecs(P.instructionwait*2);

        
    end
end

InstructionPausetext                = 'Follow The Instructions After Each Stimulus Presentation\n\nPress Any Key To Start Block';

P.bitsi.sendTrigger(251);
ade_present_text(P,InstructionPausetext)

if strcmp(Info.motor_in,'yes')
    if IsLinux
        [~,~] = get_bitsi_response(P);
    else
        KbWait(-1);
    end
end

my_fixationpoint(P,P.Black);
Screen('Flip', P.window);
WaitSecs(P.pausewait);              % this delay avoids