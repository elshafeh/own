clear ; clc ; 

new_list = {'C015';'C016';'C017';'C018';'C019';'C020';'C021';'C022';'C023';'C024';'C025';'C026';'C027';'C028'};

for sb = 1:length(new_list)
    
    old_dir = ['/dycog/anne/AVC/' new_list{sb}];
    new_dir = ['/dycog/anne/AVC/' new_list{sb} '/IRM/.'];
    
    mkdir(new_dir);
    
    ligne   = ['mv ' old_dir '/*_* ' new_dir];
    
    fprintf('%s\n',ligne);
    system(ligne);
    
end
