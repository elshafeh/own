%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to produce a comodulogram of Phase Amplitude Coupling (PAC)
% Modulation Index (MI) values using the metrics from Tort et al.,(2010),
% Ozkurt & Schnitzler (2011), Canolty et al., (2006) and
% PLV (Cohen 2008).
%
% Inputs:
% - virtsens = MEG data (1 channel)
% - toi = times of interest in seconds e.g. [0.3 1.5]
% - phases of interest e.g. [4 22] currently increasing in 1Hz steps
% - amplitudes of interest e.g. [30 80] currently increasing in 2Hz steps
% - diag = 'yes' or 'no' to turn on or off diagrams during computation
% - surrogates = 'yes' or 'no' to turn on or off surrogates during computation
% - approach = 'tort','ozkurt','canolty','PLV'
% Optional Inputs:
% - Number of phase bins used in KL-MI-Tort approach (default = 18)
%
% Outputs:
% - MI_matrix_raw = phase amplitude comodulogram (no surrogates)
% - MI_matrix_surr = = phase amplitude comodulogram (with surrogates)
%
% For details of the PAC methods go to:
% http://jn.physiology.org/content/104/2/1195.short
% http://science.sciencemag.org/content/313/5793/1626.long
% http://www.sciencedirect.com/science/article/pii/S0165027011004730
% http://www.sciencedirect.com/science/article/pii/S0165027007005237
%
% Written by: Robert Seymour - Aston Brain Centre. July 2017.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MI_matrix_raw,MI_matrix_surr,MI_raw_surr] = separate_calc_MI_optimised_bast(original_virtsens_pha,original_virtsens_amp,list_toi,phase,amp,diag,surrogates,list_approach,step_phase,step_amp,chan_index,trial_index,varargin)

% Set number of bins used for Tort
if isempty(varargin)
    nbin = 18;
else
    fprintf('Number of bins set to %s',num2str(varargin{1}))
    nbin = varargin{1};
end

if diag == 'no'
    disp('NOT producing any images during the computation of MI')
end

% Determine size of final matrix
phase_length    = length(phase(1):step_phase:phase(2));
amp_length      = length(amp(1):step_amp:amp(2));

pha_vector = phase(1):step_phase:phase(2);
amp_vector = amp(1):step_amp:amp(2);

% Create matrix to hold comod

n_chan_out = length(chan_index);
n_cond_out = length(trial_index);
n_time_out = length(list_toi);
n_meth_out = length(list_approach);

for han_toi = 1:n_time_out
    for han_chan = 1:n_chan_out
        for han_cond = 1:n_cond_out
            for han_meth = 1:length(n_meth_out)
                
                MI_matrix_raw{han_chan,han_cond,han_toi,han_meth}   = zeros(amp_length,phase_length);
                MI_matrix_surr{han_chan,han_cond,han_toi,han_meth} = zeros(amp_length,phase_length);
                MI_raw_surr{han_chan,han_cond,han_toi,han_meth}     = zeros(amp_length,phase_length);
                
            end
        end
    end
end

clear phase_length amp_length

iphase         = 0;
iampl          = 0;

for phase_freq = phase(1):step_phase:phase(2) % steps of 2 Hz
    
    iphase                      = iphase + 1;
    
    cfg                         = [];
    cfg.showcallinfo            = 'no';
    cfg.bpfilter                = 'yes';
    cfg.bpfreq                  = [phase_freq-1 phase_freq+1]; %+-1Hz - could be changed if necessary
    cfg.hilbert                 = 'angle';
    
    [virtsens_pha{iphase}]      = ft_preprocessing(cfg, original_virtsens_pha);
    
end

% close(h_wait);


for amp_freq = amp(1):step_amp:amp(2) % steps of 5 Hz
    
    %     waitbar(hesham/length(amp(1):step_amp:amp(2)));
    
    iampl                      = iampl + 1;
    
    % Specifiy bandwith = +- 2.5 * center frequency
    Af1 = round(amp_freq -(amp_freq/2.5)); Af2 = round(amp_freq +(amp_freq/2.5));
    
    %     Af1 = round(amp_freq -5); Af2 = round(amp_freq +5);
    
    % Filter data at amp frequency using Butterworth filter
    cfg                         = [];
    cfg.showcallinfo            = 'no';
    cfg.bpfilter                = 'yes';
    cfg.bpfreq                  = [Af1 Af2];
    cfg.hilbert                 = 'abs';
    [virtsens_amp{iampl}]       = ft_preprocessing(cfg, original_virtsens_amp);
    
