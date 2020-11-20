clear;

list_file                   = dir('/Volumes/Pat22Backup/heshamshung_backup/usb_stick_bup2/2Apr2019/LyonData/experiment_folders/behavioral_booth/PrepAtt_MEG21/PrepAtt_MEG21/Prog/Disc_Fix_*.txt');

dis_list                    = {};

for nf = 1:length(list_file)
    
    fname                   = [list_file(nf).folder filesep list_file(nf).name];
    trl_list                = import_preptxt(fname);
    
    tmp_list                = string(trl_list.DIS);
    
    for nd = 1:size(trl_list,1)
        xi                  = tmp_list(nd);
        
        dis_list{end+1}     = xi;
        
    end
    
end

dis_list                    = dis_list';

keep dis_list