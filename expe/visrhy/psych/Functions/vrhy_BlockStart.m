function t_start = vrhy_BlockStart()

global wPtr scr stim Info

vrhy_darkenBackground;
DrawFormattedText(wPtr, scr.Pausetext, 'center', 'center', scr.black);
Screen('Flip', wPtr);

WaitSecs(0.2);
t_start  = vrhy_response_wait;

