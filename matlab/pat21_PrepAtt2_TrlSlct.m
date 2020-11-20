clear ; clc ;

cnd = {'L','R','N'};

suj_list = [1:4 8:17] ;

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))] ;
    
    for b = 1:length(cnd)
        
        trl = [] ;
        
        for c = 1:3
            
            fprintf('Loading %8s\n',[suj '.' cnd{b} 'CnD.pt' num2str(c)]);
            
            load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/data/' suj '/elan/' suj '.pat2.' cnd{b} 'CnD.pt' num2str(c) '.mat']);
        
            chk{c} = length(data_elan.trial) ;
            
            trl = [trl (1:size(data_elan.trial,2)) + 1000*c];
            
            clear data_elan
            
        end
        
        trl_array = PrepAtt2_fun_create_rand_array(length(trl),174);

        trl_array = trl(trl_array);
        
        clear trl
        
        trl_count{a,b,1} = []; trl_count{a,b,2} = []; trl_count{a,b,3} = [];
        
        for n = 1:length(trl_array)
           
            idx = floor(trl_array(n)/1000) ;
            
            trl_count{a,b,idx} = [trl_count{a,b,idx};trl_array(n) - 1000*idx];    
            
        end
        
        for x = 1:3
            
            flag = find(trl_count{a,b,x} > chk{x});
            
            if ~isempty(flag)
                fprintf('\Trouble With %30s',[suj cnd{b} 'CnD.pt' num2str(x)]);
            end
            
        end
        
    end
    
end

clearvars -except trl_count

save('trl_slct_array_lat.mat','trl_count');

% clear ; clc ;
%
% for c = {'L','R','N'}
%
%     fOUT = ['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/txt/PrepAtt2_' c{:} 'CnD_Trials.txt'];
%
%     fid  = fopen(fOUT,'W');
%
%     fprintf(fid,'%4s\t%3s\t%3s\t%3s\n','SUB','Pt1','Pt2','Pt3');
%
%     for s = [1:4 8:17]
%
%         suj = ['yc' num2str(s)] ;
%
%         fprintf(fid,'%4s\t',suj);
%
%         for p = 1:3
%
%             fprintf('Loading %8s\n',[suj '.pt' num2str(p)]);
%
%             load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/data/' suj '/elan/' suj '.pat2.' c{:} 'CnD.pt' num2str(p) '.mat']);
%
%             fprintf(fid,'%3d\t',size(data_elan.trial,2));
%
%         end
%
%         fprintf(fid,'\n');
%
%     end
%
%     fclose(fid);
%
% end
