clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');


list_measure    = {'cohimag','wpli_debiased'};
list_cue        = {'RCnD','LCnD','NCnD'};
list_time       = {'m600m200','p600p1000'};

for nmes = 1:length(list_measure)
    for ncue = 1:length(list_cue)
        
        suj_list            = [1:4 8:17] ;
        
        for sb = 1:length(suj_list)
            
            suj             = ['yc' num2str(suj_list(sb))] ;
            
            for ntime = 1:length(list_time)
                
                fname       = ['../data/conn/' suj '.' list_cue{ncue} '.PaperAudVisTD.1t20Hz.m800p2000msCov.' list_measure{nmes} '.' list_time{ntime} '.mat'];
                load(fname);
                
                template    = freq_con;
                data_mat    = freq_con.connspctrm;
                data_matZ   = data_mat;% .5.*log((1+data_mat)./(1-data_mat));
                
                tmp{ntime}  = data_matZ; clear data_matZ data_mat;
                
            end
            
            sub_data(sb,:,:) = (tmp{2}-tmp{1}); clear tmp;
            
        end
        
        gavg_data{nmes,ncue}                = template;
        gavg_data{nmes,ncue}.cohspctrm      = squeeze(mean(sub_data,1)); clear sub_data;
        gavg_data{nmes,ncue}                = rmfield(gavg_data{nmes,ncue},'connspctrm');
        
    end
end

clearvars -except gavg_data;

