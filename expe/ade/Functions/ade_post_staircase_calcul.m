function [correctInaRow,currentThresh] = ade_post_staircase_calcul(P,correctInaRow,currentThresh,TrialCount,correct_report)

if correct_report == 1
    
    correctInaRow                       = correctInaRow + 1;
    
    if correctInaRow == P.numdown
        currentThresh(TrialCount+1)     = currentThresh(TrialCount) - P.stepsize;
        correctInaRow                   = 0;
    else
        currentThresh(TrialCount+1)     = currentThresh(TrialCount);
    end
    
else
    
    correctInaRow                       = 0;
    currentThresh(TrialCount+1)         = currentThresh(TrialCount) + P.stepsize;
    
end

