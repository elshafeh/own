function behav_in_recoded = PrepAtt22_funk_pos_recode(behav_in)

% adds cue/distractor/target delay
% recodes cues 1000+cue
% recodes distractor 2000 + delay
% recodes target 3000 + 1/2/3/4 [left low, right low, left high, right
% high];
% recodes button press : 9000 + [1: 251] or [2: 252];

fs               = 600;

delay_trigcue=ceil(0.018*fs); %18 ms de delai
delay_trigsound=ceil(0.012*fs); %12 ms de delai

behav_in_recoded = behav_in ;

for x=1:length(behav_in)     

    if (behav_in(x,3) >= 1 && behav_in(x,3) <= 34) || (behav_in(x,3) >= 101 && behav_in(x,3) <= 234)
        
        behav_in_recoded(x,3)   =   1000+behav_in_recoded(x,3);
        behav_in_recoded(x,4)   =   behav_in_recoded(x,4)+delay_trigcue;
    
    elseif behav_in(x,3) >= 51 && behav_in(x,3) <= 53   
        
        codB                    =   behav_in(x,3)-50;
        behav_in_recoded(x,3)   =   2000+codB;
        behav_in_recoded(x,4)   =   behav_in_recoded(x,4)+delay_trigsound;
        
    elseif behav_in(x,3) >= 61 && behav_in(x,3) <= 64  
        
        codB                    =   behav_in(x,3)-60;
        behav_in_recoded(x,3)   =   3000+codB;
        behav_in_recoded(x,4)   =   behav_in_recoded(x,4)+delay_trigsound;
        
    elseif behav_in(x,3) == 251   ||   behav_in(x,3) == 252 
        
        codB                    =   behav_in(x,3)-250;
        behav_in_recoded(x,3)   =   9000+codB;
        
    end
    
    clear codB
    
end