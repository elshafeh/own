% ins_temporalClusterPermuTest_WithinBetween.m
function result = ins_temporalClusterPermuTest_WithinBetween(data, def, cfg, structTemplate)
% http://meg.univ-amu.fr/wiki/Main_Page %%%%%%%%%%%%%
% 
% Nonparametric MEG data analysis with two factors (groups and conditions)
% on two levels each. Permutation test based on temporal clusters on the
% data grouped into regions of interest.
% [Analyse non paramétrique de données MEG avec deux facteurs (groupes et
% conditions) à deux niveaux chacun. Test par permutation basé sur des
% clusters temporels sur les données regroupées en régions d'intérêt.]
%
% DEPENDANCES:
% This function uses the FieldTrip MATLAB software toolbox
% (http://www.fieldtriptoolbox.org/)
%
% USAGE:
% result = ins_temporalClusterPermuTest_WithinBetween(
%                               data,
%                               def,
%                               cfg,
%                               structTemplate)
%
% INPUTS:
% data              = array <1xN struct>
%                   where N = person x roi x cond x other criterium (side)
%                   example of struct : person = 'sujet01'
%                                       group = 'control'
%                                       condition = 'condition_A'
%                                       roi = 'roi_3'
%                                       side = 'left'
%                                       time = <1x193 double>
%                                       avgabs = <1x193 double>
% def               = structure arrays with correspondance between waited
%                   field names and data field names, and list of levels
%                   for each categorical field. Waited field names are :
%                   subject, group, cond, roi, other (other selection criterium),
%                   time, value.
% cfg               = configuration parameters (cf. example).
% structTemplate	= template to reconstruct the data structure waited by
%                   the FieldTrip function ft_timelockgrandaverage.
%                   (cf. http://www.fieldtriptoolbox.org/reference/ft_timelockgrandaverage)
%
% OUTPUTS:
% result = %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% REFERENCES:
% * Cluster-based permutation tests on event related fields.
%   http://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock
% ________________________________
% Bernard Giusiano & Sophie Chen
% INSERM UMR 1106 Institut de Neurosciences des Systèmes
% Oct/2015 (first version)
% Oct/2015 (this version)
% http://ins.univ-amu.fr
 
%% global parameters
cfg.method = 'montecarlo' ;       % use the Monte Carlo Method to calculate the significance probability
cfg.correctm = 'cluster';         % Apply multiple-comparison correction
 
% Interaction between groups and conditions
if def.stats{1}
    disp('*** 1 - Interaction between groups and conditions ***');
    resultat = ins_temporalClusterPermuTest_interaction(data, def, cfg, structTemplate);
    disp(['=== ' resultat ' ===']);
end
 
% Main effect of conditions (within)
if def.stats{2}
    disp('*** 2 - Main effect of conditions (within) ***');
    resultat = ins_temporalClusterPermuTest_within(data, def, cfg, structTemplate);
    disp(['=== ' resultat ' ===']);
end
 
% Main effect of groups (between)
if def.stats{3}
    disp('*** 3 - Main effect of groups (between) ***');
    resultat = ins_temporalClusterPermuTest_between(data, def, cfg, structTemplate);
    disp(['=== ' resultat ' ===']);
end
 
% Simple effect of conditions by group
if def.stats{4}
    disp('*** 4 - Simple effect of conditions by group ***');
    resultat = ins_temporalClusterPermuTest_within_simple(data, def, cfg, structTemplate);
    disp(['=== ' resultat ' ===']);
end
 
% Simple effect of groups by condition
if def.stats{5}
    disp('*** 5 - Simple effect of groups by condition ***');
    resultat = ins_temporalClusterPermuTest_between_simple(data, def, cfg, structTemplate);
    disp(['=== ' resultat ' ===']);
end
 
result = 'END of script ins_temporalClusterPermuTest_WithinBetween.m';