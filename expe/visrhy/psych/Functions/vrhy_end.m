function vrhy_end

global Info wPtr

sca;ShowCursor;
save(Info.logfilename,'Info','-v7.3');
if strcmp(Info.runtype, 'block') && strcmp(Info.debug, 'no') && strcmp(Info.eyetracker, 'yes')
    rd_eyeLink('eyestop', wPtr, {Info.eyefile, Info.eyefolder}); 
end
