clear; clc;

fname_in                        = '/Users/heshamelshafei/github/own/doc/bil.behavioralReport.summarised';
fname_out                    	= [fname_in '.4jasp'];

data_in                         = readtable([fname_in '.csv']);

data_out                        = {};
list_name                       = {};

suj_list                        = unique(data_in.suj);

list_cue                        = {'pre' 'retro'};
list_feat                       = {'Frequency' 'Orientation'};

for nsuj = 1:length(suj_list)
    
    i                           = 0;
    
    for ncue = 1:length(list_cue)
        for nfeat = 1:length(list_feat)
            
            flg                 = find(strcmp(data_in.suj,suj_list{nsuj}) & ...
                strcmp(data_in.cue_type,list_cue{ncue}) & ...
                strcmp(data_in.feat_attend,list_feat{nfeat}));
            
            i                   = i + 1;
            
            data_out{nsuj,i}    = data_in(flg,:).max_percent_;
            list_name{i}        = lower([list_cue{ncue}(1:3) '_' list_feat{nfeat}(1:3)]);
            
        end
    end
    
    
end

keep data_out list_name fname_out; clc; 

data_out                        = cell2table(data_out,'VariableNames',list_name);
writetable(data_out,[fname_out '.csv']);