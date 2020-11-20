function source_MI = h_compute_source_pac(source_ampli,source_phase)

source_MI.pos               = source_ampli.pos;
source_MI.dim               = source_ampli.dim;
source_MI.inside            = source_ampli.inside;

source_MI.pow.ozkurt        = zeros(length(source_ampli.pos),1);
source_MI.pow.plv           = zeros(length(source_ampli.pos),1);
source_MI.pow.tort          = zeros(length(source_ampli.pos),1);
source_MI.pow.canolty       = zeros(length(source_ampli.pos),1);

inside_voxels               = find(source_ampli.inside==1);
hw_many_voxels_are_there    = length(inside_voxels);
% ntrials                     = size(source_ampli.cumtapcnt,1);

ft_progress('init','text',    'Please wait...');

data_phase                       = [];
data_ampli                       = [];

for nvox = 1:hw_many_voxels_are_there
    
    ft_progress(nvox/hw_many_voxels_are_there, 'Processing voxel %d from %d\n', nvox, hw_many_voxels_are_there);
    
    data_phase           = [data_phase; angle(source_phase.avg.mom{inside_voxels(nvox)})];            % Computes the angles, in radians
    data_ampli           = [data_ampli; abs(source_ampli.avg.mom{inside_voxels(nvox)})];            % Computes the angles, in radians
    
end

nbin            = 18;
Phase           = data_phase';
Amp             = data_ampli';


%% [1] Quantify the amount of amp modulation by means of a normalized entropy index (Tort et al PNAS 2008):

position        = zeros(1,nbin); 
winsize = 2*pi/nbin;
for j=1:nbin
    position(j) = -pi+(j-1)*winsize;
end

MeanAmp=zeros(1,nbin);
for j=1:nbin
    I               = find(Phase <  position(j)+winsize & Phase >=  position(j));
    MeanAmp(j)      = mean(Amp(I));
end

MI_tort         = (log(nbin)-(-sum((MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))))))/log(nbin);

%% [2] Apply the algorithm from Ozkurt et al., (2011)
N               = length(Amp);
z               = Amp.*exp(1i*Phase); % Get complex valued signal
MI_ozkurt       = (1./sqrt(N)) * abs(mean(z)) / sqrt(mean(Amp.*Amp)); % Normalise

%% [3] Apply MVL algorith, from Canolty et al., (2006)
z               = Amp.*exp(1i*Phase); % Get complex valued signal
MI_canolty      = abs(mean(z));

%% [4] Apply PLV algorith, from Cohen et al., (2008)
amp_phase       = angle(hilbert(detrend(Amp))); % Phase of amplitude envelope
MI_plv          = abs(mean(exp(1i*(Phase-amp_phase))));

%% Craete source

source_MI.pow.ozkurt(source_MI.inside ==1)         = MI_ozkurt;
source_MI.pow.plv(source_MI.inside ==1)            = MI_plv;
source_MI.pow.tort(source_MI.inside ==1)           = MI_tort;
source_MI.pow.canolty(source_MI.inside ==1)        = MI_canolty;

end