function spm_shortcut_spatial_projector_FL(DFile, File_Save)

% extracted from spm_eeg_invert
% for LM single trial inversion
% code un peu crasse , rapido ...
Nr=16;

D{1}=spm_eeg_load(DFile);
modalities={'MEG' 'EEG'};
Nmod  = numel(modalities);                  % number of modalities
Nmax  = Nr;                                 % max number of temporal modes

Nl=1;

for i=1:Nl
    fprintf('Checking leadfields for subject %i\n',i)
    [L D{i}] = spm_eeg_lgainmat(D{i});
    for m = 1:Nmod
        
        % Check gain or lead-field matrices
        %------------------------------------------------------------------
        Ic{i,m}  = setdiff(meegchannels(D{i}, modalities{m}), badchannels(D{i}));
        Nd(i)    = size(L,2);
        Nc(i,m)  = length(Ic{i,m});
        
        if isempty(Ic{i,m})
            errordlg(['Modality ' modalities{m} 'is missing from file ' D{i}.fname]);
            return
        end
        
        if any(diff(Nd))
            errordlg('Please ensure subjects have the same number of dipoles')
            return
        end
        
        % Check for null space over sensors (SX) and remove it
        %------------------------------------------------------------------
        try
            SX     = D{i}.sconfounds{m};
            R{i,m} = speye(Nc(i,m),Nc(i,m)) - SX*spm_pinv(SX);
        catch
            R{i,m} = speye(Nc(i,m),Nc(i,m));
        end
    end
end

%==========================================================================
% Spatial projectors (adjusting for different Lead-fields)
%==========================================================================

fprintf('Optimising and aligning spatial modes ...\n')

% Use recursive (regularised) least squares to find average lead-field
%--------------------------------------------------------------------------
Is    = 1:Nd;
UL    = cell(Nmod,1);
for m = 1:Nmod
    
    % Initialise average lead-field with L{1}
    %----------------------------------------------------------------------
    UL{m} = R{1,m}*spm_eeg_lgainmat(D{1},Is,D{1}.chanlabels(Ic{1,m}));
    AA    = 1;
    
    % pre-compute regularised inverses (for speed)
    %----------------------------------------------------------------------
    for i = 1:Nl
        L      = R{i,m}*spm_eeg_lgainmat(D{i},Is,D{i}.chanlabels(Ic{i,m}));
        iL{i}  = spm_inv(L*L' + speye(Nc(i, m))*norm(L,'inf')*exp(-16));
        disp([' suj ' num2str(i) ' :  [  ' num2str(min(min(L))) '   '  num2str(max(max(L))) '  '  num2str(norm(L,'inf'))  ]);
        %         figure;
        %         imagesc(iL{i}); title([ ' iL, sujet = ' num2str(i)  ]);
        %         colorbar;
    end
    
    % Optimise alignment matrices A such that A{m}*L{m} = <A{m}*L{m}>m
    %----------------------------------------------------------------------
    %%modif FL
    switch modalities{m}
        case 'EEG'
            Nm_max=ceil(size(L,1)/4); % approx nb of sensors / 4 : from visual inspection...
            VarThresh=99.90;
            
        case 'MEG'
            Nm_max=ceil(size(L,1)/4);
            VarThresh=99.99; % MEG > EEG : larger spatial res. in MEG allowing to take into account a larger nb of modes (+ different individual specificities)
        otherwise
            disp('sorry not implemented')
            return
    end
    
    % MOdif FL : used to be an iterative process: not anymore
    
    %figure; imagesc(UL{m}*UL{m}'), axis square; title([ ' UL, iter = ' num2str(j) ]);
    % eliminate redundant virtual channels
    %------------------------------------------------------------------
    %fprintf('Aligning - iteration: %i\n',j)
    UL{m} = spm_sqrtm(spm_inv(AA))*UL{m};
    
    % eliminate low SNR spatial modes
    %------------------------------------------------------------------
    %modif FL
    U  = spm_svd_FL_Thresh_SpatMode((UL{m}*UL{m}'),VarThresh, Nm_max);
    %fin modif FL
    
    UL{m} = U'*UL{m}; % Nmodes* Ndip
    Nm(m) = size(UL{m},1);
    
    disp(['................' num2str(1)  '..........' num2str(Nm(m) ) '..............']);%FL
    % normalise lead-field
    %------------------------------------------------------------------
    Scale = sqrt(trace(UL{m}*UL{m}')/Nm(m));
    UL{m} = UL{m}/Scale;
    %figure; imagesc(UL{m}*UL{m}'), axis square; title([ ' UL scale apres svd , iter = ' num2str(j) ' Nm= ' num2str(Nm) ]);
    % spatial projectors A{i,m) for i = 1,...,Nl subjects
    %------------------------------------------------------------------
    AL    = 0;
    AA    = 0;
    
    for i = 1:Nl
        L      = R{i,m}*spm_eeg_lgainmat(D{i},Is,D{i}.chanlabels(Ic{i,m}));
        A{i,m} = UL{m}*L'*iL{i};
        AL     = AL + A{i,m}*L;
        AA     = AA + A{i,m}*A{i,m}';
        
        
    end
    
    % re-compute average
    %------------------------------------------------------------------
    UL{m} = AL/Nl;
    
    for i = 1:Nl
        L      = R{i,m}*spm_eeg_lgainmat(D{i},Is,D{i}.chanlabels(Ic{i,m}));
        A{i,m} = UL{m}*L'*iL{i};
        
    end
    
    
    % Report
    %----------------------------------------------------------------------
    fprintf('Using %d spatial modes for modality %s\n',Nm(m),modalities{m})
  
   
end

save(File_Save, 'UL', 'A', 'iL');

