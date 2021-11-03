function [vect_slct] = h_equalVectors(vect)
 
% put in cell array with vectors and it equalizes their lengths according
% to the smallest one!
 
lenTrials                       = [];
 
for ncond = 1:length(vect)
    lenTrials                   = [lenTrials length(vect{ncond})];
end
 
NbTrials                        = min(lenTrials);
 
for ncond = 1:length(vect)
    
    if length(vect{ncond}) == NbTrials
        
        vect_slct{ncond}      	= vect{ncond};
        
    else
        
        TrialVect              	= Shuffle(1:length(vect{ncond}));
        TrialVect              	= TrialVect(1:NbTrials);
        
        vect_slct{ncond}       	= vect{ncond}(TrialVect); clear TrialVect;
        
    end
    
end