end

clc ; 

ntest_total       = n_time_out * n_chan_out * n_meth_out * iphase * iampl * n_cond_out;
test_count        = 0;

ft_progress('init','text',    'Phew.. Done Filtering !!');

for han_toi = 1:n_time_out
    for han_chan = 1:n_chan_out
        for han_cond = 1:n_cond_out
            for han_meth = 1:n_meth_out
                
                row1            = 1;
                row2            = 1;

                for han_phase_i = 1:iphase
                    for han_ampl_i = 1:iampl
                        
                        lmt1                                = list_toi(1,han_toi);
                        findlm1                             = abs(virtsens_pha{han_phase_i}.time{1} - lmt1);
                        lmt1                                = find(findlm1 == min(findlm1));
                        
                        lmt2                                = list_toi(2,han_toi);
                        findlm2                             = abs(virtsens_pha{han_phase_i}.time{1} - lmt2);
                        lmt2                                = find(findlm2 == min(findlm2));
                        
                        trial_in                            =  trial_index{han_cond};
                        
                        % Variable to hold MI for all trials
                        MI_all_trials       = [];
                        
                        % For each trial...
                        
                        for trial_num = 1:length(trial_in)
                            
                            % Extract phase and amp info using hilbert transform
                            
                            Phase       = virtsens_pha{han_phase_i}.trial{1, trial_in(trial_num)}(chan_index(han_chan),lmt1:lmt2); % getting the phase
                            Amp         = virtsens_amp{han_ampl_i}.trial{1, trial_in(trial_num)}(chan_index(han_chan),lmt1:lmt2); % getting the amplitude envelope
                            
                            % Switch PAC method based on the approach
                            switch list_approach{han_meth}
                                case 'tort'
                                    [MI] = calc_MI_tort(Phase,Amp,nbin);
                                    
                                case 'ozkurt'
                                    [MI] = calc_MI_ozkurt(Phase,Amp);
                                    
                                case 'canolty'
                                    [MI] = calc_MI_canolty(Phase,Amp);
                                    
                                case 'PLV'
                                    [MI] = calc_MI_PLV(Phase,Amp);
                            end
                            
                            % Add the MI value to all other all other values
                            MI_all_trials(trial_num) = MI;
                            
                        end
                        
                        % If user specified to use surrogates - use them!
                        if strcmp(surrogates, 'yes')
                            
                            % Variable to surrogate MI
                            MI_surr = [];
                            
                            % For each surrogate (surrently hard-coded for 200, could be changed)...
                            for surr = 1:200
                                % Get 2 random trial numbers
                                
                                trial_num = randperm(length(trial_in),2);
                                trial_num = trial_in(trial_num);
                                
                                % Extract phase and amp info using hilbert transform
                                % for different trials & shuffle phase
                                
                                hindy = randperm(length(virtsens_pha{han_phase_i}.trial{1,trial_num(1)}(chan_index(han_chan),lmt1:lmt2)));
                                
                                Phase=virtsens_pha{han_phase_i}.trial{1, trial_num(1)}(chan_index(han_chan),hindy); % getting the phase
                                
                                Amp = virtsens_amp{han_ampl_i}.trial{1,trial_num(2)}(chan_index(han_chan),lmt1:lmt2);
                                
                                
                                % Switch PAC approach based on user input
                                
                                switch list_approach{han_meth}
                                    
                                    case 'tort'
                                        [MI] = calc_MI_tort(Phase,Amp,nbin);
                                        
                                    case 'ozkurt'
                                        [MI] = calc_MI_ozkurt(Phase,Amp);
                                        
                                    case 'canolty'
                                        [MI] = calc_MI_canolty(Phase,Amp);
                                        
                                    case 'PLV'
                                        [MI] = calc_MI_PLV(Phase,Amp);
                                end
                                
                                % Add this value to all other all other values
                                MI_surr(surr) = MI;
                            end
                            
                            % Calculate average MI over trials
                            MI_raw                      = mean(MI_all_trials);
                            
                            % Subtract the mean of the surrogaates from the actual PAC
                            % value and add this to the surrogate matrix
                            MI_surr_normalised                                                       = MI_raw-mean(MI_surr);
                            
                            MI_matrix_surr{han_chan,han_cond,han_toi,han_meth}(row1,row2)   = MI_surr_normalised;
                            
                            MI_raw_surr{han_chan,han_cond,han_toi,han_meth}(row1,row2)      = mean(MI_surr);
                            
                        end
                        
                        % Calculate the raw MI score (no surrogates) and add to the matrix
                        
                        MI_raw                      = mean(MI_all_trials);
                        
                        MI_matrix_raw{han_chan,han_cond,han_toi,han_meth}(row1,row2)    = MI_raw;
                        
                        clear MI_raw MI_surr MI_surr_normalised MI_all_trials 
                        
                        % Show progress of the comodulogram if diag = 'yes'
                        if strcmp(diag, 'yes')
                            figure(2)
                            pcolor(phase(1):1:phase(2),amp(1):2:amp(2),MI_matrix_raw{han_chan,han_cond,han_toi,han_meth})
                            colormap(jet)
                            ylabel('Amplitude (Hz)')
                            xlabel('Phase (Hz)')
                            colorbar
                            drawnow
                        end
                        
                        % Go to next Amplitude
                        row1 = row1 + 1;
                        
                        pha_vector = phase(1):step_phase:phase(2);
                        amp_vector = amp(1):step_amp:amp(2);

                        test_count= test_count+1;
                        
                        ft_progress(test_count/ntest_total, 'Test %d Out Of %d\n', test_count, ntest_total);
                        
                    end
                    
                    % Go to next Phase
                    row1 = 1;
                    row2 = row2 + 1;
                end
            end
        end
    end
