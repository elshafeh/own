% Distracter Randomization
% Detection (Both)
% To get the same dis for each category with no repetition within a block

TDIScat=zeros(1,NDIScat);

for c=1:Ncat
    if tot_list(c,4)>0
        cat=tot_list(c,4);
        TDIScat(cat)=TDIScat(cat)+tot_list(c,3);
    end;
end;

minD=min(TDIScat)*Nseq;
if minD<=Ndis
    minDIS=minD;
else
    minDIS=Ndis;
end;
maxD=max(TDIScat)*Nseq;
maxDIS=max(TDIScat);

D=zeros(1,maxD);
nrepet=maxD/minD;
for r=1:nrepet
    D(1,1+(r-1)*minDIS:r*minDIS)=randperm(minDIS);
end;

DD=zeros(Nseq,maxDIS);
DDC=zeros(Nseq,maxDIS,NDIScat);

for s=1:Nseq
    DD(s,:)=D(1,1+(s-1)*maxDIS:s*maxDIS);
    temp=perms(DD(s,:));
    tt=size(temp,1);
    for c=1:NDIScat
        DDC(s,:,c)=temp(floor(rand*tt)+1,:);
    end;
end;

tc=[
    1  2 10  3  9  4  8  5  7  6
    2  3  1  4 10  5  9  6  8  7
    3  4  2  5  1  6 10  7  9  8
    4  5  3  6  2  7  1  8 10  9];

Tdis=[];

for s=1:Nseq
    tempdis=zeros(NDIScat,maxDIS);
    for c=1:NDIScat
        tempdis(c,:)=DDC(tc(c,s),:,c);
    end;
    Tdis=[Tdis tempdis];
end;
