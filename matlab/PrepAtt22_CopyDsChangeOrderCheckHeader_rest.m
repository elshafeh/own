clear ; clc ;

suj_list  = dir('../rawdata/') ;


for sb = 20 %1:length(suj_list)
    
    if length(suj_list(sb).name) > 2 && length(suj_list(sb).name) < 5
        
        suj                 = suj_list(sb).name;
        blocksArray         = PrepAtt22_funk_createDsBlocksCellArray(suj);
        
        direc_raw           = ['../rawdata/' suj '/'];
        direc_ds            = ['../data/' suj '/ds/'];
        ds_ext              = dir([direc_raw '*ds']);
        ds_ext              = ds_ext(1).name(1:end-5);
        
        i                   = 0;
        
        nbloc = length(blocksArray); %the last block is resting state
        
        dir_raw_ds =  [direc_raw ds_ext blocksArray{nbloc} '.ds'];
        dir_cop_ds =  [direc_ds suj '.pat2.restingstate.ds'];
        dir_trd_ds =  [direc_ds suj '.pat2.restingstate.thrid_order.ds'];
        
        %copy ds
        
        ligne   = ['bash copyDs -f ' dir_raw_ds ' ' dir_cop_ds];
        
        if ~exist(dir_trd_ds)
            
            fprintf('Copying %s to %s\n',dir_raw_ds,dir_cop_ds);
            system(ligne)
            
            % read header
            
            if ~exist([dir_cop_ds '/dsheader.log'])
                ligne       =  (['dshead ' dir_cop_ds ' > ' dir_cop_ds '/dsheader.log']);
                fprintf('Checking header file of %s\n',dir_cop_ds);
                system(ligne);
            end
            
            i = i + 1;
            
            headerResults                   =   struct();
            headerResults(i).old_SUBJECT    =   suj;
            headerResults(i).old_DS_NAME    =   dir_cop_ds;
            headerResults(i).old_DURATION   =   ctf_dsheader(dir_cop_ds,'Duration');
            headerResults(i).old_CHANNELS   =   ctf_dsheader(dir_cop_ds,'Channels');
            headerResults(i).old_GRADIENT   =   ctf_dsheader(dir_cop_ds,'File Gradient');
            headerResults(i).old_SAMPLES    =   ctf_dsheader(dir_cop_ds,'Samples');
            headerResults(i).old_RATE       =   ctf_dsheader(dir_cop_ds,'Rate');
            
            % change order
            
            cfgFileIn   = '../par/template_third_order_processing.cfg';
            ligne       = ['newDs -filter ' cfgFileIn ' ' dir_cop_ds ' ' dir_trd_ds];
            system(ligne);
            
            if ~exist([dir_trd_ds '/dsheader.log'])
                ligne       =  (['dshead ' dir_trd_ds ' > ' dir_trd_ds '/dsheader.log']);
                fprintf('Checking header file of %s\n',dir_trd_ds);
                system(ligne);
            end
            
            headerResults(i).new_SUBJECT    =   suj;
            headerResults(i).new_DS_NAME    =   dir_trd_ds;
            headerResults(i).new_DURATION   =   ctf_dsheader(dir_trd_ds,'Duration');
            headerResults(i).new_CHANNELS   =   ctf_dsheader(dir_trd_ds,'Channels');
            headerResults(i).new_GRADIENT   =   ctf_dsheader(dir_trd_ds,'File Gradient');
            headerResults(i).new_SAMPLES    =   ctf_dsheader(dir_trd_ds,'Samples');
            headerResults(i).new_RATE       =   ctf_dsheader(dir_trd_ds,'Rate');
            
            headerResults(i).diff_DURATION   =   headerResults(i).new_DURATION - headerResults(i).old_DURATION;
            headerResults(i).diff_CHANNELS   =   headerResults(i).new_CHANNELS - headerResults(i).old_CHANNELS;
            headerResults(i).diff_GRADIENT   =   headerResults(i).new_GRADIENT - headerResults(i).old_GRADIENT;
            headerResults(i).diff_SAMPLES    =   headerResults(i).new_SAMPLES - headerResults(i).old_SAMPLES;
            headerResults(i).diff_RATE       =   headerResults(i).new_RATE - headerResults(i).old_RATE;
            
            system(['rm -r ' dir_cop_ds]);
            
        end        
        
        headerResults  = struct2table(headerResults);
        writetable(headerResults,['../data/' suj '/res/' suj '.header.before.after.restingstate.csv']);
        
        clearvars -except suj_list sb
        
    end
 end