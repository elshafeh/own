clear ; clc ;

fname_in            = '../documents/PrepAtt22_threshold_values.csv';
threshold_table     = readtable(fname_in);

patient_list;

suj_list            = [fp_list_meg cn_list_meg] ;

sens_table          = {};

for nsuj = 1:length(suj_list)
    
    suj                 = suj_list{nsuj};
    atten_value         = threshold_table(strcmp(threshold_table.SUB,suj),5);
    atten_value         = mean(table2array(atten_value));
    
    tar_sens_val        = 98 - (atten_value*100) + 25;
    dis_sens_val        = 78 - (atten_value*100) + 55;
    
    sens_table{nsuj,1}  = suj;
    sens_table{nsuj,2}  = atten_value;
    sens_table{nsuj,3}  = tar_sens_val;
    sens_table{nsuj,4}  = dis_sens_val;
    
end

clearvars -except threshold_table sens_table;