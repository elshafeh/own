clear ;

for ns = [1:4 8:17]
    
    suj                         = ['yc' num2str(ns)];
    
    if strcmp(suj,'yc13')
        Ds_Name                 = ['/Volumes/PAT_MEG2/Fieldtripping/data/ds/' suj '.pat2.b2.ds'];
    else
        Ds_Name                 = ['/Volumes/PAT_MEG2/Fieldtripping/data/ds/' suj '.pat2.b1.ds'];
    end
    
    hdr                         = ft_read_header(Ds_Name); clear Ds_Name;
    
    fname                       = ['/Volumes/h128ssd/alpha_compare/grad/yc' num2str(ns) '.meg.header.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'hdr','-v7.3');
    
    clear hdr suj fname
    
end