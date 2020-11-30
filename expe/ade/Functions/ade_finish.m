function Info = ade_finish(Info,P)

Screen('CloseAll');
ShowCursor;

if strcmp(Info.experiment,'stair')
    
    all_threshold                           = [];
    
    for nblock = 1:length(Info.block)
        
        tmp_diff                            = [Info.block(nblock).trial.difference];
        tmp_diff                            = mean(tmp_diff(end-5:end));
        
        tmp_corr                            = [Info.block(nblock).trial.response];
        tmp_corr                            = (length(find(tmp_corr==1))) * 100;
        
        all_threshold(nblock,1)             = tmp_diff;
        all_correct(nblock,1)               = tmp_corr; clear tmp_*
        
    end
    
    target_block                            = length(Info.block);
    
    Info.DiscriminationThreshold            = all_threshold(target_block);
    Info.DiscriminationHistory              = [all_threshold all_correct];
    
end

save(Info.logfilename, 'Info');
save(Info.parameterfilename, 'P');

if IsLinux
    try
        PsychPortAudio('Close');
    catch
        x   = 0;
    end
end