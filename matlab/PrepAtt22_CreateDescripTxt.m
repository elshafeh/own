clear ; clc ;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_list        = [allsuj(2:end,1);allsuj(2:end,2)];

for sb = 1:length(suj_list)
    
    suj = suj_list{sb};
    
    dirMRI = dir(['../rawmri/' suj '/']);
    
    dirTxt = dir(['../rawmri/' suj '/descrip.txt']);
    
    %     if length(dirTxt) == 0
    
    lst_typ     = {'PA','AP'};
    lst_file    = {'_DTI_64DIR_TRA_b0_iso1.8_PA','_DTI_64DIR_TRA_b1000_iso1.8_AP'};
    
    system(['cp /dycog/anne/AVC/C001/IRM/descrip.txt ../rawmri/' suj '/.']);
    
    fOUT        = ['../rawmri/' suj '/descrip.txt'];
    fid         = fopen(fOUT,'W+');
    
    for n = 1:2
        
        dirFolder = dir(['../rawmri/' suj '/*' lst_file{n}]);
        
        if length(dirFolder) ==1
            fprintf(fid,'%s: %s\n',lst_typ{n},dirFolder.name);
        else
            error('Opps');
        end
        
        
    end
    
    fclose(fid);
    
    %     end
    
end
