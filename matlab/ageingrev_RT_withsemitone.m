clear ; clc ;

[~,allsuj,~]                    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
tar_list;

suj_group{2}                    = allsuj(2:15,1);
suj_group{1}                    = allsuj(2:15,2);

list_group                      = {'Young','Old'};

fOUT                            = '../../documents/4R/ageing_RT_esemi.txt';
fid                             = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','SEMI','MedianRT','PerIncorrect');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        
        fprintf('Handling %4s\n',suj);
        
        [all_rt,~,~,~,~,~,~,icorr]  =  h_behav_eval(suj,0:2,0:3,1:4);
        
        find_suj                    = find(strcmp(suj,list_name));
        find_semi                   = list_value(find_suj);
        
        if find_semi == 2
            semi_group              = 'standard';
        else
            semi_group              = 'adapted';
        end
        
        fprintf(fid,'%s\t%s\t%s\t%.2f\t%.2f\n',suj,list_group{ngroup},semi_group,all_rt,icorr);
        
        clear suj semi_group all_rt icorr
        
    end
end

fclose(fid);