function [ntot,nmiss,nfa,ninc,ntte,njump,premain] = PrepAtt22_funk_behav_report(posIN)

evalIN          = posIN(floor(posIN(:,2)/1000) ==1,3);

ntot            = length(evalIN);
nmiss           = ntot-length(find(evalIN==5));
nfa             = nmiss-length(find(evalIN==6));
ninc            = nfa-length(find(evalIN==7));
ntte            = ninc-length(find(evalIN==8));
njump           = ntte-length(find(evalIN==9));
premain         = (njump/ntot)*100;