end
% close(h_wait) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PAC SUB-FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [MI] = calc_MI_tort(Phase,Amp,nbin)
        
        % Apply Tort et al (2010) approach)
        %nbin=18; % % we are breaking 0-360o in 18 bins, ie, each bin has 20o
        position=zeros(1,nbin); % this variable will get the beginning (not the center) of each bin
        % (in rads)
        winsize = 2*pi/nbin;
        for j=1:nbin
            position(j) = -pi+(j-1)*winsize;
        end
        
        % now we compute the mean amplitude in each phase:
        MeanAmp=zeros(1,nbin);
        for j=1:nbin
            I = find(Phase <  position(j)+winsize & Phase >=  position(j));
            MeanAmp(j)=mean(Amp(I));
        end
        
        % The center of each bin (for plotting purposes) is
        % position+winsize/2
        
        % Plot the result to see if there's any amplitude modulation
        if strcmp(diag, 'yes')
            bar(10:20:720,[MeanAmp,MeanAmp]/sum(MeanAmp),'phase_freq')
            xlim([0 720])
            set(gca,'xtick',0:360:720)
            xlabel('Phase (Deg)')
            ylabel('Amplitude')
        end
        
        % Quantify the amount of amp modulation by means of a
        % normalized entropy index (Tort et al PNAS 2008):
        
        MI=(log(nbin)-(-sum((MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))))))/log(nbin);
    end

    function [MI] = calc_MI_ozkurt(Phase,Amp)
        % Apply the algorithm from Ozkurt et al., (2011)
        N = length(Amp);
        z = Amp.*exp(1i*Phase); % Get complex valued signal
        MI = (1./sqrt(N)) * abs(mean(z)) / sqrt(mean(Amp.*Amp)); % Normalise
    end

    function [MI] = calc_MI_PLV(Phase,Amp)
        % Apply PLV algorith, from Cohen et al., (2008)
        amp_phase = angle(hilbert(detrend(Amp))); % Phase of amplitude envelope
        MI = abs(mean(exp(1i*(Phase-amp_phase))));
    end

    function [MI] = calc_MI_canolty(Phase,Amp)
        % Apply MVL algorith, from Canolty et al., (2006)
        z = Amp.*exp(1i*Phase); % Get complex valued signal
        MI = abs(mean(z));
    end

end