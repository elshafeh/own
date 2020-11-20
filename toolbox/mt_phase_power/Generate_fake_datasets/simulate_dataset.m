function sdata=simulate_dataset(Ntrl,FOI,time,toi,Fs,dipole_position,dipole_momentum,LABELS,Probability,Strength,Pdiscard)

[~, t0]=min(abs(time-toi(1)));
[~,t1]=min(abs(time-toi(2)));


%simulated_data=rand(Ntrl,length(time));
simulated_data=nan(Ntrl,length(time));
for trl=1:Ntrl
simulated_data(trl,:)=pincnoise(length(time));
end

L=size(t0:t1,2);
data_oi=simulated_data(:,t0:t1);
%Now assign probability of hit or miss

win=hanning(size(data_oi,2));
f=Fs*(0:(L/2))/L;
[~,findex]=min(abs(f-FOI));
for trl=1:Ntrl
    trial=squeeze(data_oi(trl,:));
    trial=(trial-mean(trial)).*win';
    y=fft(trial);
    phase(trl)=angle(y(findex));
    trl_for_simulation{1,trl}=squeeze(simulated_data(trl,:));
end

Poutcome=max(0,min(1,Probability+Strength*cos(phase)));
trialinfo=random('bino',1,Poutcome);


%Use standard bem model for the simulation of the dipole
load standard_bem %Here we get the vol
elec=ft_read_sens('standard_1020.elc');

%Now project the data
cfg      = [];
cfg.vol  = vol;             % see above
cfg.elec = elec;            % see above
cfg.dip.pos = dipole_position;
cfg.dip.mom = dipole_momentum';
cfg.dipoleunit='mm';
cfg.fsample = Fs;    
cfg.dip.signal=trl_for_simulation;
cfg.relnoise=0.3;

sdata=ft_dipolesimulation(cfg);

for trl=1:Ntrl
    sdata.time{1,trl}=time;
end

sdata.trialinfo=trialinfo';

cfg=[];
cfg.channel=LABELS;

%Randomly discard some of the trials;
tmp=rand(Ntrl,1);
cfg.trials=(tmp>=Pdiscard);
sdata=ft_selectdata(cfg,sdata);


%And now sort them accordingly to LABELS
[~, order]=ismember(LABELS,sdata.label);
for trl=1:length(sdata.trial)
    sdata.trial{1,trl}=sdata.trial{1,trl}(order,:);
end


