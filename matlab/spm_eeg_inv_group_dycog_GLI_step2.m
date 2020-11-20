function spm_eeg_inv_group_dycog_GLI_step2(S, INVval, INVtype,INVwoi,INVHan, INVlpf, INVhpf,INVtrials, ModSelect,CovSourceGroup_File, QG_File, UL_File)
% Source reconstruction for a group ERP or ERF study
% FORMAT spm_eeg_inv_group(S)
% Original SPM12 code adapted by dycog to be scripted (F.Lecaignard)
%
% Inputs
% S  - string array  of names of M/EEG mat files for inversion (optional)
% INVpar - input added by dycog, structure contains inversion parameters
%__________________________________________________________________________
%
% spm_eeg_inv_group inverts forward models for a group of subjects or ERPs
% under the simple assumption that the [empirical prior] variance on each
% source can be factorised into source-specific and subject-specific terms.
% These covariance components are estimated using ReML (a form of Gaussian
% process modelling) to give empirical priors on sources.  Source-specific
% covariance parameters are estimated first using the sample covariance
% matrix in sensor space over subjects and trials using multiple sparse
% priors (and,  by default, a greedy search).  The subject-specific terms
% are then estimated by pooling over trials for each subject separately.
% All trials in D.events.types will be inverted in the order specified.
% The result is a contrast (saved in D.mat) and a 3-D volume of MAP or
% conditional estimates of source activity that are constrained to the
% same subset of voxels.  These would normally be passed to a second-level
% SPM for classical inference about between-trial effects, over subjects.
%__________________________________________________________________________
%
% References:
% Electromagnetic source reconstruction for group studies. V. Litvak and
% K.J. Friston. NeuroImage, 42:1490-1498, 2008.
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_eeg_inv_group.m 6862 2016-08-25 14:42:19Z guillaume $
 
SVNrev = '$Rev: 6862 $';


%% %% Current version : adapted from spm_eeg_inv_group.m 

%   Adjustements of SPM12 code to start individual inversions with group
%   priors (shortcut of group-level inference 5GLI) step 1)
%   F.Lecaignard, july -2017
%
%%


% % Inversion Parameters
% %----------------------
% % parameters of inversion of forward model for EEG-MEG :
% %     inverse.type   - 'GS' Greedy search on MSPs
% %                      'ARD' ARD search on MSPs
% %                      'LOR' LORETA-like model
% %                      'IID' LORETA and minimum norm
% %     inverse.woi    - 
% %     inverse.Han    - switch for Hanning window
% %     inverse.lpf    - band-pass filter - low frequency cut-off (Hz)
% %     inverse.hpf    - band-pass filter - high frequency cut-off (Hz)
% 
% 
% 
% INVtype     = INVpar.Meth; 
% INVwoi      = liste_WIN{j}; % woi
% INVHan      = 0;
% INVlpf      = 0;
% INVhpf      = 45;
% INVtrials   =liste_INVtrials{j};
% wind_tfwc    = [INVwoi]; % get time window
% freq_tfwc    = [0];        % get frequency window
% ContrastType = 'evoked';   
% 
% 
% %attention, si fichier existe deja, log se rajoute apres, fausse les
% %resultats
% diary(['/sps/cermep/cermep/experiments/DCM/manip1/reconstruction_2-45_refmasto_spm8/source_' namelist{j} '.log']);
% try
%     S=liste_Dfiles{j};
%     spm_eeg_inv_group_FL_spm8(S,INVtype,INVwoi,INVHan, INVlpf, INVhpf, INVtrials,ModSelect, ContrastType, wind_tfwc,freq_tfwc, File_UNIpatchpriors)
% end
% 
% 
% 
% 

 
%-Startup
%--------------------------------------------------------------------------
spm('FnBanner', mfilename, SVNrev);
 
% %-Check if to proceed
% %--------------------------------------------------------------------------
% str = questdlg({'This will overwrite previous source reconstructions.', ...
%     'Do you wish to continue?'},'M/EEG Group Inversion','Yes','No','Yes');
% if ~strcmp(str,'Yes'), return, end

% Which forward model ?
FWDmodel = INVval;
 
% Load data
%==========================================================================
 
% Give file names
%--------------------------------------------------------------------------
if ~nargin
    [S, sts] = spm_select(Inf, 'mat','Select M/EEG mat files');
    if ~sts, return; end
