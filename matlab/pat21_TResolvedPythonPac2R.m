clear ; clc ;

fOUT = '../R/doc/PrepAtt2_TensorPac.txt';
fid  = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','CUE','CHAN','TIME','PAC');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    list_cues    = {'NCnD','LCnD','RCnD'};
    list_method  = 'ndPAC';
    list_time    = {'m400m200','m200m0','p0p200','p200p400','p400p600','p600p800','p800p1000',...
        'p1000p1200','p1200p1400','p1400p1600','p1600p1800'};
    list_norm    = 'NoNorm';
    list_chan    = {'audL','audR','RIPS'};
    
    for xcue = 1:length(list_cues)
        
        allsuj_GA{sb,xcue}.avg                    = zeros(length(list_chan),length(list_time));
        allsuj_GA{sb,xcue}.time                   = -0.4:0.2:1.6;
        allsuj_GA{sb,xcue}.label                  = list_chan;
        allsuj_GA{sb,xcue}.dimord                 = 'chan_time';
        
        for xtime = 1:length(list_time)
            
            load(['../data/python_data/' suj '.' list_cues{xcue} '.' list_time{xtime} '.' list_method '.ShuAmp' '.' list_norm '.100perm.mat'])
            
            x1                                     = find(py_pac.vec_amp==58);
            x2                                     = find(py_pac.vec_amp==70);
            y1                                     = find(py_pac.vec_pha==9);
            y2                                     = find(py_pac.vec_pha==10);
            
            py_pac.xpac                            = squeeze(py_pac.xpac);
            py_pac.xpac                            = squeeze(mean(py_pac.xpac,3));
            py_pac.xpac                            = permute(py_pac.xpac,[3 1 2]);
            
            allsuj_GA{sb,xcue}.avg(:,xtime)         = mean(squeeze(mean(py_pac.xpac(:,x1:x2,y1:y2),3)),2);
            act                                     = allsuj_GA{sb,xcue}.avg(:,xtime);
            bsl                                     = allsuj_GA{sb,xcue}.avg(:,1);
            
            
            allsuj_GA{sb,xcue}.avg(:,xtime)         = act-bsl;
            
            for chan = 1:3
                fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',suj,list_cues{xcue},list_chan{chan},list_time{xtime},allsuj_GA{sb,xcue}.avg(chan,xtime));
            end
            
        end
        
    end
end

fclose(fid);
clearvars -except allsuj_GA list_*;