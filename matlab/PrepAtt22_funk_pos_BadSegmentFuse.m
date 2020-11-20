function posOUT = PrepAtt22_funk_pos_BadSegmentFuse(suj,pos_to_be_treated_in)

%temps entre le debut du fichier et le premier trigger qui lance
%l'acquisition (les badsegements sont indiqués par rapport à ce trigger)
    
posOUT = pos_to_be_treated_in;

if ~strcmp(suj,'fp3')
    
    start_ctf           = 0.1; %sec
    blocksArray         = PrepAtt22_funk_createDsBlocksCellArray(suj);
    badseg              = [0 0 0 0];
    
    for nbloc = 1:length(blocksArray)
        
        ds_after{1} = ['../data/' suj '/ds/' suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.ds'];
        
        if strcmp(suj,'fp3')
            ds_after{2}         = ['../data/' suj '/ds/' suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.ds'];
        else
            ds_after{2}         = ['../data/' suj '/ds/' suj '.pat2.b' num2str(str2double(blocksArray{nbloc})) '.thrid_order.deljump.ds'];
        end
        
        if ~exist([ds_after{2} '/dsheader.log'])
            ligne       =  (['dshead ' ds_after{2} ' > ' ds_after{2} '/dsheader.log']);
            system(ligne);
        end
        
        dur                       = ctf_dsheader(ds_after{2},'Duration');
        preDUR                    =(nbloc-1)*dur;
        
        for nprocess = 1:2
            
            fileID                      = [ds_after{nprocess} '/bad.segments'];
            tmp                         = load(fileID);
            
            if ~isempty(tmp)
                
                tmp                     =   floor((tmp(:,2:3)+preDUR+start_ctf) * 600);
                
                for n = 1:size(tmp,1)
                    
                    ii                      = find(badseg(:,1) == tmp(n,1));
                    jj                      = find(badseg(:,2) == tmp(n,2));
                    
                    if isempty(ii) && isempty(jj)
                        badseg = [badseg;tmp(n,:) nprocess+7 str2double(blocksArray{nbloc})];
                    end
                    
                end
                
                clear tmp
                
            end
        end
        
    end
    
    if size(badseg,1) > 1
        
        badseg   = badseg(2:end,:);
        
        blc_e_tte = unique(badseg(badseg(:,3)==8,4));
        blc_e_jmp = unique(badseg(badseg(:,3)==9,4));
        
        for jj = 1:length(blc_e_tte)
            fprintf('found tte rejection in b%s \n',num2str(blc_e_tte(jj)));
        end
        
        for ii = 1:length(blc_e_jmp)
            fprintf('found jump rejection in b%s \n',num2str(blc_e_jmp(ii)));
        end
        
        for n=1:size(badseg,1)
            posOUT(posOUT(:,1) >= badseg(n,1) & posOUT(:,1) <= badseg(n,2) & posOUT(:,3) ==0,3) = badseg(n,3);
        end
        
    end
    
    ii      = length(posOUT);
    posOUT  = PrepAtt22_funk_exclude_entire_trial(posOUT);
    jj      = length(posOUT);
    
    if ii ~= jj
        error(sprintf('CAREFUL !! Exclusion went wrong'))
    end
    
    
end
