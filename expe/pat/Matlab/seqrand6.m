function seq=seqrand6(Ntrial,Ncat,nstim,Maxsuite);
%on ne rentre pas la proba de chaque cas, mais le nb de repet directement
%cela �vite des pbs dus aux arrondis

n=Ntrial - sum(nstim);

if n>0
   nok=ones(1,Ncat);
   for i=1:n
    	nn=floor(rand*Ncat)+1;
      while nok(nn)==0
         nn=floor(rand*Ncat)+1;
      end;
      nstim(nn)=nstim(nn)+1;
      nok(nn)=0;
   end;
end;
temp0=zeros(1,Ntrial);
k=0;
for j=1:Ncat
   for i=1:nstim(j)
      k=k+1;
      temp0(k)= j;
   end;
end;

%seq(randperm(Ntrial))=temp0(:);

seq_ok=0;
while seq_ok==0
   seq(randperm(Ntrial))=temp0(:);
   Nsuite=1;
   suite=seq(1);
   ksuite=1;
   clear Nsuitemax;
   for i=2:Ntrial
      if seq(i)==suite
         Nsuite=Nsuite+1;
      else
         Nsuitemax(ksuite)=Nsuite;
         ksuite=ksuite+1;
         Nsuite=1;
         suite=seq(i);
      end;
   end;
   Nsuitemax(ksuite)=Nsuite;
   if max(Nsuitemax)<=Maxsuite
      seq_ok=1;
      %fprintf('nsuitemax=%d\n',max(Nsuitemax));
   end;
end;



