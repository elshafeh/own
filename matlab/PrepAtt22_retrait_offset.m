clear ; clc ;

suj_list    = dir('/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/Sensor_Jumps/_old/') ;
addpath(genpath('../../../fieldtrip-20151124/'));

for sb = 1:length(suj_list)
    
    if length(suj_list(sb).name) > 2 && length(suj_list(sb).name) < 5
        
        ficorder            = '../../../par/template_offset_retrait.cfg';
        suj                 = suj_list(sb).name;
        
        load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
        
        fOUT                = ['../data/' suj '/res/' suj '.Offset.txt'];
        
        system(['cp ../data/empty.txt ' fOUT]);
        
        diary on
        
        diary(fOUT)
        
        direc_ds            = ['../data/' suj '/ds/'];
        
        cd(direc_ds)
        
        for nbloc = 1:length(final_ds_list)
            
            dirDsIn         = final_ds_list{nbloc,1}; %%% careful what index you put in !!!!
            nparts          = strsplit(dirDsIn,'.');
            
            if length(nparts) > 5
                dirDsOut        = [nparts{1} '.' nparts{2} '.' nparts{3} '.thirdOrder.' nparts{5} '.retraitOffset.' nparts{6}];
            else
                dirDsOut        = [nparts{1} '.' nparts{2} '.' nparts{3} '.thirdOrder.retraitOffset.' nparts{5}];
            end
            
            clear nparts
            
            final_ds_list{nbloc,2} = dirDsOut;
            
            %             if ~exist(dirDsOut)
            
            ligne_part1     = 'newDs -f -includeBadSegments -filter ';
            ligne_part2     = ficorder;
            ligne_part3     = [' '  dirDsIn ' ' dirDsOut];
            system([ligne_part1 ligne_part2 ligne_part3]);
            
            %             ligne_part1     = 'bash moveDs -f ';
            %             ligne_part2     = [' '  dirDsOut ' ' dirDsIn];
            %             system([ligne_part1 ligne_part2]);
            
            
            %             end
            
        end
        
        save(['../res/' suj '_final_ds_list.mat'],'final_ds_list');
        
        diary off
        cd('../../../scripts.m')
        
    end
end