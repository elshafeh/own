function sdata=simulate_power_dataset(FOI,time,Fs,LABELS,trialinfo,dipole_position,dipole_momentum,Strength)


Ntrl=length(trialinfo);
%simulated_data=rand(Ntrl,length(time));
simulated_data=nan(Ntrl,length(time));
for trl=1:Ntrl
simulated_data(trl,:)=pincnoise(length(time));
if ~trialinfo(trl)
      simulated_data(trl,:)=simulated_data(trl,:)+squeeze(std(simulated_data(trl,:)))*Strength*cos(2*pi*FOI*time);
    
end

trl_for_simulation{1,trl}=squeeze(simulated_data(trl,:));
end




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
sdata=ft_selectdata(cfg,sdata);


%And now sort them accordingly to LABELS
[~, order]=ismember(LABELS,sdata.label);
for trl=1:length(sdata.trial)
    sdata.trial{1,trl}=sdata.trial{1,trl}(order,:);
end

sdata.trialinfo=trialinfo;
