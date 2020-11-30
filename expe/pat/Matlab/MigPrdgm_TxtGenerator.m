%   Randomization _ Discrimination Task
%   Fixed Cue-Target 

clear;clc;

rand('state',sum(100*clock)); %#ok<*RAND>

Nseq=10;       %trial     
Ndis=160; % 0.25 *64*10

delay_tot=1000;

duree_DIS=300;
delay2_min_list=[350 50];

Ndelay=length(delay2_min_list);

rand_delay2 = 295; % 195

side_list=['B' 'L' 'R']; % B i snuetral 
side_list2=['A' 'B' 'C' 'D']; % left low - right low - left high - right high
Nside=length(side_list); 
ISIrandini=200;

MigPrdmTable; % Trials Table

tot_list=prdgmTab;

Ntrial=sum(tot_list(:,3));
Ncat=size(tot_list,1);
NDIScat=max(tot_list(:,4));

Distem;   % Distractor List 
Disrand;  % Distractor Randomization 

% Open file dis.txt

nomficDIS='Dislist_Disc_Fix.txt'; % Change in Presentation if needed
fidDIS=fopen(nomficDIS,'wt');
fprintf(fidDIS,'%5s%8s%8s%8s%18s; \n', 'num', 'cue', 'delay1', 'DIScat','dis');

TTdis=zeros(NDIScat,1);
TT=zeros(Ntrial,Nseq);

for n=1:Nseq 

    % Randomization
    Ntot=length(tot_list);
    s_tot=seqrand6(Ntrial,Ntot,tot_list(:,3),1);

    % Open Trial File.tem
    nomficTR=['Disc_Fix_' num2str(n) '.txt'];
    fidTR=fopen(nomficTR,'wt');
    fprintf(fidTR,'%8s%10s%10s%10s%10s%8s%10s%20s%10s%15s%10s%8s%10s; \n', '"num"', '"trialt"', '"cue"', '"codCUE"', '"delay1"', '"dis"', '"codDIS"', '"DIS"', '"delay2"', '"TAR"', '"codTAR"', '"bp"', '"ISIrand"');

    d=0;
   
    for t=1:Ntrial

       cod=tot_list(s_tot(t),1);
       cod_CUEside=floor(cod/100);
       cod_DIS=floor((cod-100*cod_CUEside)/10);
       DIScat=tot_list(s_tot(t),4);
       cod_TARside=mod(cod,10);
       
        % Presentation Codes
        % Delay, Cue and Distractor

        cod_delay=tot_list(s_tot(t),2);
        codCUE=cod;
        codDIS=50+cod_DIS;
        codTAR=60+cod_TARside;

        %Delay
        
        delay2min=delay2_min_list(cod_delay);
        delay2=round(delay2min+rand*rand_delay2);
        Tdelay(t,2)=delay2;
        delay1=round(delay_tot-duree_DIS-delay2);
        Tdelay(t,1)=delay1;
        Tdelay(t,3)=delay1+delay2+duree_DIS;
        
        % Randomization ISI
        ISIrand=round(ISIrandini*rand);

        % Trial type
        if cod_CUEside==0;
            trialt=0; %trial neutre
        else
            if cod_CUEside==cod_TARside || cod_CUEside+2==cod_TARside
                trialt=1; %trial valid
            else
                trialt=-1; %trial invalide
            end;
        end;

        % Stim name
        % Cue
        CUEside=side_list(cod_CUEside+1);
        cue_name=['"' CUEside 'arrow"'];

        % Target
        TARside=side_list2(cod_TARside);
        tar=['"S_tarson_' TARside '"']; 
        
        % Distractor
        if cod_DIS>=1
            TTdis(DIScat,1)=TTdis(DIScat,1)+1;
            repet=TTdis(DIScat,1);
            dis=['"' DIS(Tdis(DIScat,repet)).name '"'];
        else
            dis='"nul"';
        end; 
        
        % Button Press
        if TARside=='A' || TARside=='B'
            bp=1;
        else
            bp=2;
        end

        % Ecriture des fichiers trial.tem
        fprintf(fidTR,'%8d', t);
        fprintf(fidTR,'%10d', trialt);
        fprintf(fidTR,'%10s', cue_name);
        fprintf(fidTR,'%10d', codCUE);
        fprintf(fidTR,'%10d', delay1);
        fprintf(fidTR,'%8d', cod_DIS);
        fprintf(fidTR,'%10d', codDIS);
        fprintf(fidTR,'%20s', dis);
        fprintf(fidTR,'%8d', delay2);
        fprintf(fidTR,'%15s', tar);
        fprintf(fidTR,'%10d', codTAR);
        fprintf(fidTR,'%8d', bp);
        fprintf(fidTR,'%10d;\n', ISIrand);

        fprintf(fidDIS,'%5d%8s%8d%8d%18s; \n', t, cue_name, delay1, DIScat, dis);
    
    end;

    fprintf(fidTR,'};\n');
    fclose(fidTR);   
    
    clc 
end; 

fclose(fidDIS);