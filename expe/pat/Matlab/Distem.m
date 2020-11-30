% Liste distracteurs

nomficT='sons_list.txt'; %stim
fidT=fopen(nomficT,'rt');

% %Ouverture fichier stimulus.tem
% nomficSTA=['prog/PrepAtt_DIS_aud.tem'];
% fidSTA=fopen(nomficSTA,'wt');
% fprintf(fidSTA,'TEMPLATE "PrepAtt_DIS_aud_fin.tem" { \n');
% fprintf(fidSTA,'%18s; \n', 'son');

for i=1:Ndis
    
    sontemp=fgetl(fidT);
    son=strtok(sontemp,'.');
    DIS(i).name=son; 

end;

fclose(fidT);