end
Ns    = size(S,1);
swd   = pwd;

 
% Load data and set method
%==========================================================================
for i = 1:Ns
    
    fprintf('checking for previous inversions: subject %i\n',i);
    D{i}                 = spm_eeg_load(deblank(S(i,:)));
    D{i}.val             = FWDmodel;
    D{i}.inv{FWDmodel}.method   = 'Imaging';
    
    % clear redundant models
    %----------------------------------------------------------------------
    % D{i}.inv = D{i}.inv(FWDmodel);
    
    
    % clear previous inversions
    %----------------------------------------------------------------------
    try, D{i}.inv{FWDmodel} = rmfield(D{i}.inv{FWDmodel},'inverse' ); end
    try, D{i}.inv{FWDmodel} = rmfield(D{i}.inv{FWDmodel},'contrast'); end
    
    % save forward model parameters
    %----------------------------------------------------------------------
    save(D{i});
    
end
 
% Check for existing forward models and consistent Gain matrices
%--------------------------------------------------------------------------
Nd = zeros(1,Ns);
for i = 1:Ns
    fprintf('checking for forward models: subject %i\n',i);
    try
        [L, D{i}] = spm_eeg_lgainmat(D{i});
        Nd(i) = size(L,2);               % number of dipoles
    catch
        Nd(i) = 0;
    end
end
 
% use template head model where necessary
%==========================================================================
if max(Nd > 1024)
    NS = find(Nd ~= max(Nd));            % subjects requiring forward model
else
    NS = 1:Ns;
end
for i = NS
 
    cd(D{i}.path);
 
    % specify cortical mesh size (1 to 4; 1 = 5125, 2 = 8196 dipoles)
    %----------------------------------------------------------------------
    Msize  = 2;
 
    % use a template head model and associated meshes
    %======================================================================
    D{i} = spm_eeg_inv_mesh_ui(D{i}, 1, 1, Msize);
 
    % save forward model parameters
    %----------------------------------------------------------------------
    save(D{i});
 
end
 
% Get inversion parameters - Dycog adjustments
%==========================================================================
% inverse = spm_eeg_inv_custom_ui(D{1});
inverse.type = INVtype; 
inverse.woi = INVwoi;
inverse.Han = INVHan;
inverse.lpf = INVlpf;
inverse.hpf = INVhpf;
inverse.trials = INVtrials;
inverse.pQ  = {};

inverse.CovSourceGroup_File=CovSourceGroup_File;
inverse.QG_File=QG_File;
inverse.UL_File=UL_File;

% Select modality
%==========================================================================
% Modality
%------------------------------------------------------------------
[mod, list] = modality(D{1}, 1, 1);
if strcmp(mod, 'Multimodal')
    %     [selection, ok]= listdlg('ListString', list, 'SelectionMode', 'multiple' ,...
    %         'Name', 'Select modalities' , 'InitialValue', 1:numel(list),  'ListSize', [400 300]);
    %     if ~ok
    %         return;
    %     end
    switch ModSelect
        case 'EEG'
            selection =  [2];
        case 'MEG'
            selection = [1];
        case 'MEEG'
            selection  = [1 2];
    end
    inverse.modality  = list(selection);
    try
        disp([ 'Modality used for source reconstrution : ' inverse.modality{1} ',   '  inverse.modality{2} ]);
    catch
        disp([ 'Modality used for source reconstrution : ' inverse.modality{1}  ]);
        
    end
    
    
    if numel(inverse.modality) == 1
        inverse.modality = inverse.modality{1};
    end
else
    inverse.modality = mod;
end
 
for i = 2:Ns
    [mod, list] = modality(D{i}, 1, 1);
    if ~all(ismember(inverse.modality, list))
        error([inverse.modality ' modality is missing from ' D{i}.fname]);
    end
end
 
% and save them (assume trials = types)
%--------------------------------------------------------------------------
for i = 1:Ns
    D{i}.inv{FWDmodel}.inverse = inverse;
end

% inversion
%--------------------------------------------------------------------------

D     = spm_eeg_invert_dycog_NoIter_GLI_step2(D);
if ~iscell(D), D = {D}; end
 
% Save
%==========================================================================
for i = 1:Ns
    try
        save(D{i});
    catch
        save_v73(D{i}); % FL, modified here (N-trial inversions leads to matlab warning "Warning: Variable 'D' was not saved. For variables larger than 2GB use MAT-file version 7.3 or later. "
    end
end
clear D
 
 

 
% Cleanup
%==========================================================================
cd(swd);

