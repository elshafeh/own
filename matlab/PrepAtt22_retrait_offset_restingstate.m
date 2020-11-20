clear ; clc ;

suj_list = struct('name',{ ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg17' 'mg18' 'mg19' ...
    'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'});

addpath(genpath('../../../fieldtrip-20151124/'));

for sb = 1:length(suj_list)
    
    if length(suj_list(sb).name) > 2 && length(suj_list(sb).name) < 5
        
        ficorder            = '../../../par/template_offset_retrait.cfg';
        suj                 = suj_list(sb).name;
        
        % load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
        final_ds_list    = cell(1,2);
        final_ds_list{1} = [suj '.pat2.restingstate.thrid_order.deljump.ds'];
        final_ds_list{2} = [suj '.pat2.restingstate.thrid_order.deljump.retraitOffset.ds'];
        
        fOUT                = ['../data/' suj '/res/' suj '.Offset.txt'];
        
        system(['cp ../data/empty.txt ' fOUT]);
        
        diary on
        
        diary(fOUT)
        
        direc_ds            = ['../data/' suj '/ds/'];
        
        cd(direc_ds)
        
        dirDsIn = final_ds_list{1};  dirDsOut = final_ds_list{2};
        
        ligne_part1     = 'newDs -f -includeBadSegments -filter ';
        ligne_part2     = ficorder;
        ligne_part3     = [' '  dirDsIn ' ' dirDsOut];
        system([ligne_part1 ligne_part2 ligne_part3]);
        
        %             ligne_part1     = 'bash moveDs -f ';
        %             ligne_part2     = [' '  dirDsOut ' ' dirDsIn];
        %             system([ligne_part1 ligne_part2]);
        
        
        %             end
        
        
        save(['../res/' suj '_final_ds_list_restingstate.mat'],'final_ds_list');
        
        diary off
        cd('../../../scripts.m')
        
    end
end