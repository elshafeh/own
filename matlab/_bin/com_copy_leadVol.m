clear ;

for ns = [1:4 8:17]
    
    fname_in                            = ['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/yc' num2str(ns) '.VolGrid.5mm.mat'];
    fname_out                           = ['/Volumes/h128ssd/alpha_compare/headfield/yc' num2str(ns) '.VolGrid.5mm.mat'];
    
    copyfile(fname_in,fname_out);
    
    for np = 1:3
        
        fname_in                        = ['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/yc' num2str(ns) '.pt' num2str(np) '.adjusted.leadfield.5mm.mat'];
        fname_out                       = ['/Volumes/h128ssd/alpha_compare/headfield/yc' num2str(ns) '.pt' num2str(np) '.adjusted.leadfield.5mm.mat'];
        
        copyfile(fname_in,fname_out);
        
    end
end