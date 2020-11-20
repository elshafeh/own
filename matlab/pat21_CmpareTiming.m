clear ; clc
load ../data/yctot/gavg/timing_dis.mat

for n = 1:length(whenCue)
    combined_whenCue{n,1}       = whenCue{n};
    combined_whenCueOffset{n,1} = whenCueOffset{n};
    combined_whenRep{n,1}       = whenRep{n};
    combined_whenTar{n,1}       = whenTar{n};
end

clear when*

load ../data/yctot/gavg/timing_fdis.mat

for n = 1:length(whenCue)
    combined_whenCue{n,2}       = whenCue{n};
    combined_whenCueOffset{n,2} = whenCueOffset{n};
    combined_whenRep{n,2}       = whenRep{n};
    combined_whenTar{n,2}       = whenTar{n};
end

clear when*

bw = 0.01;

figure;
for d = 1:2
    subplot(2,1,d)
    hold on;
    histogram([combined_whenCue{:,d}],'BinWidth',bw)
    histogram([combined_whenCueOffset{:,d}],'BinWidth',bw)
    histogram([combined_whenTar{:,d}],'BinWidth',bw)
    histogram([combined_whenRep{:,d}],'BinWidth',bw)
end