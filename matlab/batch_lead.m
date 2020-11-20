clear ;

[file,path]                                 = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

for nm = 1:length(list_modality)
    
    list_suj                                = goodsubjects{nm};    
    
    for ns = 1:length(list_suj)
        
        suj                                 = list_suj{ns};
        modality                            = list_modality{nm}; 
        
        chk                                 = dir(['../data/' suj '/mri/' suj '_segmentMRI.mat']);
        
        if ~isempty(chk)
            ade_sfn_create_VolGridLeadfield(suj,modality)
        end
        
    end
    
end