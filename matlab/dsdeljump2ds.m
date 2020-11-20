function [filenamecorrectedmegdata,v_LatencyJump,v_NameSensArtefacted]=dsdeljump2ds(ds_directory, Threshold, Duration2RemoveBefore, Duration2RemoveAfter)
% Remove sensor jumps, store the result in new *.ds and update the bad.segments file
%
% USAGE 
%%   [filenamecorrectedmegdata,v_LatencyJump,v_NameSensArtefacted]=dsdeljump2ds(ds_directory, Threshold, Duration2RemoveBefore, Duration2RemoveAfter)
%       ds_directory   : *.ds file name with complete path name 
%       Threshold      : Threshold in fT
%       Duration2RemoveBefore : duration (ms) before the jump for which data are set to a constant value (ex : 200 ms)
%       Duration2RemoveAfter : duration (ms) after the jump for which data are set to a constant value (ex : 200 ms)
%
%       filenamecorrectedmegdata : new dataset file name with corrected data
%       v_LatencyJump : jump latencies in s
%       v_SensArtefacted : artefacted MEG sensors  name




[DS,DATA] = ds2mat(ds_directory);
[pathstr,namefileorig] = fileparts(ds_directory);

% Extract MEG data
CharLabel=DS.res4.chanNames;
IdxMEGchannels = find (((CharLabel(:,1)=='M')));
DATA_MEG = (DATA(:,IdxMEGchannels));

% Remove Sensor jumps
[MEG_data_Corrected,v_LatencyJump,v_SensArtefacted] = MatDeljumpsens(DATA_MEG, DS.res4.sample_rate, Threshold,Duration2RemoveBefore,Duration2RemoveBefore);
v_LatencyJump = v_LatencyJump/DS.res4.sample_rate;
v_NameSensArtefacted= CharLabel(IdxMEGchannels(v_SensArtefacted),1:5);

badSegmentBeg = v_LatencyJump - (DS.res4.preTrigPts/DS.res4.sample_rate) - (Duration2RemoveBefore/1000);
badSegmentEnd = v_LatencyJump - (DS.res4.preTrigPts/DS.res4.sample_rate) + (Duration2RemoveAfter/1000);




% New data with corrected MEG data
newdata=DATA;
newdata(:,IdxMEGchannels)=MEG_data_Corrected;

% save new dataset
filenamecorrectedmegdata=fullfile(DS.path,[ DS.baseName '.deljump.ds']);
[pathstr,namefilecorr] = fileparts(filenamecorrectedmegdata);
newds=writeCTFds( filenamecorrectedmegdata,DS,newdata);

% copy BadChannels, bad.segments, *.hc, params.dsc  files in the new dataset

cmdtmp=['cp ' ds_directory filesep 'BadChannels ' filenamecorrectedmegdata filesep '.'];
system(cmdtmp);

cmdtmp=['cp ' ds_directory filesep 'bad.segments ' filenamecorrectedmegdata filesep '.'];
system(cmdtmp);

cmdtmp=['cp ' ds_directory filesep namefileorig '.hc '  filenamecorrectedmegdata filesep namefilecorr '.hc'];
system(cmdtmp);

cmdtmp=['cp ' ds_directory filesep 'params.dsc ' filenamecorrectedmegdata filesep '.'];
system(cmdtmp);

% Update the bad.segments file
badsegmentsFile = [filenamecorrectedmegdata filesep 'bad.segments'];

NewTabBadsegment = [[ones(length(badSegmentBeg),1) badSegmentBeg' badSegmentEnd']];

if ~isempty(badSegmentEnd)
    fid= fopen(badsegmentsFile,'a');
    fprintf(fid,'%d\t\t%f\t%f\n',NewTabBadsegment');
    fclose(fid);
end
