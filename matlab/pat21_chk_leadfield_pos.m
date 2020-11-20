% checks positions of leadfields

clear;clc;

suj_list = [1:4 8:17];

for s = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(s))];
    
    for p = 1:3
        
        load(['../data/' suj '/headfield/' suj '.pt' num2str(p) '.adjusted.leadfield.1cm.mat']);
        carr_pos{p} = leadfield.cfg.grad.chanpos ;% leadfield.cfg.grad.chanpos ; % leadfield.pos; % leadfield.cfg.grad.chanori
        clear leadfield ;
        
    end
    
    mtch = [1 2 ; 1 3; 2 3];
    
    for p = 1:size(mtch,1);
        
        if isequal(carr_pos{mtch(p,1)},carr_pos{mtch(p,2)})    
            fprintf('For %4s : Block %1d and Block %1d have the same position!\n',suj, mtch(p,1),mtch(p,2));
        end
        
    end
    
end