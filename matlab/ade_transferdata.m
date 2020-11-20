clear;

fieldtrip_path  = 'H:\common\matlab\fieldtrip';
addpath(fieldtrip_path); 
ft_defaults; clear fieldtrip_path;

load P:/3015039.04/misc_data/goodsubjects-27-Nov-2019.mat

for nmodality = 1:length(list_modality)
    for nsubject = 1:length(goodsubjects{nmodality})
        
        suj_name                        = goodsubjects{nmodality}{nsubject};
        mod_name                        = list_modality{nmodality};
        
        fname                           = ['P:/3015039.04/data/' suj_name '/preprocessed/' suj_name '_secondreject_postica_' mod_name '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        cfg                             = [];
        cfg.resamplefs                  = 40;
        cfg.detrend                     = 'no';
        cfg.demean                      = 'no';
        data                            = ft_resampledata(cfg, secondreject_postica);
        data                            = rmfield(data,'cfg');
        
        fname                           = ['C:\Users\hesels\Dropbox\project_me\pjme_ade\data\preproc\' suj_name '.' mod_name '.40dwn.mat'];
        fprintf('saving %s\n',fname);
        save(fname,'data','-v7.3');
        
    end
end