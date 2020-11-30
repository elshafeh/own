clear;clc;

Nseq=10;

ALL_DIS=[];

dis_sound_check=[];

DIS=[];

fIN='sons_list.txt';
fid=fopen(fIN,'r');


for p=1:54
    
    DIS{p,1}=fgetl(fid);
    DIS{p,1}=strrep(DIS{p,1},'.wav','');
    DIS{p,2}=0;
end

for n=1:Nseq
    
    tar_cond={'A','B','C','D'};
    cue_cond={'B','L','R'};
    
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
    
    % load txt
    
    fIN=['Disc_Fix_' num2str(n) '.txt'];
    seq=importtxt(fIN, 2, 65);
    
    % remove ""
    
    for m=1:size(seq,1)
        for p=1:size(seq,2)
            if isstr(seq{m,p})
                seq{m,p}=strrep(seq{m,p},'"','');
            end
        end
    end
    
    % break the code to cue dis and target
    
    for m=1:size(seq,1)
        
        code=seq{m,4};
        cue=floor(code/100);
        dis=floor((code - cue*100)/10);
        target=mod(code,10);
        
        seq{m,14}=cue;
        seq{m,15}=dis;
        seq{m,16}=target;
        
    end
    
    % check stimuli correspond with codes
    % cue
    
    ndis=0;
    
    for m=1:size(seq,1)
        
        if strcmp(seq{m,3}(1),cue_cond{seq{m,14}+1})
        else
            fprintf('problem with cue stim in trial %d\n',seq{m,1})
        end
        
        if strcmp(seq{m,8},'nul')
            if seq{m,15}==0;
            else
                fprintf('problem with dis stim in trial %d\n',seq{m,1})
            end
        else
            
            ndis=ndis+1;
            
            dis_sound_check{n,ndis}=seq{m,8};
            
            idx_dis=find(strcmp(DIS(:,1),seq{m,8}));
            
            DIS{idx_dis,2}=DIS{idx_dis,2}+1;
            
            if seq{m,15}~=0;
            else
                fprintf('problem with dis stim in trial %d\n',seq{m,1})
            end
        end
        
        % target
        
        if strcmp(seq{m,10}(end),tar_cond{seq{m,16}})
        else
            fprintf('problem with target stim in trial %d\n',seq{m,1})
        end
        
        trltyp=[cnd_cue{seq{m,14}+1} 'D' num2str(seq{m,15}) cnd_tar{seq{m,16}}];
        
        idx=find(strcmp(cnd_list(:,1),trltyp));
        
        cnd_list{idx,2}=cnd_list{idx,2} + 1;
        
    end
    
    % dis
    
    fOUT=['Disc_Fix_' num2str(n) '_check.txt'];
    fid=fopen(fOUT,'W+');
    
    for p=1:size(cnd_list,1)
        
        fprintf(fid,'%2s\t%2s\t%2s\t%2d\n',cnd_list{p,1}(1:2),cnd_list{p,1}(3:4),cnd_list{p,1}(5:6),cnd_list{p,2});
        
    end
    
    fclose(fid);
    
    fOUT='DistSoundCheck.txt';
    fid=fopen(fOUT,'W+');
    
    for p=1:size(dis_sound_check,2)
        
        tmp = dis_sound_check(n,:);
        
        dis = tmp{1,p};
        rest = tmp(~strcmp(tmp,dis));
        
        flag = rest(strcmp(rest,dis));
        
        if size(flag,1) == 0 || size(flag,2) == 0
        else
            fprintf('Duplicate Dis: %s\n',num2str(n));
        end
        
    end

    
    for p=1:size(dis_sound_check,1);
        
        for m=1:size(dis_sound_check,2);
            
            fprintf(fid,'%20s\t',dis_sound_check{p,m});
            
        end
        
        fprintf(fid,'\n');
        
    end
    
    fclose(fid);
    
    dis_delay=[cell2mat(seq(:,6)) cell2mat(seq(:,9))]; % 9 for delay2 % 5 for delay1
    
    dis_delay=dis_delay(dis_delay(:,1)~=0,:);
    
    ALL_DIS=[ALL_DIS;dis_delay];
    
    dis1=dis_delay(dis_delay(:,1)==1,2);
    dis2=dis_delay(dis_delay(:,1)==2,2);
    
%     figure
%     hold on
%     
%     histogram(dis1,'BinWidth',10)
%     histogram(dis2,'BinWidth',10)
%     legend({'DIS1','DIS2'});
%     xlim([0 1000]);
%     ylim([0 8]);
    
end

fOUT='DisSoundTotal.txt';
fid=fopen(fOUT,'W+');
for p=1:size(DIS,1);
    
    fprintf(fid,'%20s\t%3d\n',DIS{p,1},DIS{p,2});
    
end

fclose(fid);

clearvars -except ALL_DIS

dis1=ALL_DIS(ALL_DIS(:,1)==1,2);
dis2=ALL_DIS(ALL_DIS(:,1)==2,2);

figure
hold on

histogram(dis1,'BinWidth',5)
histogram(dis2,'BinWidth',5)
vline(50,'r','lim1');
vline(350,'r','lim2');
legend({'DIS1','DIS2'});
xlim([0 800]);
