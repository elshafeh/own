% Behavioral data for R plots

clear ;

[file,path]                                 = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

all_table                                   = [];

for nm = 1:length(list_modality)
    
    list_suj                                = goodsubjects{nm};%dir('../data/sub*/preprocessed/*secondreject*');    
    
    for ns = 1:length(list_suj)
        
        %         nme_prts                  = strsplit(list_suj(ns).name,'_');
        suj                                 = list_suj{ns}; %nme_prts{1};
        modality                            = list_modality{nm}; %nme_prts{end}(1:3);
        
        fprintf('handling %s %s-modality\n',suj,modality);
        
        for ntype = {'stair','expe'}
            
            add_bloc_no              = 0;
            add_tria_no              = 0;
            
            % this looping makes sure to load files in chronological order :)
            
            for rtype = {'run','extra'}
                for nb = 1:9
                    
                    list_files               = dir(['../data/' suj '/behav/*' modality '*' ntype{:} '*' rtype{:} '*' num2str(nb) '*Logfile.mat']);
                    
                    if ~isempty(list_files)
                        
                        % avoid loading training
                        fname                    = [list_files(1).folder '/' list_files(1).name];
                        chk                      = strfind(fname,'train');
                        
                        if isempty(chk)
                            
                            fprintf('Loading %s\n',fname);
                            load(fname);
                            
                            name_parts              = strsplit(list_files(1).name,'_');
                            bloc_type               = name_parts{3}; clear name_parts;
                            
                            sub_table               = h_printbehav(Info,suj,modality, ...
                                'meg',bloc_type,add_bloc_no,add_tria_no);
                            
                            add_bloc_no             = add_bloc_no+length(Info.block);
                            add_tria_no             = str2double(sub_table.n_trial_tot{end});
                            
                            all_table               = [all_table;sub_table]; clear sub_table;
                            
                        end
                    end
                end
            end
            
            fprintf('\n');
            
        end
    end
    
    clearvars -except all_table list_modality goodsubjects nm;
    
end

writetable(all_table,'../docs/4R/ade_meg2R_summary.txt');