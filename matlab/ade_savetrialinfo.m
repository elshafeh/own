clear;

load P:/3015039.04/misc_data/goodsubjects-27-Nov-2019.mat

for nmodality = 1:length(list_modality)
    for nsubject = 1:length(goodsubjects{nmodality})
        
        suj_name                        = goodsubjects{nmodality}{nsubject};
        mod_name                        = list_modality{nmodality};
        
        fname                           = ['C:\Users\hesels\Dropbox\project_me\pjme_ade\data\preproc\' suj_name '.' mod_name '.40dwn.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        index                           = data.trialinfo;
        
        fname                           = ['C:\Users\hesels\Dropbox\project_me\pjme_ade\data\trialinfo\' suj_name '.' mod_name '.trialinfo.mat'];
        fprintf('save %s\n',fname);
        save(fname,'index');
        
        clear index data
        
    end
end
