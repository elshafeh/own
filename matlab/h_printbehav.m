function info_table = h_printbehav(Info,suj,suj_modality,suj_manip,bloc_type,add_bloc_no,add_tria_no)

new_info    = [];
ix          = 0;

for nb = 1:length(Info.block)
    for nt = 1:length(Info.block(nb).trial)
        
        ix                                                  = ix + 1;
        bloc_info(nt).suj                                   = suj;
        bloc_info(nt).mod                                   = suj_modality;
        bloc_info(nt).design                                = suj_manip;
        bloc_info(nt).bloc_type                             = bloc_type;
        
        bloc_info(nt).bloc_size                             = length(Info.block(nb).trial)/2;
        
        if nb < 10
            bloc_info(nt).n_block                           = ['B0' num2str(nb+add_bloc_no)];
        else
            bloc_info(nt).n_block                           = ['B' num2str(nb+add_bloc_no)];
        end
        
        if nt < 10
            bloc_info(nt).n_trial_bloc                      = ['0' num2str(nt)];
        else
            bloc_info(nt).n_trial_bloc                      = num2str(nt);
        end
        
        ix_new                                              = ix+add_tria_no;
        
        if ix_new < 10
            bloc_info(nt).n_trial_tot                       = ['0' num2str(ix_new)];
        else
            bloc_info(nt).n_trial_tot                       = num2str(ix_new);
        end
        
        % --
        if Info.block(nb).trial(nt).side == 1
            bloc_info(nt).side                              = 'left';
        else
            bloc_info(nt).side                              = 'right';
        end
        
        % --
        if isfield(Info.block(nb).trial(nt),'correct')
            
            if Info.block(nb).trial(nt).correct == 1
                bloc_info(nt).correct    = 1;
            else
                bloc_info(nt).correct    = 0;
            end
            
        else
            
            if Info.block(nb).trial(nt).response == 1
                bloc_info(nt).correct    = 1;
                
            else
                bloc_info(nt).correct    = 0;
            end
            
        end
        
        bloc_info(nt).difference            = Info.block(nb).trial(nt).difference;
        bloc_info(nt).rt                    = Info.block(nb).trial(nt).RT * 1000;
        
        if isfield(Info.block(nb).trial(nt),'nois')
            
            if strcmp(bloc_type,'stair')
                bloc_info(nt).nois           = '1';
            else
                bloc_info(nt).nois           = num2str(Info.block(nb).trial(nt).nois+2);
                
                if Info.block(nb).trial(nt).nois == 0
                    bloc_info(nt).bloc_size  = 4;
                else
                    bloc_info(nt).bloc_size  = 20;
                end
                
            end
            
        else
            
            chk                                 = bloc_info(nt).bloc_type(1:4);
            
            if strcmp(chk,'expe')
                bloc_info(nt).nois               = '3';
            elseif strcmp(chk,'loca')
                bloc_info(nt).bloc_type          = 'expe';
                bloc_info(nt).nois               = '2';
            elseif strcmp(chk,'stai')
                bloc_info(nt).nois               = '1';
            end
            
        end
        
        if isfield(Info.block(nb).trial(nt),'confidence')
            if ~isempty(Info.block(nb).trial(nt).confidence)
                if Info.block(nb).trial(nt).confidence == 1
                    bloc_info(nt).confide    = 1;
                else
                    bloc_info(nt).confide    = 0;
                end
            else
                bloc_info(nt).confide    = 0;
            end
        else
            bloc_info(nt).confide    = 100;
        end
        
        bloc_info(nt).name_comb                 = [bloc_info(nt).nois bloc_info(nt).n_block];
        
        list_correct                            = {'incorrect','correct'};
        list_confide                            = {'unconfident','confident'};
        
        zi                                      = bloc_info(nt).correct+1;
        zo                                      = bloc_info(nt).confide+1;
        
        if zi < 3 && zo < 3
            
            bloc_info(nt).resp_type              = [list_confide{zo} '_' list_correct{zi}];
            bloc_info(nt).conf_type              = list_confide{zo};
            bloc_info(nt).corr_type              = list_correct{zi};
            
        else
            bloc_info(nt).resp_type              = 'undefined';
            bloc_info(nt).conf_type              = 'undefined';
            bloc_info(nt).corr_type              = 'undefined';
        end
        
    end
    
    new_info            = [new_info bloc_info]; clear bloc_info;
    
end

info_table              = struct2table(new_info);