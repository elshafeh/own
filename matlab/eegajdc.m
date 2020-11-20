function DataCorrAjdcFilename = eegajdc(eegfilename, varargin)
%% eegajdc() - Perform Approximate joint diagonalization of cospectra (AJDC) of an *.eeg ELAN dataset using the AJDC algorithm of Congedo (2008) with optional dimension reduction
% Usage:
%   >> DataCorrAjdcFilename = eegajdc(eegfilename) % Computing with default settings
%   >> DataCorrAjdcFilename = eegajdc(eegfilename, 'key', 'val' ); % Computing with custom settings
%
%* INPUTS:
%   eegfilename                 - input dataset *.eeg Elan filename
%
% Optional inputs:
%   'timewindow'                - The AJDC is performed on this time window [begin end] in seconds
%                                   If omitted, a data scrolling is displayed to select manually the time window of interest
%   'listchans'                 - a vector containing the channel indices to process.
%                                   If omitted, default is 'all'
%   'chanlocfile'               - name of channels location file.
%                                   If omitted, automatic settings of channels location
%   'frequencyband'             - frequency band of interest (Hz)
%                                   If omitted, default is [1 20] Hz
%   'compreduc_explainedvar'    - accumulated explained variance percentage of eigenvalues .
%                                   If equal to 100%, no dimension reduction is applied
%                                   If omitted, default is 95%
%
%* OUTPUT :
%   DataCorrAjdcFilename = corrected data *.eeg Elan filename
%
% V0 : Manu Maby 2017/10/01
FlagWindows = strcmp(filesep,'\');


if FlagWindows
    pathUtilElan = '\\10.69.111.22\dycog\commun\soft\matlab\prog\util_ELAN';
    pathEEGLAB = '\\10.69.111.22\dycog\commun\soft\matlab\prog\eeglab14_1_0b';
else
    pathUtilElan = '/dycog/commun/soft/matlab/prog/util_ELAN';
    pathEEGLAB = '/dycog/commun/soft/matlab/prog/eeglab14_1_0b';
end

if  isempty(strfind(path,pathUtilElan))
    addpath(genpath(pathUtilElan))
end

if isempty(strfind(path,pathEEGLAB))
    addpath(genpath(pathEEGLAB))
end

% Default settings if no optional input
global ChanLocationFile

if FlagWindows
    ChanLocationFile = '\\10.69.111.22\dycog\commun\soft\matlab\prog\eeglab14_1_0b\sample_locs\eloctmp.locs';
else
    ChanLocationFile = '/dycog/commun/soft/matlab/prog/eeglab14_1_0b/sample_locs/eloctmp.locs';
end

CompReduc_ExplainedVar = 95;
FrequencyBand = [1 20];
TimeWinsec4ICA = [];
v_TabChan=[];
% Reading of optional settings
for i = 1:2:length(varargin) % for each Keyword
    Keyword = varargin{i};
    Value = varargin{i+1};
    if strcmp(lower(Keyword),'timewindow')
        TimeWinsec4ICA = Value;
    end
    if strcmp(lower(Keyword),'listchans')
        v_TabChan = Value;
    end
    
    if strcmp(lower(Keyword),'chanlocfile')
        ChanLocationFile = Value;
    end
    if strcmp(lower(Keyword),'frequencyband')
        FrequencyBand = Value;
    end
    
    if strcmp(lower(Keyword),'compreduc_explainedvar')
        CompReduc_ExplainedVar = Value;
    end
end


% Read *.eeg Elan file
[m_data,m_events,v_label_selected,s_fs,s_nb_samples_all,s_nb_channel_all,v_label_all,v_channel_type_all,v_channel_unit_all,str_ori_file1,str_ori_file2] = eeg2mat(eegfilename,1,'all','all');

if isempty(v_TabChan)
    createlocsfile(v_label_selected);
    NbChannels = length(v_label_selected);
    DATA = m_data';
else
    createlocsfile(v_label_selected(v_TabChan));
    NbChannels = length(v_label_selected(v_TabChan)) ;
    DATA = m_data(v_TabChan,:)';
end

DataSetName = 'Data_tmp';

SamplingRate = s_fs;

m_EvtCode = m_events;

% Convert data in EEGLAB format
EEG_Input = ConvertMat2EEGLAB(DataSetName,NbChannels,ChanLocationFile,SamplingRate,DATA,m_EvtCode);


if isempty(TimeWinsec4ICA)
    
    % Time window selection to process AJDC
    Datadisp=(detrend((EEG_Input.data)','constant'))';
    DataSort = sort(abs(Datadisp(:)));
    MaxScale = DataSort(fix(0.99*length(EEG_Input.data(:))));
    eegplot(EEG_Input.data,'eloc_file',ChanLocationFile,'spacing',MaxScale,'srate',EEG_Input.srate,'events', EEG_Input.event, 'winlength',20,'dispchans',min(EEG_Input.nbchan,20),'submean','on','title','Raw data')
    
    res = inputgui('geometry', { 1 1 }, 'uilist', ...
        { { 'style' 'text' 'string' 'Time windows for AJDC ,  Enter start and end latencies (in sec with space delimiter)' } ...
        { 'style' 'edit' 'string' '' } });
    
    TimeWinsec4ICA = str2num(char(res));
    close all
    
end
PtsWinsec4ICA = fix(TimeWinsec4ICA*EEG_Input.srate);
EEG4ICA = eeg_eegrej( EEG_Input, [1 PtsWinsec4ICA(1);PtsWinsec4ICA(2)  EEG_Input.pnts] );


% Compute AJDC
EEGica = pop_runica(EEG4ICA,'icatype','ajdc','FrequencyBand',FrequencyBand,'FFT_FrequencyResolution',0.25,'FFT_OverLapTimeWindow',0,'Percentage_ExplainedVariance',CompReduc_ExplainedVar);
clear EEG4ICA
%% Component identification
% Compute component projections
EEG_Filt = pop_eegfiltnew(EEGica,FrequencyBand(1),FrequencyBand(2));
EEG_Filt.chanlocs=readlocs( ChanLocationFile );

ICAcomponentFilt = eeg_getdatact(EEG_Filt, 'component', [1:size(EEG_Filt.icaweights,1)]);
Datadisp=(detrend((ICAcomponentFilt)','constant'))';
DataSort = sort(abs(Datadisp(:)));
MaxScale = DataSort(fix(0.99*length(ICAcomponentFilt(:))));

% Plot decomposed components
eegplot( ICAcomponentFilt, 'srate',EEG_Filt.srate,'spacing',MaxScale,'winlength',20,'submean','on','dispchans',min(size(ICAcomponentFilt,1),20));

% Topographic view of components
NbCompo = size(ICAcomponentFilt,1);
SubTopo =  [fix(sqrt(NbCompo)) ceil(NbCompo/fix(sqrt(NbCompo)))];

pop_topoplot(EEG_Filt,0, [1:NbCompo] ,'Ind Components',SubTopo ,0,'electrodes','on','conv','off','gridscale',36);
clear EEG_Filt
ColorMapU821 = [1.0000         0         0
    0.9500         0         0
    0.7999         0    0.3969
    0.5998         0    0.6945
    0.4498         0    0.6945
    0.2997         0    0.6945
    0         0    0.5953
    0    0.3815    0.4730
    0    0.6409    0.3967
    0    0.8721    0.0744
    0.5875    1.0000         0
    0.7938    1.0000         0
    1.0000    1.0000         0];
colormap(ColorMapU821)




EEG_Input.icawinv = EEGica.icawinv;
EEG_Input.icasphere = EEGica.icasphere;
EEG_Input.icaweights = EEGica.icaweights;
EEG_Input.icachansind = EEGica.icachansind;
EEG_Input.icaact = [];

% Component rejection
EEG_Clean = pop_subcomp( EEG_Input);


% Plot corrected data
Datadisp=(detrend((EEG_Input.data)','constant'))';
DataSort = sort(abs(Datadisp(:)));
MaxScale = DataSort(fix(0.99*length(EEG_Input.data(:))));
Datadisp=(detrend((EEG_Clean.data)','constant'))';
DataSort = sort(abs(Datadisp(:)));
MaxScale = max(MaxScale,DataSort(fix(0.99*length(EEG_Clean.data(:)))));

eegplot( EEG_Input.data,'data2',EEG_Clean.data,'eloc_file',ChanLocationFile,'spacing',MaxScale, 'srate',EEG_Input.srate,'winlength',20,'submean','on','dispchans',min(size(EEG_Input.data,1),20));



% Save data in a *eeg Elan file (input fielename concatenated with .corrajd
[PATHSTR,NAME,EXT] = fileparts(eegfilename);
if isempty(PATHSTR)
    DataCorrAjdcFilename = ['.' filesep NAME '.corrajdc.eeg'];
    
else
    DataCorrAjdcFilename = [PATHSTR filesep NAME '.corrajdc.eeg'];
end

DataClean2eeg = m_data;
if not(isempty(v_TabChan))
    DataClean2eeg(v_TabChan,:) = EEG_Clean.data;
end



mat2eeg(DataClean2eeg, DataCorrAjdcFilename, m_events, str_ori_file1, str_ori_file2, s_fs, v_label_selected, v_channel_type_all,v_channel_unit_all);





%% Create a location channel file from file containing label and polar coordinates of 81 EEG and 275 MEG channels
function createlocsfile(v_label_selected)
global ChanLocationFile

FlagWindows = strcmp(filesep,'\');
if FlagWindows
    fid = fopen('\\10.69.111.22\dycog\commun\soft\matlab\prog\eeglab14_1_0b\sample_locs\eloc81EEG275MEG.txt','rt');
else
    fid = fopen('/dycog/commun/soft/matlab/prog/eeglab14_1_0b/sample_locs/eloc81EEG275MEG.txt','rt');
end


[TabResult] = textscan(fid,'%f%f%s');
fclose(fid);
TabTheta   = TabResult{1};
TabR     = TabResult{2};
TabLabel   = (TabResult{3});

fidnew = fopen(ChanLocationFile,'wt');

NbChannels = length(v_label_selected);
for i=1:NbChannels
    LabelCurr = char(v_label_selected(i));
    idot=strfind(LabelCurr,'.');
    LabelCurr = LabelCurr(1:idot-1);
    ix = find(not(cellfun(@isempty,strfind(TabLabel,LabelCurr))));
    for j=1:length(ix)
        if length(char(TabLabel(ix(j)))) == length(LabelCurr)
            fprintf(fidnew,'%d\t%.3f\t%f\t%s\n',i, TabTheta(ix(j)), TabR(ix(j)), char(TabLabel(ix(j))));
        end
    end
end
fclose(fidnew);

%% Convert data in EEGLAB format
function EEG = ConvertMat2EEGLAB(DataSetName,NbChannels,ChanLocationFile,SamplingRate,DATA,m_EvtCode)
EEG.setname=DataSetName;
EEG.filename= '';
EEG.filepath= '';
EEG.subject= '';
EEG.group= '';
EEG.condition= '';
EEG.session= [];
EEG.comments= '';
EEG.nbchan= NbChannels;
EEG.trials= 1;
EEG.pnts= size(DATA,1);
EEG.srate= SamplingRate;
EEG.xmin= 0;
EEG.xmax = EEG.pnts-1;
EEG.times=EEG.xmin:EEG.xmax ;
EEG.data = DATA';
EEG.icaact= [];
EEG.icawinv= [];
EEG.icasphere= [];
EEG.icaweights= [];
EEG.icachansind= [];
EEG.chanlocs=readlocs( ChanLocationFile );
EEG.urchanlocs= [];
EEG.chaninfo.plotrad= [];
EEG.chaninfo.shrink= [];
EEG.chaninfo.nosedir= '+X';
EEG.chaninfo.nodatchans= [];
EEG.chaninfo.icachansind= [];
EEG.ref= 'nose';

EEG.event.latency = [];
EEG.event.duration = [];
EEG.event.channel = [];
EEG.event.type = [];
EEG.event.urevent = [];
if ~isempty(m_EvtCode)
    for ievt = 1 :length(m_EvtCode(:,2))
        EEG.event(ievt).latency = m_EvtCode(ievt,1);
        EEG.event(ievt).duration = 1;
        EEG.event(ievt).channel = 0;
        EEG.event(ievt).type = m_EvtCode(ievt,2);
        EEG.event(ievt).urevent = ievt;
    end
end
EEG.urevent=EEG.event;
EEG.eventdescription= {''  ''  ''  ''  ''  ''  ''  ''};
EEG.epoch= [];
EEG.epochdescription= {};

EEG.reject.rejjpE= [];
EEG.reject.rejjp= [];
EEG.reject.rejkurtE= [];
EEG.reject.rejkurt= [];
EEG.reject.rejmanualE= [];
EEG.reject.rejmanual= [];
EEG.reject.rejthreshE= [];
EEG.reject.rejthresh= [];
EEG.reject.rejconstE= [];
EEG.reject.rejconst= [];
EEG.reject.rejfreqE= [];
EEG.reject.rejfreq= [];
EEG.reject.icarejjpE= [];
EEG.reject.icarejjp= [];
EEG.reject.icarejkurtE= [];
EEG.reject.icarejkurt= [];
EEG.reject.icarejmanualE= [];
EEG.reject.icarejmanual= [];
EEG.reject.icarejthreshE= [];
EEG.reject.icarejthresh= [];
EEG.reject.icarejconstE= [];
EEG.reject.icarejconst= [];
EEG.reject.icarejfreqE= [];
EEG.reject.icarejfreq= [];
EEG.reject.rejglobal= [];
EEG.reject.rejglobalE= [];
EEG.reject.rejmanualcol= [1 1 0.7830];
EEG.reject.rejthreshcol= [0.8487 1 0.5008];
EEG.reject.rejconstcol= [0.6940 1 0.7008];
EEG.reject.rejjpcol= [1 0.6991 0.7537];
EEG.reject.rejkurtcol= [0.6880 0.7042 1];
EEG.reject.rejfreqcol= [0.9596 0.7193 1];
EEG.reject.disprej= {};
EEG.reject.threshold= [0.8000 0.8000 0.8000];
EEG.reject.threshentropy= 600;
EEG.reject.threshkurtact= 600;
EEG.reject.threshkurtdist= 600;
EEG.reject.gcompreject= [];


EEG.stats.jp= [];
EEG.stats.jpE= [];
EEG.stats.icajp= [];
EEG.stats.icajpE= [];
EEG.stats.kurt= [];
EEG.stats.kurtE= [];
EEG.stats.icakurt= [];
EEG.stats.icakurtE= [];
EEG.stats.compenta= [];
EEG.stats.compentr= [];
EEG.stats.compkurta= [];
EEG.stats.compkurtr= [];
EEG.stats.compkurtdist= [];


EEG.specdata= [];
EEG.specicaact= [];
EEG.splinefile= '';
EEG.icasplinefile= '';
EEG.dipfit= [];
EEG.history= [];
EEG.saved= 'no';
EEG.etc.eeglabvers= '14.0.0';
EEG.datfile= '';


