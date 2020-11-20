clear ; clc ; close ; dleiftrip_addpath ;

load ../data/yctot/postConnExtWav.mat

for sb = 1:size(allsuj,1)
    
    allsuj_post{sb,1} = allsuj{sb,3};
    allsuj_post{sb,2} = allsuj{sb,2};
    allsuj_post{sb,3} = allsuj{sb,1};
    allsuj_post{sb,4} = allsuj{sb,4};
    allsuj_post{sb,5} = allsuj{sb,5};
    
end

template_post = template ; 

clearvars -except template_post allsuj_post

load ../data/yctot/NewMotorExtWav.mat ; clear ext ; 

for sb = 1:14
    
    for cnd = 1:5
        
        new_allsuj{sb,cnd} = cat(1,allsuj_post{sb,cnd},allsuj{sb,cnd});
        
    end
    
end

new_template = template ; 
new_template.label = [template_post.label;new_template.label];

clearvars -except new*

allsuj = new_allsuj ; template = new_template ; clear new*

save ../data/yctot/postConn&NewMotorExtWav.mat