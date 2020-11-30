function vrhy_showWarning( msg )
%VRHY_SHOWWARNING Shows msg on the screen, then waits until KB response

global wPtr scr
vrhy_darkenBackground;
DrawFormattedText(wPtr, msg, 'center', 'center', scr.black);
Screen('Flip', wPtr);

WaitSecs(0.2);
KbWait(-1);

end

