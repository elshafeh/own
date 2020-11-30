function [  ] = luca_SendTrigger( is, dio, trigger_value )
% set dio to the trigger value, pause, and set back to zero.

if is.recording_flag
    putvalue(dio,[dec2binvec(trigger_value,8) 1]); % This sends the strobe bit and the 8-bit code to the DAQ
    pause(.005); % This waits for 5 ms to allow matlab enough time to send the codes and move on
    putvalue(dio,[dec2binvec(0,8) 0]); % This resets the digital outputs to 0
else
    disp(['trigger ' num2str(trigger_value) ' at ' datestr(rem(now,1), 'HH:MM:SS:FFF')])
end


end

