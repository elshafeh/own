function [D] = spm_eeg_invert_dycog_NoIter_GLI_step2(D, val)
% ReML inversion of multiple forward models for EEG-MEG
% FORMAT [D] = spm_eeg_invert(D)
% ReML estimation of regularisation hyperparameters using the
% spatiotemporal hierarchy implicit in EEG/MEG data
%
% Requires:
% D{i}.inv{val}.inverse:
%
%     inverse.modality - modality to use in case of multimodal datasets
%
%     inverse.trials - D.events.types to invert
%     inverse.type   - 'GS' Greedy search on MSPs
%                      'ARD' ARD search on MSPs
%                      'MSP' GS and ARD multiple sparse priors
%                      'LOR' LORETA-like model
%                      'IID' minimum norm
%     inverse.woi    - time window of interest ([start stop] in ms)
%     inverse.lpf    - band-pass filter - low frequency cut-off (Hz)
%     inverse.hpf    - band-pass filter - high frequency cut-off (Hz)
%     inverse.Han    - switch for Hanning window
%     inverse.xyz    - (n x 3) locations of spherical VOIs
%     inverse.rad    - radius (mm) of VOIs
%
%     inverse.Nm     - maximum number of channel modes
%     inverse.Nr     - maximum number of temporal modes
%     inverse.Np     - number of sparse priors per hemisphere
%     inverse.smooth - smoothness of source priors (0 to 1)
%     inverse.Na     - number of most energetic dipoles
%     inverse.sdv    - standard deviations of Gaussian temporal correlation
%     inverse.pQ     - any source priors (e.g. from fMRI); vector or matrix
%     inverse.Qe     - any sensor error components (e.g. empty-room data)
%     inverse.dplot  - make diagnostics plots (0 or 1)
%     inverse.STAT   - flag for stationarity assumption, which invokes a 
%                      full DCT temporal projector (from lpf to hpf Hz)
%
% Evaluates:
%
%     inverse.M      - MAP projector (reduced)
%     inverse.J{i}   - Conditional expectation (i conditions) J = M*U*Y
%     inverse.L      - Lead field (reduced UL := U*L)
%     inverse.qC     - spatial covariance
%     inverse.qV     - temporal correlations
%     inverse.T      - temporal projector
%     inverse.U(j)   - spatial projector (j modalities)
%     inverse.Y{i}   - reduced data (i conditions) UY = UL*J + UE
%     inverse.Is     - Indices of active dipoles
%     inverse.It     - Indices of time bins
%     inverse.Ic{j}  - Indices of good channels (j modalities)
%     inverse.Nd     - number of dipoles
%     inverse.pst    - peristimulus time
%     inverse.dct    - frequency range
%     inverse.F      - log-evidence
%     inverse.VE     - variance explained in spatial/temporal subspaces (%)
%     inverse.R2     - variance in subspaces accounted for by model (%)
%     inverse.scale  - scaling of data for each of j modalities
%__________________________________________________________________________
%
% 1. This routine implements "group-based" inversion, corresponding to
% ill-posed linear models of the following form:
%
% [AY{1}...AY{n}] = L(1} * [J{1}...J{n}]   +  [e{1}...e{n}]
%
% where AY{i} are the spatially normalized or adjusted data from subject i
% that would have been seen if the lead-field L{i} = L{1}. The ensuing
% Gaussian process priors on sources are then used to estimate subject-
% specific MAP estimates of J{i} using
%
% AY{i} = L(1} * J{i}  +  e{i}
%
% using spatial priors from the group model above.
%
% Here, A{i}  = L{1}*pinv(L{i}) =>
%       AY{i} = A(i}*L(i}*J{i}
%             = L(1}*J{i}
%
% Potential scaling differences between the lead-fields are handled by
% scaling L{1} such that trace(L{1}*L{1}') = constant (number of spatial
% modes or channels), while scaling the data such that trace(AY{n}*AY{n}') =
% constant over subjects (and modalities; see below).
%
% See: Electromagnetic source reconstruction for group studies.
% Litvak V, Friston K.
% NeuroImage. 2008 Oct 1;42(4):1490-8.
%
%__________________________________________________________________________
%
% 2. It also implements "fusion" of different types of MEG and EEG data,
% corresponding to ill-posed linear models of the following form:
%
%             AY{1}{1,...,t}  = L(1} * J{1,...,t}   +  e{{1,...,t}}
%             AY{2}{1,...,t}  = L(2}                   e{{2,...,t}}
%                  .
%                  .
%                  .
%             AY{m}{1,...,t}  = L(n}                   e{{n,...,t}}
%
% Under empirical priors on J{1,...,t} for m modalities with t trial types.
%
% See: MEG and EEG data fusion: Simultaneous localisation of face-evoked
% responses.
% Henson R, Mouchlianitis E & Friston K.
% Neuroimage. 2009. 47:581-9.
%__________________________________________________________________________
%
% 3. It also allows incorporation of spatial source priors, eg, from fMRI
% (see spm_eeg_inv_fmripriors.m). Note that if a vector is passed in
% inverse.pQ, then variance components used (pass a matrix if a covariance
% component is desired).
%
% See: A Parametric Empirical Bayesian framework for fMRI-constrained
% MEG/EEG source reconstruction.
% Henson R, Flandin G, Friston K & Mattout J.
% Human Brain Mapping (in press).
%__________________________________________________________________________
%
% The routine essentially consists of two steps:
%
%   1. Optimisation of spatial source priors over subjects
%   2. Re-inversion of each subject, fusing across all modalities
%__________________________________________________________________________
% Copyright (C) 2006-2014 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_eeg_invert.m 6636 2015-12-05 23:28:50Z vladimir $
 


%% Current version : adapted by F.Lecaignard, February 2014
% spatial mode threshold modified for EEG modality (spm default => 0 modes
% bilateral constraint on source is disabled
warning('Current version of spm_eeg_invert (spm12) : adapted by F.Lecaignard, February 2014');
disp(' - Removal of the iterative  procedure for spatial mode selection- EEG and MEG thresholds adjusted to account for 99% and 99.9% of variance, resp.'); 
disp(' - DCT disabled for "too short" windows');
disp(' - Possibility to disable  the bilaterality constraint on source priors');


% current version = 03-13-17 (modif FL, correction for a bug wrt DCT temporal mode selection)

% check whether this is a group inversion for (Nl) number of subjects
%--------------------------------------------------------------------------
if ~iscell(D), D = {D}; end
Nl = length(D);
 
 
% D - SPM data structure
%==========================================================================
if nargin > 1
    D{1}.val = val;
elseif ~isfield(D{1}, 'val')
    D{1}.val = 1;
end
for i = 2:Nl
    D{i}.val = D{1}.val;
end
 
% forward model
%--------------------------------------------------------------------------
inverse   = D{1}.inv{D{1}.val}.inverse;
 
% defaults
%--------------------------------------------------------------------------
try, STAT = inverse.STAT;   catch, STAT = 0;        end
try, type = inverse.type;   catch, type = 'GS';     end
try, s    = inverse.smooth; catch, s    = 0.6;      end
try, Np   = inverse.Np;     catch, Np   = 256;      end
try, Nr   = inverse.Nr;     catch, Nr   = 16;       end
try, xyz  = inverse.xyz;    catch, xyz  = [0 0 0];  end
try, rad  = inverse.rad;    catch, rad  = 128;      end
try, mask = inverse.mask;   catch, mask = [];       end
try, lpf  = inverse.lpf;    catch, lpf  = 0;        end
try, hpf  = inverse.hpf;    catch, hpf  = 48;       end
try, sdv  = inverse.sdv;    catch, sdv  = 4;        end
try, Han  = inverse.Han;    catch, Han  = 1;        end
try, woi  = inverse.woi;    catch, woi  = [];       end
try, pQ   = inverse.pQ;     catch, pQ   = [];       end
try, dp   = inverse.dplot;  catch, dp   = 0;        end
 

CovSourceGroup_File=inverse.CovSourceGroup_File;
QG_File=inverse.QG_File; % QG = green fct for BEM
UL_File=inverse.UL_File; % UL, A for spatial mode projection

% get specified modalities to invert (default to all)
%--------------------------------------------------------------------------
try
    modalities     = inverse.modality;
    if ~iscell(modalities)
        modalities = {modalities};
    end
catch
    for m = 1:length(D{1}.inv{D{1}.val}.forward)
        modalities{m} = D{1}.inv{D{1}.val}.forward(m).modality;
    end
end
Nmod  = numel(modalities);                  % number of modalities
Nmax  = Nr;                                 % max number of temporal modes
 
 
% check lead fields and get number of dipoles (Nd) and channels (Nc)
%==========================================================================
for i = 1:Nl
    
    fprintf('Checking lead fields for subject %i\n',i)
    [L,D{i}] = spm_eeg_lgainmat(D{i});
    
    for m = 1:Nmod
        
        % Check gain or lead-field matrices
        %------------------------------------------------------------------
        Ic{i,m}  = indchantype(D{i}, modalities{m}, 'GOOD');
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
fprintf(' - done\n')
 
 
% Compute spatial coherence: Diffusion on a normalised graph Laplacian GL
%==========================================================================
 
% fprintf('Computing Green function from graph Laplacian:')
% %--------------------------------------------------------------------------
% Nd    = Nd(1);                                     % number of dipoles
% vert  = D{1}.inv{D{1}.val}.mesh.tess_mni.vert;
% face  = D{1}.inv{D{1}.val}.mesh.tess_mni.face;
% A     = spm_mesh_distmtx(struct('vertices',vert,'faces',face),0);
% GL    = A - spdiags(sum(A,2),0,Nd,Nd);
% GL    = GL*s/2;
% Qi    = speye(Nd,Nd);
% QG    = sparse(Nd,Nd);
% for i = 1:8
%     QG = QG + Qi;
%     Qi = Qi*GL/i;
% end
% QG    = QG.*(QG > exp(-8));
% QG    = QG*QG;
% clear Qi A GL
% fprintf(' - done\n')

load(QG_File); %QG
vert  = D{1}.inv{D{1}.val}.mesh.tess_mni.vert;


% check for (e.g., empty-room) sensor components (in Qe{1})
%==========================================================================
QE    = cell(Nl,Nmod);
for i = 1:Nl
    for m = 1:Nmod
        try
            QE{i,m} = D{i}.inv{D{i}.val}.inverse.Qe{m};
            QE{i,m} = Nc(i,m)*QE{i,m}/trace(QE{i,m});
            if length(QE{i,m}) ~= Nc(i,m)
                errordlg('error component (modality %s; subject %d) does not match number of channels (%d)\n',modalities{m},i,Nc(i,m))
                return
            end
            fprintf('Using sensor error component provided...\n');
            
            % assume i.i.d. if not specified
            %------------------------------------------------------------------
        catch
            
            QE{i,m} = 1;
        end
    end
end


%==========================================================================
% Spatial projectors (adjusting for different Lead-fields)
%==========================================================================

fprintf('Optimising and aligning spatial modes ...\n')
% original code removed (see spm_eeg_invert_dycog.m)
load(UL_File); % 'UL', 'A'

% get Nm (for data scaling, see below)

for m = 1:Nmod
    Nm(m)=size(UL{m},1);
    fprintf('Using %d spatial modes for modality %s\n',Nm(m),modalities{m})
end

% check restriction: assume radii are the same for all (Nv) VOI
%==========================================================================
Nv  = size(xyz,1);
if length(rad) ~= Nv
    rad = rad(1)*ones(Nv,1);
else
    rad = rad(:);
end
 
% Restrict source space to Ns sources by eliminating dipoles
%--------------------------------------------------------------------------
if any(any(xyz)) || ~isempty(mask)
    
    Is    = sparse(Nd,1);
    
    if any(any(xyz))
        for i = 1:Nv
            Iv = sum([vert(:,1) - xyz(i,1), ...
                vert(:,2) - xyz(i,2), ...
                vert(:,3) - xyz(i,3)].^2,2) < rad(i)^2;
            Is = Is | Iv;
        end
    end
    
    if ~isempty(mask)
        Iv = spm_mesh_project(struct('vertices',vert,'faces',face), mask);
        Is = Is | Iv(:);
    end
    
    Is    = find(Is);
else
    Is    = 1:Nd;
end


vert  = vert(Is,:);
QG    = QG(Is,Is);
for m = 1:Nmod
    UL{m} = UL{m}(:,Is);
end
Ns    = length(Is);
 
 
 
 
%==========================================================================
% Temporal projector
%==========================================================================
 
% loop over Nl lead-fields (subjects)
%--------------------------------------------------------------------------
Nn    = zeros(1,Nl);                             % number of samples
AY    = {};                                      % pooled response for MVB
AYYA  = 0;                                       % pooled response for ReML
for i = 1:Nl
    
    % Time-window of interest
    %----------------------------------------------------------------------
    if isempty(woi)
        w{i} = 1000*[min(D{i}.time) max(D{i}.time)];
    else
        w{i} = woi;
    end
    It{i}  = (w{i}/1000 - D{i}.timeonset)*D{i}.fsample + 1;
    It{i}  = max(1,It{i}(1)):min(It{i}(end), length(D{i}.time));
    It{i}  = fix(It{i});
    
    % Peristimulus time
    %----------------------------------------------------------------------
    pst{i} = 1000*D{i}.time;                     % peristimulus time (ms)
    pst{i} = pst{i}(It{i});                      % windowed time (ms)
    dur    = (pst{i}(end) - pst{i}(1))/1000;     % duration (s)
    dct{i} = (It{i} - It{i}(1))/2/dur;           % DCT frequencies (Hz)
    Nb(i)  = length(It{i});                      % number of time bins
    
    % Serial correlations
    %----------------------------------------------------------------------
    K      = exp(-(pst{i} - pst{i}(1)).^2/(2*sdv^2));
    K      = toeplitz(K);
    qV{i}  = sparse(K*K');
    
    % Confounds and temporal subspace
    %----------------------------------------------------------------------
    T      = spm_dctmtx(Nb(i),Nb(i));
    j      = find( (dct{i} >= lpf) & (dct{i} <= hpf) );
    T      = T(:,j);
    dct{i} = dct{i}(j);
    
    
    % Hanning operator (if requested)
    %----------------------------------------------------------------------
    if Han
        W  = sparse(1:Nb(i),1:Nb(i),spm_hanning(Nb(i)));
    else
        W  = 1;
    end
    
    % get trials or conditions
    %----------------------------------------------------------------------
    try
        trial = D{i}.inv{D{i}.val}.inverse.trials;
    catch
        trial = D{i}.condlist;
    end
    Nt(i) = length(trial);
    
    
    % get temporal covariance (Y'*Y) to find temporal modes
    %======================================================================
    MY    = cell(Nmod,1);                        % mean response
    YTY   = sparse(0);                           % accumulator
    for m = 1:Nmod                               % loop over modalities
        
        % get (spatially aligned) data
        %------------------------------------------------------------------
        N     = 0;
        YY    = 0;
        MY{m} = 0;
        for j = 1:Nt(i)                          % pool over conditions
            c     = D{i}.indtrial(trial{j});     % and trials
            Nk    = length(c);
            for k = 1:Nk
                Y     = A{i,m}*D{i}(Ic{i,m},It{i},c(k));
                MY{m} = MY{m} + Y;
                YY    = YY + Y'*Y;
                N     = N + Nb(i);
            end
        end
        
        % Apply any Hanning and filtering
        %------------------------------------------------------------------
        YY         = W'*YY*W;
        %modif FL sept 2014 : under specific cases of sample rate + source
        %woi, the number of dct can be too small to ensure more than 3
        %temporal models (which appears to be the minimum val. to avoid
        %R2=NaN. Example : Fech=200Hz, with P50 source woi= 60-70 ms ,
        %dct=0, which makes T= 3*1, which makes size(YY)=1)
        fprintf('Hanning and filtering for subject %i \n',i)
     
        if isequal(size(T,2), 1) % a single DCT compnent
            % disp('flag=0');
            disp('spm_eeg_invert_dycog_NoIter : no DCT filtering (woi too small with current sampling rate)');
            flag_svdTemp=0; % ne pas appliquer la projection sur modes temporaux (pas assez de signal)
        else
            % disp('flag=1');
            YY         = T'*YY*T;
            flag_svdTemp=1; %  appliquer la projection sur modes temporaux ( assez de signal)
        end
        
        % Scale data (to remove subject and modality scaling differences)
        %------------------------------------------------------------------
        scale(i,m) = sign(trace(MY{m}'*(UL{m}*UL{1}')*MY{1}));
        scale(i,m) = scale(i,m)/sqrt(trace(YY)/(Nm(m)*N));
        YTY        = YTY + YY*(scale(i,m)^2);
        
    end
    
    % temporal projector (at most Nmax modes) S = T*V
    %======================================================================
    if STAT % Stationarity assumption
        
        S{i}  = T;                               % temporal modes
        Nr(i) = size(T,2);                       % number of temporal modes
        VE(i) = 1;                               % variance explained
        fprintf('Using %i temporal modes for subject %i, ',Nr(i),i);
        fprintf('accounting for %0.2f percent average variance\n',full(100*VE(i)));
        
    else
        %         %original code :
        %         [U E] = spm_svd(YTY,exp(-8));            % get temporal modes
        %         E     = diag(E)/trace(YTY);              % normalise variance
        %         Nr(i) = min(length(E),Nmax);             % number of temporal modes
        %         S{i}  = T*U(:,1:Nr(i));                  % temporal modes
        %         VE(i) = sum(E(1:Nr(i)));                 % variance explained
        %         %end of original code
        
        %modif FL .......
        switch flag_svdTemp
            
            case 1 % temporal projector
                [U E]  = spm_svd(YTY,exp(-32));               % get temporal modes
                E      = diag(E)/trace(YTY);                 % normalise variance
                Nr(i)  = min(length(E),Nmax);                % number of temporal modes
                V{i}   = U(:,1:Nr(i));                       % temporal modes
                VE(i)  = sum(E(1:Nr(i)));                    % variance explained
                fprintf('Using %i temporal modes for subject %i, ',Nr(i),i)
                fprintf('accounting for %0.2f percent average variance\n',full(100*VE(i)))
                % projection and whitening
                %----------------------------------------------------------------------
                S{i}   = T*V{i};                             % temporal projector, size = Nech * Nmode
                Vq{i}  = S{i}*inv(S{i}'*qV{i}*S{i})*S{i}';   % temporal precision
                
            case 0 % no temporal projector
                fprintf('No use of temporal mode projection used for subject  %i \n',i)
                Nr(i)  = Nb(i);
                VE(i)  = 1;                    % variance explained
                S{i}   = eye(Nb(i) ,   Nb(i));               % temporal projector = identty
                Vq{i}  = S{i}*inv(S{i}'*qV{i}*S{i})*S{i}';   % temporal precision
        end
        clear flag_svdTemp
        %end of modif FL
        
        
    end
    
%     fprintf('Using %i temporal modes for subject %i, ',Nr(i),i)
%     fprintf('accounting for %0.2f percent average variance\n',full(100*VE(i)))
%     
    % whitening
    %----------------------------------------------------------------------
    Vq{i}  = S{i}*inv(S{i}'*qV{i}*S{i})*S{i}';   % temporal precision
    
    
    % get spatial covariance (Y*Y') for Gaussian process model.
    %======================================================================
    
    % loop over Nt trial types
    %----------------------------------------------------------------------
    UYYU{i} = 0;
    for j = 1:Nt(i)
        
        UY{i,j} = sparse(0);
        c       = D{i}.indtrial(trial{j});
        Nk      = length(c);
        
        % loop over epochs
        %------------------------------------------------------------------
        for k = 1:Nk
            
            % stack (scaled aligned data) over modalities
            %--------------------------------------------------------------
            for m = 1:Nmod
                Y       = D{i}(Ic{i,m},It{i},c(k))*S{i};
                MY{m}   = A{i,m}*Y*scale(i,m)/Nk;
            end
            
            % accumulate first & second-order responses
            %--------------------------------------------------------------
            Nn(i)       = Nn(i) + Nr(i);         % number of samples
            Y           = spm_cat(MY);           % contribution to ERP
            YY          = Y*Y';                  % and covariance
            
            % accumulate statistics (subject-specific)
            %--------------------------------------------------------------
            UY{i,j}     = UY{i,j} + Y;           % condition-specific ERP
            UYYU{i}     = UYYU{i} + YY;          % subject-specific covariance
            
            % and pool for optimisation of spatial priors over subjects
            %--------------------------------------------------------------
            AY{end + 1} = Y;                     % pooled response for MVB
            AYYA        = AYYA    + YY;          % pooled response for ReML
            
        end
    end
end
 
% and concatenate for optimisation of spatial priors over subjects
%--------------------------------------------------------------------------
AY    = spm_cat(AY);                             % pooled response for MVB
UL    = spm_cat(UL);                             % pooled lead fields
 
 
% generate sensor error components (Qe)
%==========================================================================
AQ{1} = sparse(0);
for m = 1:Nmod
    Qe{m} = sparse(0);
end
 
% assuming equal noise over subjects (Qe{m}) and modalities AQ
%--------------------------------------------------------------------------
N     = cell(Nmod,Nmod);
for i = 1:Nl
    for m = 1:Nmod
        N{m,m} = sparse(Nm(m),Nm(m));
    end
    for m = 1:Nmod
        Q      = N;
        AQeA   = A{i,m}*QE{i,m}*A{i,m}';
        Q{m,m} = AQeA/(trace(AQeA)/Nm(m));
        Q      = spm_cat(Q)/Nl;
        Qe{m}  = Qe{m} + Q;
        AQ{1}  = AQ{1} + Q;
    end
end
 
 
%==========================================================================
% Step 1: Optimise spatial priors over subjects
%==========================================================================
% % Multivariate Bayes
% %------------------------------------------------------------------
% MVB   = spm_mvb(AY,UL,[],Q,AQ,16);
cov=load(CovSourceGroup_File);
MVB=cov.MVB;
try
    Q=cov.Q; %patch, Ndip*Npatch
catch
    Q=MVB.Q;
end

clear cov;

QP     = {};
LQP    = {};
LQPL   = {};

% Accumulate empirical priors
%------------------------------------------------------------------

Qcp           = Q*MVB.cp;
QP{end + 1}   = sum(Qcp.*Q,2);
LQP{end + 1}  = (UL*Qcp)*Q';
LQPL{end + 1} = LQP{end}*UL';


        
       
%==========================================================================
% Step 2: Re-estimate for each subject separately (fusing all modalities)
%==========================================================================
 
for i = 1:Nl
    
    fprintf('Inverting subject %i\n',i)
    
    % generate sensor component (Qe) per modality
    %----------------------------------------------------------------------
    AQ    = 0;
    Qe    = {};
    for m = 1:Nmod
        N{m,m} = sparse(Nm(m),Nm(m));
    end
    for m = 1:Nmod
        Q      = N;
        AQeA   = A{i,m}*QE{i,m}*A{i,m}';
        Q{m,m} = AQeA/(trace(AQeA)/Nm(m));
        Qe{m}  = spm_cat(Q);
        AQ     = AQ + Qe{m};
    end
    
    % using spatial priors from group analysis
    %----------------------------------------------------------------------
    Np    = length(LQPL);
    Ne    = length(Qe);
    Q     = [Qe LQPL];
    
    % re-do ReML (with informative hyperpriors)
    %======================================================================
    Q0          = exp(-2)*trace(UYYU{i})/Nn(i)*AQ/trace(AQ);
    [Cy,h,Ph,F] = spm_reml_sc(UYYU{i},[],Q,Nn(i),-4,16,Q0);
    
    % Data ID
    %----------------------------------------------------------------------
    ID    = spm_data_id(AYYA);
    
    
    % Covariance: sensor space - Ce and source space - L*Cp
    %----------------------------------------------------------------------
    Cp    = sparse(0);
    LCp   = sparse(0);
    hp    = h(Ne + (1:Np));
    for j = 1:Np
        Cp  =  Cp + hp(j)*QP{j};
        LCp = LCp + hp(j)*LQP{j};
    end
    
    % MAP estimates of instantaneous sources
    %======================================================================
    M     = LCp'/Cy;
    
    % conditional variance (leading diagonal)
    % Cq    = Cp - Cp*L'*iC*L*Cp;
    %----------------------------------------------------------------------
    Cq    = Cp - sum(LCp.*M')';
    
    % evaluate conditional expectation (of the sum over trials)
    %----------------------------------------------------------------------
    SSR   = 0;
    SST   = 0;
    J     = {};
    for j = 1:Nt(i)
        
        % trial-type specific source reconstruction
        %------------------------------------------------------------------
        J{j} = M*UY{i,j};
        
        % sum of squares
        %------------------------------------------------------------------
        SSR  = SSR + sum(var((UY{i,j} - UL*J{j}),0,2));
        SST  = SST + sum(var( UY{i,j},0,2));
        
    end
    
    % accuracy; signal to noise (over sources)
    %======================================================================
    R2   = 100*(SST - SSR)/SST;
    fprintf('Percent variance explained %.2f (%.2f)\n',full(R2),full(R2*VE(i)));
    
    % Save results (for first modality)
    %======================================================================
    inverse.type   = type;                 % inverse model
    inverse.smooth = s;                    % smoothness (0 - 1)
    inverse.xyz    = xyz;                  % VOI (XYZ)
    inverse.rad    = rad;                  % VOI (radius)
    inverse.scale  = scale(i,:);           % data scale-factor
    inverse.M      = M;                    % MAP projector (reduced)
    inverse.J      = J;                    % Conditional expectation
    inverse.Y      = UY(i,:);              % ERP data (reduced)
    inverse.L      = UL;                   % Lead-field (reduced)
    inverse.qC     = Cq;                   % spatial covariance
    inverse.qV     = Vq{i};                % temporal correlations
    inverse.T      = S{i};                 % temporal projector
    inverse.U      = A(i,:);               % spatial projector
    inverse.Is     = Is;                   % Indices of active dipoles
    inverse.It     = It{i};                % Indices of time bins
    inverse.Ic     = Ic(i,:);              % Indices of good channels
    inverse.Nd     = Nd;                   % number of dipoles
    inverse.pst    = pst{i};               % peristimulus time
    inverse.dct    = dct{i};               % frequency range
    inverse.F      = F;                    % log-evidence
    inverse.ID     = ID;                   % data ID
    inverse.R2     = R2;                   % variance explained (reduced)
    inverse.VE     = R2*VE(i);             % variance explained
    inverse.woi    = w{i};                 % time-window inverted
    
    inverse.modality = modalities;         % modalities inverted
    
    % save in struct
    %----------------------------------------------------------------------
    D{i}.inv{D{i}.val}.inverse = inverse;
    D{i}.inv{D{i}.val}.method  = 'Imaging';
    
    % and delete old contrasts
    %----------------------------------------------------------------------
    try
        D{i}.inv{D{i}.val} = rmfield(D{i}.inv{D{i}.val},'contrast');
    end
    
    % Display
    %======================================================================
    if ~spm('CmdLine'), spm_eeg_invert_display(D{i}); end
    
end
 
if length(D) == 1, D = D{1}; end
