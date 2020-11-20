function r_epmeasure(data,event,cond,window,varargin)
%data: 'eeg' or 'meg'
%event: 'dis', 'cue', 'target'
%cond: 'DIS1' for example
%window: n x 2 matrix with starts and ends of each ERP
%varargin1: extension of the file
%varargin2: sensor number

%By default, the average of the ERP will be calculated on the average of
%frontocentral electrodes (EEG) or the global field power (MEG)
addpath('/dycog/Aurelie/DATA/mat_prog/ELAN/erp');

load('../documents/list_all_suj.mat')
% list_all_suj = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
%     'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'  ...
%     'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
%     'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc21' 'yc16' 'yc18' 'yc4'};

Nsuj_badEEG  = sum(contains(list_all_suj,'yc9')) + sum(contains(list_all_suj,'fp3'));
Nsuj_badMEG  = sum(contains(list_all_suj,'fp3'));


if nargin == 4
    switch data
        case 'eeg'
            ext  = '.lb.avgelec.p';
            Nsuj = length(list_all_suj)-Nsuj_badEEG;  % minus fp3 and yc9 with no EEG -> number of exploitable subjects
        case 'meg'
            ext = '.lb.gfp.p';
            Nsuj = length(list_all_suj);
        otherwise
            disp('Enter eeg or meg')
    end
    fileOUT = ['../data/all/ERPmean_' data '_' cond '.csv'];
end

if nargin > 4    
    switch data
        case 'eeg'
            Nsuj = length(list_all_suj)-Nsuj_badEEG;  % minus fp3 and yc9 with no EEG -> number of exploitable subjects
        case 'meg'
            Nsuj = length(list_all_suj);
        otherwise
            disp('Enter eeg or meg')
    end
    ext = varargin{1};
    fileOUT = ['../data/all/ERPmean_' data '_' cond '_' ext '.csv'];
end

switch event  % orig is the time of the event onset (ms)
    case 'dis'
        orig = 1200;
    case 'target'
        orig = 1200;
    case 'cue'
        orig = 2400;
    otherwise
        disp('Enter cue, dis or target as events')
end

[Nerp,~] = size(window);      

suj_list = list_all_suj.';
ep_mean  = zeros(Nsuj,Nerp);

ERP_list = cell(1,Nerp);
grp_list = cell(Nsuj,1); 
new_suj_list = cell(Nsuj,1); 

for e = 1:Nerp
    
    start = window(e,1); 
    fin   = window(e,2);
    ERP_list{e} = ['from' num2str(start) 'to' num2str(fin)];
    
    i = 0;
    
    for sb = 1:length(suj_list)
        
        if ((strcmp(data,'eeg') && strcmp(suj_list(sb),'yc9')) + strcmp(suj_list(sb),'fp3'))~=0
                                   
        else
            
            i = i+1;
            filename      = ['../data/' suj_list{sb} '/erp/' data '/' event '/' suj_list{sb} '.pat22.' cond ext];
            [~,~,ep,~]    = readpem(filename);
            ep_mean(i,e)  = mean(ep(start+orig:fin+orig));
            
            grp_list{i}     = suj_list{sb}(1:2); %yc, oc, etc..
            new_suj_list{i} =  suj_list{sb};
            
        end
        
    end
    
end

ep_table    = array2table(ep_mean,'VariableNames',ERP_list);
group_table = array2table(grp_list,'VariableNames',{'Group'});
suj_table   = array2table(new_suj_list,'VariableNames',{'Subject'});

table       = [suj_table group_table ep_table];

writetable(table,fileOUT)
            
            