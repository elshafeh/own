% Faire un son


rand('state',sum(100*clock));

fs=44100;  % Sampling Rate

semitone=3; % !!! Parameter to change !!!

% param�tres
duree_burst=0.1;  % en seconde
A=2000;
A_clip=12000;
typenv=2;           % 1=sinusoide; 2=cr�neau
trf=0.005;          % temps de mont�e en s du cr�neau dans cas 2 (rise and fall in seconds)
typeburst='h';        % h=son harmonique; b=bruit
Nharm=1;              % nb d'harmoniques dans cas h
band=20;               %largeur du bruit en dt dans cas b (useless)
typefreq=1;         % 1=en dt(semitones), 2=en Hz
F0=512;            % dans cas 1 uniquement (low TAR)
freq1= semitone ; % semitone*3;  % no semitones
freq2=4000;         % useless
sizeson='b';        % b=binaural

%Fabrication des sons

%param�tres
nd=round(fs*duree_burst);
nrf1=round(nd/2);
nrf2=round(fs*trf);

%enveloppe
enveloppe=ones(1,nd);
if typenv==1          %sinusoide
    nrf=nrf1;
    for i=1:nrf
        enveloppe(i)=0.5*(1-cos(pi*i/nrf));
        enveloppe(nd-i+1)=0.5*(1-cos(pi*(i-1)/nrf));
    end;
end;
if typenv==2          %cr�neau
    nrf=nrf2;
    for i=1:nrf
        enveloppe(i)=(i-1)/nrf;
        enveloppe(nd-i+1)=(i-1)/nrf;
    end;
end;
temps=[0:1/fs:(nd-1)/fs];

%frequence
if typefreq==1
    f1=ton2Hz(F0,freq1);
    f2=ton2Hz(F0,freq1+band);
else
    f1=freq1;
    f2=freq2;
end;

%burst
smono=zeros(1,nd);

if typeburst=='h'        %son harmonique
    for k=1:Nharm
        smono(1,1:nd)=smono(1,1:nd)+(1/Nharm)*sin(2*pi*f1*k*temps);
    end;
    smono(1,:)=smono(1,:)*A.*enveloppe;
else                     %bruit
    smono(1,:)=Noisegen(f1,f2,fs,duree_burst);
    smono(1,:)=smono(1,:)*A.*enveloppe;
    while max(max(smono))>A_clip
        fprintf('max s = %f \n',max(max(smono)));
        smono(1,:)=Noisegen(f1,f2,fs,duree_burst);
        smono(1,:)=smono(1,:)*A.*enveloppe;
        
    end
    
end

% fabrication d'un son.wav

sbino=zeros(2,nd);

if sizeson=='g'             %son mono gauche
    sbino(1,:)=2*smono;
elseif sizeson=='d'         %son mono droite
    sbino(2,:)=2*smono;
elseif sizeson=='b'         %son mono bino
    sbino(1,:)=smono;
    sbino(2,:)=smono;
end;

max(max(max(abs(sbino))));
sbino=0.9*sbino/max(max(max(abs(sbino))));

nomfic1=['tar_1_high_' num2str(semitone) '_' num2str(f1) '.wav'];

audiowrite(nomfic1,sbino', fs);
