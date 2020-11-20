function pos_val=pos_calculate(data,hit_vec)

assert(~isreal(data),'Please enter complex values to this function!')
data=data./abs(data);

P1=squeeze(abs(mean(data(hit_vec,:,:),1)));
P2=squeeze(abs(mean(data(~hit_vec,:,:),1)));
P12=squeeze(abs(mean(data,1)));

pos_val=P1+P2-2*P12;
clearvars -except pos_val

