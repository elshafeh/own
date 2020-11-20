clear ; clc ;

cnd = {'L','R','N'};

suj_list = [1:4 8:17] ;

fOUT = '/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.field/txt/PrepAtt2_Final_CnD_Count_per_target.txt';

fid  = fopen(fOUT,'W');

fprintf(fid,'%4s\t%3s\t%3s\t%3s\n','SUB','NCnD','LCnD','RCnD');

trl_cnt = [];

for a = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(a))] ;
    
    fprintf(fid,'%4s\t',suj);
    
    posIN = load(['/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.pos']);
    
    posIN = posIN(posIN(:,3) == 0,:) ;
    posIN = posIN(floor(posIN(:,2)/1000) ==1,2);
    
    posIN      = posIN - 1000 ;
    posIN(:,2) = floor(posIN(:,1)/100);
    posIN(:,3) = floor((posIN(:,1) - posIN(:,2)*100)/10);
    posIN = posIN(posIN(:,3) == 0,:);
    
    posIN(:,4) = floor(mod(posIN(:,1),10));
    
    ntrl{1} = length(posIN(posIN(:,2) == 1));
    ntrl{2} = length(posIN(posIN(:,2) == 2));
    
    ntrl{3} = length(posIN(posIN(:,2) == 0 & mod(posIN(:,4),2) ~=0));
    ntrl{4} = length(posIN(posIN(:,2) == 0 & mod(posIN(:,4),2) ==0));
    
    for b=1:4
        fprintf(fid,'%3d\t',ntrl{b});
        trl_cnt(a,b) = ntrl{b};
    end
    
    clear ntrl;
    
    fprintf(fid,'\n');
    
end

fclose(fid);

clearvars -except trl_cnt

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
