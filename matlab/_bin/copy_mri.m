clear ; clc ;

suj_list = dir('../rawmri/');

% for n = 1:length(suj_list)
%     
%     if ~strcmp(suj_list(n).name(1),'.');
%         
%         suj = suj_list(n).name;
%         dir_list = dir(['../rawmri/' suj '/scans/']);
%         
%         if length(dir_list) > 1
%             
%             system(['mv ../rawmri/' suj '/scans/* ../rawmri/' suj '/.']);
%             system(['rm -r ../rawmri/' suj '/scans']);
%             
%         end
%         
%     end
%     
% end

for n = 1:length(suj_list)
    
    if ~strcmp(suj_list(n).name(1),'.');
        
        suj         = suj_list(n).name;
        dir_list    = dir(['../rawmri/' suj '/2*zip']);
        
        if length(dir_list) > 0
            
            fprintf('Copying Zip File for %s\n',suj);
            system(['mv ../rawmri/' suj '/*zip /media/hesham.elshafei/PAT_MEG2/backup_mri/' suj '_' dir_list(1).name]);
            
        end
        
    end
    
end