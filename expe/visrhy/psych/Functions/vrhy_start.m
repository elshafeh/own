function vrhy_start

global scr ctl Info

Info.logfolder          = ['Logfiles' filesep  Info.name];
mkdir(Info.logfolder);

fname_out               = [Info.logfolder filesep  Info.name '_visrhythm_' Info.runtype];
Info.logfilename        = [fname_out '_Logfile.mat'];

% -- open bisti up
if IsLinux
    try
        scr.b   = Bitsi('/dev/ttyS0');
    catch
        fclose(instrfind);
        scr.b   = Bitsi('/dev/ttyS0');
    end
end

% Create Trials

if strcmp(Info.runtype,'train')
    repeat = 3;
    repeat_freq = 1;
    possib_isi                              = [1 2 3 0];
    [Stim,ISI,trialinfo,timing,expectedRep] = vrhy_CreateAllTrials(repeat, 5, repeat_freq, possib_isi);
    Info.bloc_length                        = 3 * length(possib_isi) * repeat; % nrFreqs * nrTrialTypes * repeat
    Info.nr_blocs                           = 1;
else
    repeat = 8;
    repeat_freq = 4;
    possib_isi                              = [1 2 3 0 0]; % 0 twice to make catch trials 40%
    [Stim,ISI,trialinfo,timing,expectedRep] = vrhy_CreateAllTrials(repeat,5, repeat_freq, possib_isi);
    Info.bloc_length                        = length(possib_isi) * repeat;     
    Info.nr_blocs                           = repeat_freq * 3; % Number of frequencies times number of repetitions per frequency
end

Info.Stim                                   = Stim;
Info.ISI                                    = ISI;
Info.trialinfo                              = trialinfo;
Info.timing                                 = timing;
Info.expectedRep                            = expectedRep;

% empty parameters to be filled later on
Info.rt                                     = [];
Info.correct                                = [];
Info.button                                 = [];
Info.blocks.acc                             = [];
Info.blocks.sleep                           = [];
Info.blocks.rhythmicity                     = [];