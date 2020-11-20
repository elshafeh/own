clear ; clc ;

suj_list    = dir('../data/') ;
% suj_list.name = 'yc14';
% 
% suj_list    = dir('/dycog/Aurelie/DATA/MEG/PAT_EXPE22/check/Sensor_Jumps/old/');

thr_jump      = 10000;% 10000; % en femto-teslas
addpath(genpath('/mnt/autofs/Aurelie/DATA/MEG/fieldtrip-20151124/'));

for sb = 1:length(suj_list)
    
    if length(suj_list(sb).name) > 2 && length(suj_list(sb).name) < 5
        
        if ~strcmp(suj_list(sb).name,'fp3')
            
            suj                 = suj_list(sb).name;
            blocksArray         = PrepAtt22_funk_createDsBlocksCellArray(suj);
            
            fOUT                = ['../data/' suj '/res/' suj '.DsJumpLog.txt'];
            fid                 = fopen(fOUT,'a+');
            direc_ds            = ['../data/' suj '/ds/'];
            
            PrepAtt22_funk_check_hc(blocksArray,suj)
            
            for nbloc = 1:length(blocksArray)
                
                dirDsIn                                                                   = [direc_ds suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.ds'];
                dirDsOut                                                                  = [direc_ds suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.deljump.ds'];
                
                if exist(dirDsOut)
                    
                    fprintf('%Checking Sensor Jumps for %s\n',dirDsOut);
                    fprintf(fid,'%s\n',dirDsIn);
                    
                    [dirDsOut,v_LatencyJump,v_NameSensArtefacted]                         = dsdeljump2ds(dirDsIn,thr_jump, 200, 200); % badsegment sur une fenetre de large de 5sec en tout = dur??e d'un trial
                    
                    if ~isempty(v_LatencyJump)
                        
                        mkdir(['../check/Sensor_Jumps/' suj]);
                        
                        cfg                                                               = [];
                        cfg.dataset                                                       = dirDsIn;
                        cfg.channel                                                       = cellstr(v_NameSensArtefacted);
                        data_pre                                                          = ft_preprocessing(cfg);
                        cfg.dataset                                                       = dirDsOut;
                        data_post                                                         = ft_preprocessing(cfg);
                        
                        for x = 1:size(v_NameSensArtefacted,1)
                            fprintf(fid,'%s\t',v_NameSensArtefacted(x,:));
                        end
                        
                        fprintf(fid,'\n\n');
                        
                        for x = 1:length(v_LatencyJump)
                            fprintf(fid,'%.2f\t',v_LatencyJump(x));
                        end
                        
                        hihi = 0 ;
                        
                        for x = 1:length(v_LatencyJump)
                            
                            if x == 1 || (x>1 && ((v_LatencyJump(x)-v_LatencyJump(x-1)) > 5))
                                
                                hihi = hihi+1;
                                
                                lm1                                                               = find(round(data_post.time{1},4) == round(v_LatencyJump(x)-3,4));
                                lm2                                                               = find(round(data_post.time{1},4) == round(v_LatencyJump(x)+3,4));
                                
                                if isempty(lm1)
                                    lm1 = 1;
                                end
                                
                                figure;
                                subplot(2,1,1)
                                plot(data_pre.time{1}(lm1:lm2),data_pre.trial{1}(:,lm1:lm2));title([suj '.b' num2str(str2double(blocksArray{nbloc})) ' Jump no ' num2str(hihi) ' at ' num2str(v_LatencyJump(x)) ' sec before']);
                                xlim([data_pre.time{1}(lm1) data_pre.time{1}(lm2)])
                                subplot(2,1,2)
                                plot(data_post.time{1}(lm1:lm2),data_post.trial{1}(:,lm1:lm2));title([suj '.b' num2str(str2double(blocksArray{nbloc})) ' Jump no ' num2str(hihi) ' at ' num2str(v_LatencyJump(x)) ' sec before']);
                                xlim([data_post.time{1}(lm1) data_post.time{1}(lm2)])
                                
                                fnameout = ['../check/Sensor_Jumps/' suj '/' suj '.b' num2str(str2double(blocksArray{nbloc})) '.Jump.no.' num2str(hihi) '.png'];
                                saveas(gcf,fnameout);
                                close all;
                            end
                        end
                        
                        fprintf(fid,'\n\n');
                        
                    else
                        fprintf(fid,'%s\n\n','No Jumps!');
                    end
                    
                else
                    fprintf('%s already exists\n',dirDsOut);
                end
            end
            
            fclose(fid);
            
        end
    end
end