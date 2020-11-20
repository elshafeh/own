clear ;

[file,path]                                             = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

for nm = 1:length(list_modality)
    
    list_suj                                            = goodsubjects{nm};
    
    
    for ns = 1:length(list_suj)
        
        suj                                             = list_suj{ns};
        modality                                        = list_modality{nm};
        
        dir_data                                        = ['../data/' suj '/preprocessed/'];
        fname                                           = [dir_data suj '_secondreject_postica_' modality '.mat'];
        fprintf('loading %s \n',fname);
        load(fname);
        
        trialinfo                                       = secondreject_postica.trialinfo;
        
        fname                                           = [dir_data suj '_secondreject_postica_' modality '.trialinfo.mat'];
        fprintf('saving %s \n',fname);
        save(fname,'trialinfo');
        
        clear trialinfo;
        
    end
end