clear ; clc ;

[~,suj_list,~]                          = xlsread('/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                                = suj_list(2:73);

threshold_table                         = {};
i                                       = 0 ;

for sb = 1:length(suj_list)
    
    suj                                 = suj_list{sb};
    
    
    % for users of experiments (other than PAT_EXPE22) you should
    % adjust this line
    
    fname_in                            = ls(['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/rawdata/' suj '/*.misc/*/*_thresholds.txt']);
    fname_in                            = fname_in(~isspace(fname_in));
    
    fid                                 = fopen(fname_in);
    wh_txt                              = fgetl(fid);
    
    while ischar(wh_txt)
        
        tline                           = fgetl(fid);
        ix                              = [];
        
        if ischar(tline)
            lparts                      = strsplit(tline,'\t');
            ix                          = strfind(lparts{1},'tarson');
            
            if ~isempty(ix)
                
                i                       = i + 1;
                threshold_table{i,1}    = suj;
                threshold_table{i,2}    = lparts{1};
                threshold_table{i,3}    = ['spkr' lparts{2}];
                threshold_table{i,4}    = str2double(lparts{3});
                threshold_table{i,5}    = str2double(lparts{4});
                
            end
        else
            break;
        end
    end
    
    fclose(fid);
    
end

clearvars -except threshold_table ;

threshold_table = array2table(threshold_table,'VariableNames',{'SUB','SOUND','SPEAKER','VOLUME','ATTENUATION'});
fname_out       = '../documents/PrepAtt22_threshold_values.csv';
writetable(threshold_table,fname_out);

suj_list        = unique(threshold_table.SUB);
sens_table      = {};

for nsuj = 1:length(suj_list)
   
    suj                 = suj_list{nsuj};
    atten_value         = threshold_table(strcmp(threshold_table.SUB,suj),5);
    atten_value         = mean(cell2mat(table2array(atten_value)));
    
    tar_sens_val        = 98 - (atten_value*100) + 25;
    dis_sens_val        = 78 - (atten_value*100) + 55;
    
    sens_table{nsuj,1}  = suj;
    sens_table{nsuj,2}  = atten_value;
    sens_table{nsuj,3}  = tar_sens_val;
    sens_table{nsuj,4}  = dis_sens_val;
    
end

clearvars -except threshold_table sens_table;

sens_table      = array2table(sens_table,'VariableNames',{'SUB','Threshold','Target_level','Distracor_level'});
fname_out       = '/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/documents/PrepAtt22_sensation_values.csv';
writetable(sens_table,fname_out);