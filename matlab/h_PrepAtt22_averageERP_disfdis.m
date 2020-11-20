clear ; clc ; close all;

[~,allsuj,~]  = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');
suj_group{1}    = allsuj(2:end,1);
suj_group{2}    = allsuj(2:end,2);
lst_group       = {'oc_n11','yc_n11'};

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% lst_group       = {'oc','yc'};

load ../documents/event.mat; %structure 'event'

event_names = fieldnames(event);

for ngroup = 1:length(suj_group)
    
    for data = {'meg','eeg'}
        
        for ev = 4;
            
            event_list = getfield(event, event_names{ev});
            
            mkdir(['../data/' lst_group{ngroup} '/erp/' data{:} '/dis-fdis']);
            
            for cat = 1:length(event_list)
                
                for ext_bsl = {'.dis-fdis','.lb.dis-fdis'}
                    
                    %                     if exist(['../data/' suj_group{ngroup}{1} '/erp/' data{:} '/dis-fdis/' suj_group{ngroup}{1} '.pat22.' event_list{cat} ext_bsl{:} '.p'])
                    
                    cd(['../data/' lst_group{ngroup} '/erp/' data{:} '/dis-fdis'])
                    
                    system(['rm ' lst_group{ngroup} '.pat22.' event_list{cat}  ext_bsl{:} '.p']);
                    system('rm ERP.list');
                    
                    FicName     = 'ERP.list';
                    fid         = fopen(FicName,'w+');
                    
                    epfileOUT   = [lst_group{ngroup} '.pat22.' event_list{cat} ext_bsl{:}];
                    
                    fprintf(fid,'%s\n\n',epfileOUT);
                    
                    for sb = 1:length(suj_group{ngroup})
                        
                        suj      = suj_group{ngroup}{sb};
                        epfileIN = [ '../../../../' suj '/erp/' data{:} '/dis-fdis/' suj '.pat22.' event_list{cat} ext_bsl{:}];
                        fprintf(fid,'%s\n',epfileIN);
                        
                    end
                    
                    fprintf(fid,'%s\n\n','');
                    fprintf(fid,'%s','!');
                    fclose(fid);
                    
                    ligne = 'epavg <ERP.list';
                    system(ligne);
                    system('rm ERP.list');
                    
                    cd ../../../../../scripts.m
                    
                    %                     end
                end
            end
        end
    end
end