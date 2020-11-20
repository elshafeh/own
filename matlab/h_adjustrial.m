function [offset,code] = h_adjustrial(data,trial_struct)

x                   = trial_struct;

offset.target       = (([trial_struct.first_gab_smpl]-[trial_struct.first_cue_smpl]) ./ [trial_struct.Fs]) .* data.fsample;
offset.probe        = (([trial_struct.secnd_gab_smpl]-[trial_struct.first_cue_smpl]) ./ [trial_struct.Fs]) .* data.fsample;
offset.scnd_cue     = (([trial_struct.secnd_cue_smpl]-[trial_struct.first_cue_smpl]) ./ [trial_struct.Fs]) .* data.fsample;
offset.response     = (([trial_struct.response_smpl]-[trial_struct.first_cue_smpl]) ./ [trial_struct.Fs]) .* data.fsample;

offset.target       = round(offset.target);
offset.probe        = round(offset.probe);
offset.scnd_cue     = round(offset.scnd_cue);
offset.response     = round(offset.response);

code.target         = [trial_struct.first_gab_code];
code.probe          = [trial_struct.secnd_gab_code];
code.scnd_cue       = [trial_struct.secnd_cue_code];
code.response       = [trial_struct.response_code];
