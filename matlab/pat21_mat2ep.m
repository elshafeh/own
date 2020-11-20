function n = mat2ep (p_file_name, s_Event_Code, s_fs, s_Nb_Sample_PreStim, v_Elec, s_Nb_Event_Aver, DATA)
%% function
% n = mat2ep (p_file_name, s_Event_Code, s_fs, s_Nb_Sample_PreStim, v_Elec, s_Nb_Event_Aver, DATA)
%
% Write *p file
% With
%       p_file_name             : Output *.p file name 
%       s_Event_Code            : Event code
%       s_fs                    : Sampling frequency (Hz)
%       s_Nb_Sample_PreStim     : Number of samples for prestimulus
%       v_Elec                  : Channel number in elec.dat
%       s_Nb_Event_Aver         : Number of averaged epochs
%       DATA                 : Data (1 channel per line, 1 sample per column)
%
%
%       n                       : Number of written float
% V01 Emmanuel Maby, le 23/10/2009
% V1.02 Pierre-Emmanuel Aguera, le 04/03/2010
% V1.03 09-08-2010 Pierre-Emmanuel Aguera : changes in variable names
%%



[f,err]=fopen(p_file_name,'w','b');

% File opening
%==================
if f==-1
    error(['pb avec ' p_file_name ' : ' err]);
end
n=0;

[s_Nb_Sample_per_Channel,s_Nb_Channels] = size(DATA);




v_HEADER2 = zeros((18+(5*s_Nb_Channels)),1);

v_HEADER2(1)                                                        = s_Nb_Channels;                        % Total number of channels
v_HEADER2(2)                                                        = s_Nb_Sample_per_Channel;              % Number of samples/channel
v_HEADER2(3)                                                        = s_Nb_Sample_per_Channel * 1000 /s_fs; % Time (ms)
v_HEADER2(4)                                                        = s_Nb_Sample_PreStim;                  % Number of samples for prestimulus
v_HEADER2(5)                                                        = 1000 /s_fs;                           % Sampling period (ms)
v_HEADER2(9)                                                        = min(DATA(:));                          % Minimum signal value (amplitude unit)
v_HEADER2(10)                                                       = max(DATA(:));                          % Maximum signal value (amplitude unit)
v_HEADER2(11:10+s_Nb_Channels)                                      = v_Elec;                              % Channel number in elec.dat
v_HEADER2(11+s_Nb_Channels : 10+(4*s_Nb_Channels))                  = 0;                                    % Triplets (r, theta, phi)
v_HEADER2(11+4*s_Nb_Channels)                                       = s_Nb_Event_Aver;                      % Number of averaged epochs
v_HEADER2(11+(4*s_Nb_Channels) + 1)                                 = 0;                                    % Number of inhibition samples for artefact rejection
v_HEADER2(11+(4*s_Nb_Channels) + 2)                                 = 0;                                    % Flag for the artefact rejection
v_HEADER2(11+(4*s_Nb_Channels) + 3)                                 = 0;                                    % Flag for the baseline correction (=0 no correction, other = event code used for the correction)
v_HEADER2(11+(4*s_Nb_Channels) + 4)                                 = -1;                                   % Amplifiers gain
v_HEADER2(11+(4*s_Nb_Channels) + 5)                                 = -1;                                   % Low cut frequency fot the amplifiers (Hz)
v_HEADER2(11+(4*s_Nb_Channels) + 6)                                 = -1;                                   % High cut frequency fot the amplifiers (Hz)
v_HEADER2(11+(4*s_Nb_Channels) + 7 : 10 + (5*s_Nb_Channels) + 7)    = 0;                                    % Baseline values for each channel



v_HEADER1    = zeros(6,1);
v_HEADER1(1) = -1;
v_HEADER1(2) = (18+(5*s_Nb_Channels))*4;
v_HEADER1(3) = s_Event_Code;





% v_HEADER1 Writing
%================
SZ=size(v_HEADER1)*4;
n=n+fwrite(f,SZ(1),'int32');
n=n+fwrite(f,v_HEADER1,'float');
n=n+fwrite(f,SZ(1),'int32');


% v_HEADER2 Writing
%================
SZ=size(v_HEADER2)*4;
n=n+fwrite(f,SZ(1),'int32');
n=n+fwrite(f,v_HEADER2,'float');
n=n+fwrite(f,SZ(1),'int32');



% DATA writing
%=================
SZ=4*size(DATA(:,1));
for v=1:v_HEADER2(1)    
    n=n+fwrite(f,SZ(1),'int32');
    n=n+fwrite(f,DATA(:,v),'float');
    n=n+fwrite(f,SZ(1),'int32');

end


fclose(f);



