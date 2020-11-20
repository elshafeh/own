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
                fprintf('Loading %s\n',fname);
                
                template    = h_conn2freq(freq_con);
                
                data_mat    = freq_con.connspctrm;
                data_matZ   = .5.*log((1+data_mat)./(1-data_mat));
                
                tmp{ntime}  = data_matZ; clear data_matZ data_mat;
                
            end
            
            allsuj_data{sb,nmes,ncue}               = template;
            allsuj_data{sb,nmes,ncue}.powspctrm     = (tmp{2}-tmp{1}); clear tmp;
            
        end
        
        
        
    end
end

clearvars -except allsuj_data list_*;

fOUT = '../data/prep21_conn2R.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','SUB','MEASURE','CUE','NODE','FREQ','POW');

for sb = 1:size(allsuj_data,1)
    for nmes = 1:size(allsuj_data,2)
        for ncue = 1:size(allsuj_data,3)
            
            data    = allsuj_data{sb,nmes,ncue};
            
            for nchan = 1:length(data.label)
                for nfreq = [ 4 5 6 ]
                    
                    mtrx    = data.powspctrm(nchan,nfreq);
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.5f\n',['sb' num2str(sb)],list_measure{nmes},list_cue{ncue}, ...
                        data.label{nchan},[num2str(round(data.freq(nfreq))) 'Hz'],mtrx);
                    
                end
            end
            
        end
    end
end

fclose(fid);