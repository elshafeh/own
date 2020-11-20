clear ; clc ;
addpath(genpath('/mnt/autofs/Aurelie/DATA/MEG/fieldtrip-20151124/'));

suj_list        = dir('/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/Sensor_Jumps/_old/') ;

sens_jump_list  = readtable('../documents/PrepAtt22_SensorJumps.xlsx');
sens_jump_list  = sens_jump_list(sens_jump_list.real~=1,:);
i               = 0;

for sb = 1:length(suj_list)
    
    if length(suj_list(sb).name) > 2 && length(suj_list(sb).name) < 5
        
        i               = i + 1;
        suj             = suj_list(sb).name;
        blocksArray     = PrepAtt22_funk_createDsBlocksCellArray(suj);
        
        fOUT            = ['../data/' suj '/res/' suj '.PostSensJumpBlocCount.txt'];
        fid             = fopen(fOUT,'W+');
        fprintf('Handling %4s\n',suj);
        
        bloc_summary    = {};
        
        for nbloc = 1:length(blocksArray)
            
            if strcmp(suj,'fp3')
                ext_ds = '.ds';
            else
                
                flag1 = sens_jump_list(strcmp(suj,sens_jump_list.subject) & strcmp(['b' num2str(str2double(blocksArray{nbloc}))],sens_jump_list.block),:);
                
                if size(flag1,1) ~= 0
                    ext_ds = '.ds';
                else
                    ext_ds = '.deljump.ds';
                end
                
            end
            
            dsName                  = ['../data/' suj '/ds/' suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order' ext_ds];
            bloc_summary{nbloc,1}   = [suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order' ext_ds];
            posnameout              = ['../data/' suj '/pos/' suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order' ext_ds '.code.pos'];
            
            if ~exist(posnameout)
                
                posIN       = ft_read_event(dsName);
                allCodes    = [];
                allSamples  = [];
                
                for h  =1:length(posIN)
                    if strcmp(posIN(h).type,'UPPT001')
                        if ~isempty(posIN(h).value)
                            if ~isempty(posIN(h).sample)
                                allCodes    = [allCodes ;posIN(h).value];
                                allSamples  = [allSamples ;posIN(h).sample];
                            end
                        end
                    end
                end
                
                posIN = [allSamples allCodes];
                dlmwrite(posnameout,posIN,'Delimiter','\t' ,'precision','%10d'); clear allSamples allCodes ;
                
            else
                posIN = load(posnameout);
            end
            
            if ~isempty(posIN)
                posIN           = posIN(:,2);
                if length(posIN) < 3 && unique(posIN) == 253
                    ntrl = 0;
                else
                    posIN       = posIN((posIN >= 1 & posIN <= 24) | (posIN >= 101 & posIN <= 123) | (posIN >= 202 & posIN <= 224));
                    ntrl        = length(posIN);
                end
            else
                ntrl = NaN;
            end
            
            bloc_summary{nbloc,2} = ntrl ;
            
        end
        
        bloc_summary            = array2table(bloc_summary,'VariableNames',{'DsName','Ntrial'});
        writetable(bloc_summary,['../data/' suj '/res/' suj '.PostSensJumpBlocCount.txt'],'Delimiter',' ')
        
        ix                      = cell2mat(bloc_summary.Ntrial);
        final_ds_list           = table2array(bloc_summary(find(~isnan(ix) & ix>0),1));
        
        save(['../data/' suj '/res/' suj '_final_ds_list.mat'],'final_ds_list');
        
        allsuj_summary{i,1}     = suj;
        allsuj_summary{i,2}     = length(find(ix==64));
        allsuj_summary{i,3}     = length(find(ix>0 & ix<64));
        allsuj_summary{i,4}     = length(find(ix== 0));
        allsuj_summary{i,5}     = length(find(isnan(ix)));
        allsuj_summary{i,6}     = length(final_ds_list);
        
        clear final_ds_list bloc_summary final_ds_list ix
        
    end
end

allsuj_summary            = array2table(allsuj_summary,'VariableNames',{'suj','NGood','NBad','NRest','NEmpty','NFinal'});
writetable(allsuj_summary,'../documents/sens_pickup_PostSensJumpBlocCount.csv','Delimiter',';')