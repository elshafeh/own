function bpilot_start

global scr ctl Info

Info.logfolder          = ['Logfiles' filesep  Info.name];
mkdir(Info.logfolder);

if strcmp(Info.runtype,'block')
    fname_out           = [Info.logfolder filesep  Info.name '_JYcent_' Info.runtype]; % Info.blocNumber];
else
    fname_out           = [Info.logfolder filesep  Info.name '_JYcent_' Info.runtype '_' Info.runnumber];
end

Info.logfilename        = [fname_out '_Logfile.mat'];

Info.eyefolder          = ['EyeData' filesep  Info.name];
mkdir(Info.eyefolder);

mapName                 = [Info.logfolder filesep Info.name '.blockMapping.mat'];

ev_or_odd               = mod(str2double(Info.name(4:end)),2);

if ev_or_odd == 0
    sub_MappingList     = [1 1 2 2 1 1 2 2];
    sub_ColorList       = repmat([1 2],1,4);
else
    sub_MappingList     = [2 2 1 1 2 2 1 1];
    sub_ColorList       = repmat([2 1],1,4);
end
save(mapName,'sub_MappingList','sub_ColorList');

resp_map{1}             = [1 1;2 0];
resp_map{2}             = [1 0;2 1];

Info.MappingList        = sub_MappingList; % (str2double(Info.blocNumber));

InstructConc            = '\n\nPlease Fixate To The Center of The Screen\n\n\nPress Any Key To Continue';

if IsLinux
    scr.Pausetext{1}    = ['Press Far Left Key for MATCH\n\nPress Far Right Key for NO-MATCH' InstructConc];
    scr.Pausetext{2}    = ['Press Far Left Key for NO-MATCH\n\nPress Far Right Key for MATCH' InstructConc];
else   
    scr.Pausetext{1}    = ['Press D for MATCH\n\nPress K for NO-MATCH' InstructConc];
    scr.Pausetext{2}    = ['Press D for NO-MATCH\n\nPress K for MATCH' InstructConc];
end

% -- open bisti up
if IsLinux
    try
        scr.b   = Bitsi('/dev/ttyS0');
    catch
        fclose(instrfind);
        scr.b   = Bitsi('/dev/ttyS0');
    end
end

% Create Trials array
% if a sudden exit has occured ; this load the previous one before the
% crash and build up on

if exist(Info.logfilename)
    tmp                                     = load(Info.logfilename);
    Info.TrialInfo                          = tmp.Info.TrialInfo; clear tmp;
else
    Info.TrialInfo                          = bpilot_CreateAllTrials(sub_ColorList); % change color either in first or second half of bloc
end

for ni_block = 1:size(sub_ColorList,2)
    ctl.SRMapping{ni_block}                 = resp_map{Info.MappingList(ni_block)}; 
end

if strcmp(Info.runtype,'train')
    Info.TrialInfo                          = Info.TrialInfo(1:20,:); % choose twenty trials for training
end