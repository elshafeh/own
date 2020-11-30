MigPrdmTable;

cnd_cue={'NC','LC','RC'};
cnd_dis={'D0','D1','D2','D3'};
cnd_tar={'LLo','RLo','LHi','RHi'};

cnd=0;

cnd_list=[];

for c=1:3
    for d=1:3
        for t=1:4
            
            if (strcmp(cnd_cue{c}(1),'R') && strcmp(cnd_tar{t}(1),'L')) || (strcmp(cnd_cue{c}(1),'L') && strcmp(cnd_tar{t}(1),'R'))
            else
                cnd=cnd+1;
                cnd_list{cnd,1}=[cnd_cue{c} cnd_dis{d} cnd_tar{t}];
                cnd_list{cnd,2}=0;
            end
        end
    end
end

clear c d t

for n=1:length(prdgmTab)
    
    code=prdgmTab(n,1);
    cue=floor(prdgmTab(n,1)/100);
    dis=floor((code - cue*100)/10);
    target=mod(code,10);
    
    cue_idx=cue+1;
    
    trltyp=[cnd_cue{cue_idx} 'D' num2str(dis) cnd_tar{target}];
    
    idx=find(strcmp(cnd_list(:,1),trltyp));
    
    cnd_list{idx,2}=cnd_list{idx,2} + prdgmTab(n,3);
    
end

fOUT='migraine_Prdgm_chk.txt';
fid=fopen(fOUT,'W+');

for n=1:size(cnd_list,1)
    
    fprintf(fid,'%2s\t%2s\t%2s\t%2d\n',cnd_list{n,1}(1:2),cnd_list{n,1}(3:4),cnd_list{n,1}(5:6),cnd_list{n,2});
    
end

fclose(fid);

clearvars -except cnd_list