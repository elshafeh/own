function ade_endblock(P)

P.bitsi.sendTrigger(224); % end block trigger
P.bitsi.clearResponses();

ade_present_text(P,'Press Any Button To Conitnue')

if strcmp(P.motor_in,'yes')
    
    if IsLinux
        [~,~] = get_bitsi_response(P);
    else
        KbWait(-1);
    end
    
end

my_fixationpoint(P,P.Black);        % present_fixation_dot(P)
Screen('Flip', P.window);