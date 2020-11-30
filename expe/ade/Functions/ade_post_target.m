function [Info,RT,final_report,correct_report] = ade_post_target(P,Info,TrialInst,nb,nt)

[trial_instruction,list_stimulus,list_condfidence] = ade_draw_instruction(P,Info,TrialInst); % draw boxes

if strcmp(Info.motor_in,'yes')

    if IsLinux
        [RT,final_report]     = get_bitsi_response(P);
    else
        [RT,final_report]     = get_kb_response(P);
    end
    
else
    
    WaitSecs(0.1);
    RT              = 10;
    final_report    = 1;
    
end

Info.block(nb).trial(nt).mapping            = list_stimulus(final_report);
Info.block(nb).trial(nt).confidence         = list_condfidence(final_report);
Info.block(nb).trial(nt).instruction        = trial_instruction;

if Info.block(nb).trial(nt).mapping == Info.block(nb).trial(nt).type
    
    Info.block(nb).trial(nt).correct        = 1;
    
    if strcmp(Info.runtype,'train')
        my_fixationpoint(P,P.Green);
    else
        my_fixationpoint(P,P.Black);
    end
    
else
    
    Info.block(nb).trial(nt).correct        = -1;
    
    if strcmp(Info.runtype,'train')
        my_fixationpoint(P,P.Red);
    else
        my_fixationpoint(P,P.Black);
    end
    
end

correct_report             = Info.block(nb).trial(nt).correct;
Screen('Flip', P.window);
P.bitsi.clearResponses ;