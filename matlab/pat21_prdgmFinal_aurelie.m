clear ; clc ;

pos = load('/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/fc1/pos/fc1.pat2.rec.pos');

pos             =   pos(pos(:,3) == 0,1:2);
pos(:,3)        =   floor(pos(:,2)/1000);
pos             =   pos(pos(:,3)==1,:);
pos(:,4)        =   pos(:,2) - (pos(:,3)*1000);
pos(:,5)        =   floor(pos(:,4)/100);
pos(:,6)        =   floor((pos(:,4)-100*pos(:,5))/10);     % Determine the DIS latency
pos(:,7)        =   mod(pos(:,4),10);
pos             =   pos(1:64,:);

list_cue = {'unf','l','r'};
list_tar = {'llo','rlo','lhi','rhi'};
list_dis = {'d0','d1','d2'};

list_tot = {};

ix = 0 ;

for cnd_cue = 1:3
    for cnd_dis = 1:3
        for cnd_tar = 1:4
            
            ix = ix + 1;
            list_tot{ix,1} = [list_cue{cnd_cue} '.' list_dis{cnd_dis} '.' list_tar{cnd_tar}];
            
            
        end
    end
end

nw_list = list_tot ;

for n = 1:length(nw_list)
    nw_list{n,2} = 0;
end

for n = 1:length(pos)
    
    ttype = [list_cue{pos(n,5)+1} '.' list_dis{pos(n,6)+1} '.' list_tar{pos(n,7)}];
    ii    = find(strcmp(list_tot,ttype));
    nw_list{ii,2} = nw_list{ii,2}+1;
    
end