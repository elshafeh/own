function [Stim,ISI,trialinfo,timing,expectedRep] = vrhy_CreateAllTrials(repeat,sequence_size, repeat_freq, possib_isi)

% repeat : number of times a condition would be repeated (within block)
% sequence_size: number of digits in input stream, excluding target
% repeat_freq: how often each frequency should be repeated (blocsck-wise)
global ctl

possib_rhythm                   = [1.3 2.1 3.1];

Stim                            = [];
ISI                             = [];
trialinfo                       = [];
expectedRep                     = [];

timing                          = {};

i                               = 0;
for n = 1:repeat_freq
    frequencies = Shuffle(possib_rhythm);
    for nr = 1:length(frequencies)        
        for nb = 1:repeat
            for ni = Shuffle(1:length(possib_isi))
                i                   = i + 1;

                F                   = 1/frequencies(nr);

                trial_stim          = [];
                trial_isi           = [];

                for ns = 1:sequence_size
                    trial_stim      = [trial_stim '0'];
                    trial_isi       = [trial_isi F * (ns-1)];
                end

                list_target         = ['1', '4', '6', '8', 'J', 'H', 'E', 'A'];

                if possib_isi(ni) == 0
                    target          = 'X'; %No target
                    trial_stim      = [trial_stim target]; % 5 elements + catch
                    trial_isi       = [trial_isi NaN];
                else
                    target          = list_target(randi(length(list_target)));
                    trial_stim      = [trial_stim target]; % 5 elements + catch
                    trial_isi       = [trial_isi F*(sequence_size-1 +possib_isi(ni))];
                end

                Stim                = [Stim;trial_stim]; clear trial_stim;
                ISI                 = [ISI;trial_isi]; clear trial_isi;

                trialinfo           = [trialinfo; i F possib_isi(ni)];

                timing{i}           = [];

                if strcmp(target, 'X')
                    expectedRep(i)      = -1;
                else
                    if isletter(target)
                        if ctl.mapping == 1
                            expectedRep(i)  = 1;
                        else
                            expectedRep(i)  = 2;
                        end
                    else
                        if ctl.mapping == 1
                            expectedRep(i)  = 2;
                        else
                            expectedRep(i)  = 1;
                        end
                    end
                end
            end
        end
    end
end