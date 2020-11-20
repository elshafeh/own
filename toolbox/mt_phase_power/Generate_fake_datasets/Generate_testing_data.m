addpath('C:\Users\U66300\toolbox\fieldtrip-20161103\');
ft_defaults;


Nparts=10;
Nsessions=2;

info_path='C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_Preproc\02_INFO_FILES\';
output_path='C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_Preproc\04_OUTPUT\';

Ntrl=800; %Number of trials
Fs=500;   %Sampling frequency
time=-1:1/Fs:0; %Time 
Strength=0.3;%Modulation strength
Power_strength=0.2;%Power modulation strength
Probability=0.5;%Probability of outcome (H/M)
dipole_position=[0 -80 30];%In (mm)
dipole_momentum=[1 0 0];%Orientation of the dipole
FOI=10; %Frequency of interest
toi=[-2/FOI 0];%Time for phase modulation
Pdiscard=0.1;%Probability of discarding a trial by artifact rejection

load LABELS_PO

for pnum=1:Nparts
    ID=randsample('A':'Z',2,true);
        for psession=1:Nsessions
        safeID=1.7e9+randi(1e8);
        IAF=FOI;
        IAF_dB=2*rand;
        file_ID=['P' num2str(pnum,'%0.3i') '_S' num2str(psession,'%0.2i') '_' ID '_' num2str(safeID)];
        Generate_info_file(pnum,psession,ID,safeID,IAF,IAF_dB,file_ID,info_path);
        data_phase=simulate_dataset(Ntrl,FOI,time,toi,Fs,dipole_position,dipole_momentum,LABELS_PO,Probability,Strength,Pdiscard);
        data_power=simulate_power_dataset(FOI,time,Fs,LABELS_PO,data_phase.trialinfo,dipole_position,dipole_momentum,Power_strength);
        save(fullfile(output_path,[file_ID '_preproc_phase.mat']),'data_phase');
        save(fullfile(output_path,[file_ID '_preproc_power.mat']),'data_power');
        P_ID{pnum,psession}=file_ID;
    end
    
end

xlswrite('C:\Users\U66300\Dropbox (UPF-MRG)\Cortex_Preproc\Accepted_participants.xlsx',P_ID,'Accepted_participants','A2');