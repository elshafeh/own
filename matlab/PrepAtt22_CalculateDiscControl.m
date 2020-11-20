clear ; clc ; 

[~,all_mix,~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = all_mix(2:73,2);
cod_list                    = all_mix(2:73,1);

[~,allsuj,~]                = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}                = allsuj(2:15,1);
suj_group{2}                = allsuj(2:15,2);
suj_group{3}                = allsuj(16:end,1);
suj_group{4}                = allsuj(16:end,2);

fOUT                        = '../documents/4R/PrepAtt22_Disc_Control.txt';
fid                         = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\n','GROUP','SUB','DISC_PERC');

for ngroup = 1:length(suj_group)
    for nsuj = 1:length(suj_group{ngroup})
        
        suj                 = suj_group{ngroup}{nsuj};
        ix_code             = find(strcmp(suj_list,suj));
        su_code             = lower(cod_list{ix_code});
        
        dir_data            = '/Volumes/JUDITH/Hesham/';
        
        file_list           = dir([dir_data su_code '*misc']);
        dir_data            = [dir_data file_list.name '/' su_code '/'];
        file_list           = dir([dir_data '/*_Disc_Control_*.txt']);
        
        if ~isempty(file_list)
            if length(file_list) == 1
                fname_in        = [dir_data file_list.name];
            else
                
                sub_file        = struct2cell(file_list);
                sub_file        = sub_file(1,:);
                sub_file        = cellfun(@(x) str2double(x(end-4)),sub_file,'UniformOutput',false);
                ix              = find(cell2mat(sub_file)==max(cell2mat(sub_file)));
                
                fname_in        = [dir_data file_list(ix).name];
            end
        else
            error('No file was found for %s !',suj);
        end
        
        disc_control        = import_disc_control(fname_in);
        perc_correct        = (length(disc_control(disc_control==1))/length(disc_control))*100;
        
        fprintf(fid,'%s\t%s\t%.2f\n',['gr' num2str(ngroup)],suj,perc_correct);
        
        clear disc_control perc_correct dir_data
        
    end
end

fclose(fid);