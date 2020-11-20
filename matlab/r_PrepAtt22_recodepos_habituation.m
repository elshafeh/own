function r_PrepAtt22_recodepos_habituation

% MATLAB_2015A!!!!!!!!!!!!!!!!
%%%NE MARCHE PAS POUR YC9 qui n'a pas 640 trials

clear

% recode le fichier pos pour étudier l'habituation des PE
% 1***** -> cue CnD de début de bloc // 2***** -> cue CnD de fin de bloc
% *n**** -> n = numéro de bloc - 1

[~,subject,~]  = xlsread('appariement_matlab_mig.xls','B:B');
% suj_group{1}        = subject(:,1);
% suj_group{2}        = subject(:,2);

list_suj = subject(:);

for sb = 1:length(list_suj)
    
    %%
    suj     = list_suj{sb}
    
    if strcmp(suj,'yc9')==0
        
        posFileNoEpoch = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.pos'];
        posNoEpoch     = csvread(posFileNoEpoch);
        
        cue_num        = find(posNoEpoch(:,2)<1999); %all cues
        numcuebyblocdeb = zeros(1,10); %on va compter le nombre de trials non rejetés dans les 32 premiers trials du bloc
        numcuebyblocfin = zeros(1,10); %on va compter le nombre de trials non rejetés dans les 32 derniers trials du bloc
        
        for b = 1:10;
            
            norej_tr = 0;
            
            for cue = ((b-1)*64+1):((b-1)*64+32)
                if posNoEpoch(cue_num(cue),3) == 0
                    norej_tr = norej_tr +1;
                end
            end
            numcuebyblocdeb(b) = norej_tr;
            
            norej_tr = 0;
            
            for cue = ((b-1)*64+33):((b-1)*64+64)
                if posNoEpoch(cue_num(cue),3) == 0
                    norej_tr = norej_tr +1;
                end
            end
            numcuebyblocfin(b) = norej_tr;
            
        end
        
        numcuebybloc = numcuebyblocdeb + numcuebyblocfin;
        
        posFile = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos'];
        pos     = csvread(posFile);
        
        %%
        
        % on va enlever les doubles réponses car ça me fout en l'air mon programme
        
        bp               = find(pos(:,2)>9000); %on cherche les boutons poussoirs
        a                = 0;
        
        for i = 1:length(bp)-1
            
            if pos(bp(i)+1-a,2) > 9000
                
                pos = [ pos(1:(bp(i)-a),:); pos((bp(i)+2-a):end,:)]; %j'enlève la seconde réponse
                a = a + 1; % "a" compte le nombre de décalage déjà réalisés car l'indexation des lignes change à chaque fois que j'en enlève une
                
            end
            
        end
        
        %le programme qui insère les fdis oublie d'en mettre si le trial est
        %rejeté. Je rajoute une ligne bateau si un trial rejeté a moins de 5 evenements (255, cue, dis/fdis, target, bp)
        
        tr23          = find(pos(:,3)==23);
        a             = 0;
        
        for i = 1:length(tr23)
            
            if (pos(tr23(i)+a,2)==255) && ((tr23(i)+a+3)==length(pos)) %cas exceptionnel = si trial à 4 événements en fin du 10e bloc
                
                pos = [ pos(1:(tr23(i)+1+a),:); 0, 6000, 23; pos((tr23(i)+2+a):end,:)];
                
            elseif (pos(tr23(i)+a,2)==255) && (pos(tr23(i)+a+4,2)==255) %oubli de mettre un fdis
                
                pos = [ pos(1:(tr23(i)+1+a),:); 0, 6000, 23; pos((tr23(i)+2+a):end,:)]; %je rajoute une ligne qui ne sert à rien
                a = a+1; % "a" compte le nombre de décalage déjà réalisés car l'indexation des lignes change à chaque fois que j'en rajoute une
                
            end
            
        end
        
        
        %%
        
        
        for b = 1:10 %nombre de blocs
            
            if b ==1
                deb    = 1:(numcuebyblocdeb(b)*5); % les trials de la première moitié de chaque bloc
                fin    = (numcuebyblocdeb(b)*5+1) : (sum(numcuebybloc(1:b))*5);    % les trials de la dernière moitié de chaque bloc
            else
                deb    = (sum(numcuebybloc(1:b-1))*5+1) : (sum(numcuebybloc(1:b-1)*5)+numcuebyblocdeb(b)*5); % les trials de la première moitié de chaque bloc
                fin    = (sum(numcuebybloc(1:b-1)*5)+numcuebyblocdeb(b)*5+1) : (sum(numcuebybloc(1:b))*5);    % les trials de la dernière moitié de chaque bloc
            end
            
            trial_deb = deb(1:5:end);
            trial_fin = fin(1:5:end);
            
            for tr = 1:length(trial_deb);
                for event = (trial_deb(tr)+1):(trial_deb(tr)+4)
                    pos(event,2) = pos(event,2) + 100000 + (b-1)*10000; % 1***** -> trial de début de bloc // 2***** -> trial de fin de bloc
                end
            end
            
            for tr = 1:length(trial_fin);
                for event = (trial_fin(tr)+1):(trial_fin(tr)+4)
                    pos(event,2) = pos(event,2) + 200000 + (b-1)*10000; % 1***** -> trial de début de bloc // 2***** -> trial de fin de bloc
                end
            end
            
        end
        
        posFileOUT = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.habituation.pos'];
        dlmwrite(posFileOUT,pos,'delimiter','\t','precision','%d')
        
    end
    
end
