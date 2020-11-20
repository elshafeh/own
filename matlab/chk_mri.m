clear 

sona_id_list = {'132535','123073','138295','148636','150961','144970','150184'};

for ns = 1:length(sona_id_list)
    
    mri_dir         = ['/home/common/anatomical_mri/' sona_id_list{ns}];
    mri_chk       = dir(mri_dir);
    
    if ~isempty(mri_chk)
        fprintf('%s\n',mri_dir);
    end
    
end