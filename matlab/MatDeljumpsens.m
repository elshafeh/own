function [MEG_data_Corrected,v_LatencyJump,v_SensArtefacted] = MatDeljumpsens(MEG_data, s_fs, Threshold_jump, Duration2RemoveBefore,Duration2RemoveAfter)
%% function  [MEG_data_Corrected,v_LatencyJump,v_SensArtefacted] = MatDeljumpsens(MEG_data,s_fs, Threshold_jump, Duration2RemoveBefore,Duration2RemoveAfter)
% Threshold_jump : threshold of data amplitude jump
% Duration2RemoveBefore : duration (ms) before jump to set to zero
% Duration2RemoveAfter : duration (ms) after jump to set to zero
%


NbjumpTot = [];
NbSamp2RemoveBefore = fix(Duration2RemoveBefore * s_fs /1000); %120
NbSamp2RemoveAfter = fix(Duration2RemoveAfter * s_fs /1000);

NbSampRise = fix(10 *s_fs /1000); %12 ms Rise duration

TabjumpTOT = [];
MEG_data=MEG_data';
% h=waitbar(0,'Work in progress !!!');

for i_chan = 1:size(MEG_data,1)
    %     waitbar(i_chan/size(MEG_data,1),h)
    
    DATAtmp= MEG_data(i_chan,:);
    diffDATAtmp= DATAtmp(NbSampRise:end)-DATAtmp(1:end-NbSampRise+1);
    Tabjump=find(abs(diffDATAtmp) > Threshold_jump);
    Tabjump(find(diff(Tabjump)==1))=[];
    
    Nbjump = length(Tabjump);
    
    if (Nbjump)
        TabjumpTOT= [TabjumpTOT,Tabjump];
    end
    NbjumpTot = [NbjumpTot Nbjump];
    
    for i_jump=1:Nbjump+1
        if (i_jump-1)>0
            i_beg=min(Tabjump(i_jump-1) + NbSamp2RemoveAfter,size(MEG_data,2));
        else
            i_beg=1;
        end
        
        if (i_jump)<=Nbjump
            i_end=max(Tabjump(i_jump)-NbSamp2RemoveBefore,i_beg);
        else
            i_end=size(MEG_data,2);
        end
        
        meantmp = mean(DATAtmp(i_beg:i_end));
        DATAclean(i_beg:i_end) = DATAtmp(i_beg:i_end) -meantmp ;
        if (i_jump-1)>0
            DATAclean(i_beg:i_end) = DATAclean(i_beg:i_end) + LastSamp(i_jump-1) - DATAclean(i_beg);
        else
            DATAclean(i_beg:i_end) = DATAclean(i_beg:i_end)  - DATAclean(i_beg);
        end
        LastSamp(i_jump) = DATAclean(i_end);
        
        if i_jump<Nbjump+1
            DATAclean(max(1,Tabjump(i_jump)-NbSamp2RemoveBefore):min(Tabjump(i_jump)+NbSamp2RemoveAfter,size(MEG_data,2)))=LastSamp(i_jump);
        end
    end
    
    MEG_data_Corrected(i_chan,:)=DATAclean;
    
    
end

v_LatencyJump = unique(TabjumpTOT);

MEG_data_Corrected=MEG_data_Corrected';
NbSens = length(find(NbjumpTot));
v_SensArtefacted = find(NbjumpTot);
disp(['There is ' num2str(sum(NbjumpTot)) ' sensor jumps on ' num2str(NbSens) ' sensors in this file'])

% close(h)





