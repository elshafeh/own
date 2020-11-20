clear ;

[file,path]                                 = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

for nm = 1:length(list_modality)
    
    list_suj                                = goodsubjects{nm};    
    
    for ns = 1:length(list_suj)
        
        suj                                 = list_suj{ns};
        modality                            = list_modality{nm};
        
        %         list_chk{1}                         = ['../data/' suj '/mri/' suj '_segmentMRI.mat'];
        %         list_chk{2}                         = ['../data/' suj '/mri/' suj '_gridVol.mat'];
        list_chk{1}                         = ['../data/' suj '/mri/' suj '_' modality '_leadfield.mat'];
        
        for i = 1:length(list_chk)
            
            chk                             = dir(list_chk{i});
            
            if isempty(chk)
                ade_sfn_create_VolGridLeadfield(suj,modality);
            end
            
        end
    end
    
end