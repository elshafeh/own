function null_pos=null_pos_calculate(data,hit_vec,Null_values)

assert(~isreal(data),'Please enter complex values to this function!')
data=data./abs(data);

P12=(abs(mean(data,1)));

null_pos=nan(Null_values,size(data,2),size(data,3));

Ntrl=size(data,1);

for nrand=1:Null_values
    hit_vec=hit_vec(randperm(Ntrl));
    P1=(abs(mean(data(hit_vec,:,:),1)));
    P2=(abs(mean(data(~hit_vec,:,:),1)));
    null_pos(nrand,:,:)=P1+P2;
    
end

null_pos=squeeze(null_pos)-2*repmat(P12,Null_values,1,1);

clearvars -except null_pos