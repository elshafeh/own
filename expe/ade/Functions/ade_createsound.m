% This is the script that is used to fabricate pure tones 

fs          = 44100;  % Sampling Rate
semitone    = 0; % semitone array
multiple    = 1;

for w = 1:length(semitone)
    for xx=1:length(multiple)
        
        % parameters
        duree_burst     = 0.05;  % in second
        A               = 2000;
        A_clip          = 12000;
        typenv          = 2;                % 1 = sinusoide; 2 = creneau
        trf             = 0.005;            % rise and fall in seconds
        typeburst       = 'h';              % h=harmonic sound; b=noise
        band            = 20;               % largeur du bruit en dt dans cas b (useless)
        Nharm           = 1;                % nb of harmonics
        typefreq        = 1;                % 1=en dt(semitones), 2=en Hz
        F0              = 512;              % dans cas 1 uniquement (low TAR)
        freq1           = semitone(w)*multiple(xx); % semitone*3;  % no semitones
        sizeson         ='b';        % b=binaural

        %parametres
        nd              =round(fs*duree_burst);
        nrf1            =round(nd/2);
        nrf2            =round(fs*trf);
        
        %enveloppe
        enveloppe=ones(1,nd);
        if typenv==1          %sinusoide
            nrf=nrf1;
            for i=1:nrf
                enveloppe(i)=0.5*(1-cos(pi*i/nrf));
                enveloppe(nd-i+1)=0.5*(1-cos(pi*(i-1)/nrf));
            end;
        end
        
        if typenv==2          % creneau
            nrf=nrf2;
            for i=1:nrf
                enveloppe(i)=(i-1)/nrf;
                enveloppe(nd-i+1)=(i-1)/nrf;
            end;
        end
        temps=[0:1/fs:(nd-1)/fs];
        
        %frequency
        if typefreq==1
            f1=ton2Hz(F0,freq1);
            f2=ton2Hz(F0,freq1+band);
        else
            f1=freq1;
            f2=freq2;
        end
        
        %burst
        smono=zeros(1,nd);
        
        if typeburst=='h'        % harmonic sound
            for k=1:Nharm
                smono(1,1:nd)=smono(1,1:nd)+(1/Nharm)*sin(2*pi*f1*k*temps);
            end
            smono(1,:)=smono(1,:)*A.*enveloppe;
        else                     %noise
            smono(1,:)=Noisegen(f1,f2,fs,duree_burst);
            smono(1,:)=smono(1,:)*A.*enveloppe;
            while max(max(smono))>A_clip
                fprintf('max s = %f \n',max(max(smono)));
                smono(1,:)=Noisegen(f1,f2,fs,duree_burst);
                smono(1,:)=smono(1,:)*A.*enveloppe;
            end
        end
        
        % fabrication of .wav file
        
        sbino=zeros(2,nd);
        if sizeson=='g'             %sound mono left
            sbino(1,:)=2*smono;
        elseif sizeson=='d'         %sound mono right
            sbino(2,:)=2*smono;
        elseif sizeson=='b'         %sound mono binaural
            sbino(1,:)=smono;
            sbino(2,:)=smono;
        end
        
        max(max(max(abs(sbino))));
        sbino=0.9*sbino/max(max(max(abs(sbino))));

        nomfic1     =['..' filesep 'Stimuli' filesep num2str(round(duree_burst*1000)) 'ms_target_sound_' num2str(round(f1)) '_' num2str(semitone(w)) '.wav'];
        audiowrite(nomfic1,sbino', fs);
        
    end
end