function [out2, out1] = importPresentationLog(fileName, extraNames)
% Import any Presentation log file into MATLAB and enjoy your analysis ;)
% This function imports all columns of any presentation log file into
% MATLAB and names the variables to the column names used in the log file.
% The following columns are automaticaly converted to doubles:
% Trial, Time, TTime, Uncertainty, Duration, ReqTime, ReqDur
% The others however are strings.
% 
% To convert additional columns as doubles, add a list of column
% names (as displayed in the log file) as second argument in a cell.
%
% The data are represented as a vector of structs or a struct with vectors
% for every colum.
%
% Usage: [out1, out2] = presLog(fileName, columnsToBeConverted2Doubles);
% * INPUT
%       * filename  -> full qualified file name as string
%
% * OUTPUT
%       * out1      -> data represented as 1xn struct
%       * out2      -> struct that contains vectors for every column
%
% Example: [out1, out2] = presLog('resultFile.log');
%
% Example: [out1, out2] = presLog('resultFile.log', {'extraCol1', 'extraCol2'});
% Converts not only the standard columns to doubles but also the columns
% that are passed as extra argument

% Tobias Otto, tobias.otto@ruhr-uni-bochum.de
% 1.2
% 11.07.2012

% 21.09.2010, Tobias: first draft
% 02.02.2011, Tobias: added check for wrong header entries
% 11.07.2012, Tobias: added extraCol conversion, checking for duplicates in
%                     column names, speed optimization, 
%                     bugfix from Ben Cowley (thank you!)

%% Init variables
tmp         = [];
names       = {};
out1        = [];
out2        = [];
j           = 0;
dubCount    = 0;
convNames   = {'trial', 'Time', 'TTime', 'Uncertainty', 'Duration', ...
    'ReqTime', 'ReqDur'};   % Defines entries that are numeric and not a string
convNames   = lower(convNames);

%% Check input arguments
if(nargin == 2)
    if(~iscell(extraNames))
        disp(' *************************************************************');
        disp(' Please use cells to indicate the columns that have to be ');
        disp(' converted to doubles');
        disp(' E.g. ');
        disp(' [a, b] = presLog(''file.log'', {''column1'', ''coumn2''});');
        disp(' *************************************************************');
        error('Please solve error and try again');
    else
        for i=1:length(extraNames)
            extraNames{i}  = convertString(extraNames{i});
        end
        % Copy to cell that contains the "conversion names"
        convNames   = [convNames extraNames];
    end
end

%% Load file
fid = fopen(fileName,'r');
if(fid == -1)
    disp(' *************************************************************');
    disp(['The file ' fileName ' can''t be loaded']);
    disp(' *************************************************************');
    error('Please check the input file name and try again');
end

%% Read file
header{1} = fgetl(fid);
header{2} = fgetl(fid);
header{3} = fgetl(fid);

%% Get variable names
[numEntries, indexEntries, logLine] = sepHeader(fid);

for i = 1:numEntries
    tmp             = logLine(indexEntries(i):indexEntries(i+1));
    tmp             = convertString(tmp);
    
    % Check for duplicates
    for k=1:length(names)
        if(strcmpi(tmp, names{k}))
            rename      = tmp;
            dubCount    = dubCount + 1;
            tmp         = [tmp '_' num2str(dubCount)];
            disp([' --> Renamed "' rename '" to "' tmp '"']);
        end
    end
    
    % Finally copy entry to names
    names{i} = tmp;   % remove tab
end

% Remove white line
fgetl(fid);

%% Get entries by line
try
    while(ischar(logLine) && ~isempty(logLine))
        j = j+1;
        
        %% Separate values from line
        [numEntries, indexEntries, logLine] = sepEntries(fid);
        
        %% Copy entries to struct (for each line in file)
        for i=1:numEntries
            tmp = logLine(indexEntries(i):indexEntries(i+1));
            tmp = tmp(tmp~=9);  % Remove tab
            
            %% Check, entries in current line
            % Some lines have more entries than defined in header file
            % Warn user and ignore entry !!!
            if(length(names) < i)
                i = length(names);
                disp(' **********************************************************************');
                disp(' !!! The log file has more entries than defined in the header !!!');
                disp([' Skipping additional entries. Please check your log file in line ' num2str(j+5)]);
                disp(' **********************************************************************');
            end
            
            %% Check, if entry has to be converted to a double value
            % Compare entry with variable convNames: if entry exists save
            % as double. Otherwise as string
            k=1;
            while(k<=length(convNames) && ~strcmpi(convNames{k},names{i}))
                k=k+1;
            end
            
            %% Copy entries to struct
            if(k<=length(convNames))
                out1.(names{i})(j,:)    = str2double(tmp);
                out2(j).(names{i})      = out1.(names{i})(j,:);
            else
                % Copy to output struct
                out1.(names{i}){j,:}    = tmp;
                out2(j).(names{i})      = tmp;
            end
        end
    end
    
catch
    disp(' *************************************************************');
    disp([' Sorry I''m giving up on line ' num2str(j+5)]);
    disp(' This is a permanent error ... I give up :(');
    disp(' If you are able to find the error feel free to contact me');
    disp(' and I will add the changes.');
    disp(' *************************************************************');
end

%% Clean up
fclose(fid);


%% SUB FUNCTIONS
function [numEntries, indexEntries, logLine] = sepHeader(fid)
% Get header line
logLine         = fgetl(fid);
% Find valid separators
separators      = [find(double(logLine)==9) length(logLine)];
separators      = separators(diff(separators)~=1);
% Compute last variables
numEntries      = length(separators)+1;
indexEntries    = [1 separators length(logLine)];

function [numEntries, indexEntries, logLine] = sepEntries(fid)
% Get header line
logLine         = fgetl(fid);
% Find valid separators
separators      = find(double(logLine)==9);
% Compute last variables
numEntries      = length(separators)+1;
indexEntries    = [1 separators length(logLine)];

function out = convertString(in)
% Removes white line, (, ) and removed tab
in(in==32)	= '_';         	% Replace ' ', '(' , ')' with '_'
in(in==40)	= '_';        	% Replace ( with _
in(in==41) 	= '';       	% Replace ) with nothing
in         	= in(in~=9);  	% Remove tab
out     	= lower(in);    % Lower all character
