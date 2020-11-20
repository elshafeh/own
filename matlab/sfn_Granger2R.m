clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

list_measure    = {'cohimag','wpli_debiased'};
list_cue        = {'RCnD','LCnD','NCnD'};
list_time       = {'m600m200','p600p1000'};

for ncue = 1:length(list_cue)
    
    suj_list                                = [1:4 8:17] ;
    
    for sb = 1:length(suj_list)
        
        suj                                 = ['yc' num2str(suj_list(sb))] ;
        
        for ntime = 1:length(list_time)
            
            fname                           = ['../data/conn/' suj '.' list_cue{ncue} '.PaperAudVisTD.1t20Hz.m800p2000msCov.granger.' list_time{ntime} '.mat'];
            load(fname);
            fprintf('Loading %s\n',fname);
            
            freq                            = h_grang2freq(freq_con);
            
            data_mat                        = freq.powspctrm;
            data_matZ                       = .5.*log((1+data_mat)./(1-data_mat));
            
            tmp{ntime}                      = data_matZ; clear data_matZ data_mat;
            
        end
        
        allsuj_data{sb,ncue}                = freq; clear freq;
        allsuj_data{sb,ncue}.powspctrm      = (tmp{2}-tmp{1}); clear tmp;
        
    end
end

clearvars -except allsuj_data list_*;

fOUT = '../data/prep21_grangerZ2R.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','SUB','FREQ_CAT','CUE','NODE','FREQ','POW');

for sb = 1:size(allsuj_data,1)
    for ncue = 1:size(allsuj_data,2)
        
        data    = allsuj_data{sb,ncue};
        
        for nchan = 1:length(data.label)
            for nfreq = [7 8 9 11 12 13] % [8 9 10 12 13 14]
                
                mtrx    = data.powspctrm(nchan,nfreq);
                
                if nfreq < 11
                    freq_cat = 'low_freq';
                    freq_name   = ['0' num2str(data.freq(nfreq)) 'Hz'];
                else
                    freq_cat = 'high_freq';
                    freq_name   = [num2str(data.freq(nfreq)) 'Hz'];
                end
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.5f\n',['sb' num2str(sb)],freq_cat,list_cue{ncue}, ...
                    data.label{nchan},freq_name,mtrx);
                
            end
        end
        
    end
end

fclose(fid);