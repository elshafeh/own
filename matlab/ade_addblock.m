clear;

load P:/3015039.04/misc_data/goodsubjects-27-Nov-2019.mat

for nmodality = 1:length(list_modality)
    for nsubject = 1:length(goodsubjects{nmodality})
        
        suj_name                        = goodsubjects{nmodality}{nsubject};
        mod_name                        = list_modality{nmodality};
        
        fname                           = ['C:\Users\hesels\Dropbox\project_me\pjme_ade\data\preproc\' suj_name '.' mod_name '.40dwn.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        load(['P:/3015039.04/data/' suj_name '/behav/' suj_name '_' mod_name '_block_info.mat'],'bloc_info')
        
        bloc_info                       = bloc_info(data.trialinfo(:,1),2);
        data.trialinfo                  = [data.trialinfo bloc_info];
        
        fprintf('saving %s\n',fname);
        save(fname,'data','-v7.3');
        
    end
end