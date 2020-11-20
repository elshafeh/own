clear ;

list_modality       = {'vis','aud'};

goodsubjects{1}     = {};
goodsubjects{2}     = {};

for nmod = 1:2
    
    list_suj        = dir(['../data/sub*/preprocessed/*secondreject_postica*' list_modality{nmod} '*']);
    
    for ns = 1:length(list_suj)
        
        all_table       = [];
        nme_prts        = strsplit(list_suj(ns).name,'_');
        suj             = nme_prts{1};
        modality        = list_modality{nmod};
        
        excl_list       = {'sub016','sub004','sub009','sub018','sub019'};
        flg             = find(strcmp(suj,excl_list));
        
        if isempty(flg)
            
            block_correct                   = [];
            
            for ntype = {'expe'}
                
                add_bloc_no                 = 0;
                add_tria_no                 = 0;
                
                % this looping makes sure to load files in chronological order :)
                
                for rtype = {'run'}
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
                                
                                all_table               = [all_table;sub_table];
                                
                                all_trials              = sub_table.correct;
                                perc_correct            = sum(all_trials) / length(all_trials);
                                
                                block_correct           = [block_correct;perc_correct];
                                
                                clear sub_table all_trials perc_correct;
                                
                            end
                        end
                    end
                end
                
                lm_low                                  = 0.65;
                lm_high                                 = 0.85;
                
                perc_correct                            = mean(block_correct);
                clear block_correct;
                
                if (perc_correct >= lm_low) && (perc_correct <= lm_high)
                    goodsubjects{nmod}{end+1}           = suj;
                end
                
            end
            
            fprintf('\n');
            
        end
    end
end

clearvars -except goodsubjects list_modality;

system('rm ../misc_data/goodsubjects-*');

save(['../misc_data/goodsubjects-' date '.mat']);