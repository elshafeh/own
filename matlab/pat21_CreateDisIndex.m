clear ; clc ;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(sb))];
    bigSampleInfo           = [];
    bigTrialInfo            = [];
    
    for pt = 1:3
        
        fname_in = [suj '.pt' num2str(pt) '.fDIS'];
        fprintf('Loading %50s\n',fname_in);
        load(['../data/elan/' fname_in '.mat'])
        
        bigSampleInfo           = [bigSampleInfo;data_elan.sampleinfo];
        bigTrialInfo            = [bigTrialInfo;data_elan.trialinfo];
        
    end
    
    lock                    = 6 ; 
    bigTrialInfo(:,2)       = bigTrialInfo(:,1) - ((floor(bigTrialInfo(:,1)/1000))*1000);
    bigTrialInfo(:,3)       = floor(bigTrialInfo(:,2)/100);
    bigTrialInfo(:,4)       = floor((bigTrialInfo(:,2)-100*bigTrialInfo(:,3))/10);
    
    posIN                   =   load(['/Volumes/PAT_MEG2/Fieldtripping/data/pos/' suj '.pat2.fin.fDisMirror.pos']);
    posIN                   =   posIN(posIN(:,3) == 0,1:2);
    posIN(:,3)              =   posIN(:,2) - ((floor(posIN(:,2)/1000))*1000);
    posIN(:,4)              =   floor(posIN(:,3)/100);
    posIN(:,5)              =   floor((posIN(:,3)-100*posIN(:,4))/10);
    
    rt_order{sb} = [];
    
    for n = 1:length(bigSampleInfo)
        
        flag_trl    = bigSampleInfo(n,1) + 600*abs(data_elan.time{1}(1));
        flag_pos    = find(posIN(:,1)==flag_trl);
        
        tar_pos     = flag_pos+1;
        rep_pos     = flag_pos+2;
        
        if posIN(flag_pos,3) ~= bigTrialInfo(n,2) || floor(posIN(flag_pos,2)/1000) ~= lock || isempty(flag_pos) || floor(posIN(tar_pos,2)/1000) ~= 3 || floor(posIN(rep_pos,2)/1000)~= 9
            error('Something Is not Right Here..')
        else
            rt_trial            = posIN(rep_pos,1) - posIN(tar_pos,1) ;
            rt_trial            = rt_trial * 5/3 ;
            rt_order{sb}    = [rt_order{sb};rt_trial];
            
            clear rt_trial flag_trl flag_pos
            
        end
        
    end
    
    if length(rt_order{sb}) ~= length(bigTrialInfo)
        error('Inconsistent N. of Trials')
    end
    
end

clearvars -except rt_order; save ../data/yctot/rt/rt_fdis_ordered.mat ;