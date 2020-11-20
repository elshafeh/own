function [trl,data] = e_func_pres_to_trl(log_table,bloc_cond,bloc_length)

% input : 
% ds_name           : log_table that has already been read through
% importlog.m

% bloc_order        : vector with Conditions -> use 1 for eye-open and 2 for eye-closed
% bloc_length       : 76 (trials) + 4 (example) = 80

% ouput: 
% [1] trl           : elements are self-explanatory
% [2] data          : elements are self-explanatory


log_table.Time  = log_table.Time/10;

trl.n           = [1:(length(bloc_cond)*bloc_length)]'; % trial number

trl.cond        = [];

for i = 1:length(bloc_cond) % extract block number and condition !!
    trl.cond    = [trl.cond; repmat(i,bloc_length,1) repmat(bloc_cond(i),bloc_length,1)];
end

% find the trial start onsets
trl.start=[];

for i=1:height(log_table)
    
    if strcmp(log_table.Code(i), 'start') % trial onset code
        trl.start=[trl.start; i];
    end
    
end

if length(trl.start)~=trl.n(end), error('trial number disagreement'), end

% find the cue onsets
trl.cue=[];
for i=1:height(log_table)
    if ismember(double(log_table.Code(i)), [64 128]) % cue onset code
        trl.cue=[trl.cue; i];
    end
end
if length(trl.cue)~=trl.n(end), error('trial number disagreement'), end


% find the pre stim interval onsets
trl.isi=[];

for i=1:height(log_table)
    if double(log_table.Code(i))==32 % pre-stim interval onset code
        trl.isi=[trl.isi; i];
    end
end

if length(trl.isi)~=trl.n(end), error('trial number disagreement'), end


% find the stim onsets
t=0; i=1;
while i<=height(log_table)
    
    if strcmp(log_table.Code(i), 'start') % trial onset code
        t=t+1; % trial number
        p=1;   % pulse number
    end
    
    if ismember(double(log_table.Code(i)), [1 2]) % pulse
        trl.stim(t,p)=i;
        p=p+1;
    end
    
    i=i+1;
end

if size(trl.stim,1)~=trl.n(end), error('trial number disagreement'), end

% find stimulated side [1=left, 2=right] : please verify ±±
trl.side=[];
for i=1:trl.n(end)
    trl.side(i,1)=double(log_table.Code(trl.stim(i,2)));
end
if length(trl.side)~=trl.n(end), error('trial number disagreement'), end


% find stim freq (or actually, pulse number)
trl.freq=[];
for i=1:trl.n(end)
    trl.freq(i,1)=nnz(trl.stim(i,:));
end
if length(trl.freq)~=trl.n(end), error('trial number disagreement'), end


% find the response feedback onsets
trl.feedback    =[]; % four example !! 

for i=1:height(log_table)-1
    if strcmp(log_table.Code(i), 'correct') || strcmp(log_table.Code(i), 'incorrect') || strcmp(log_table.Code(i), 'noresp')
        trl.feedback=[trl.feedback; i];
    end
end

if length(trl.feedback)~=trl.n(end), error('trial number disagreement'), end


% find the button presses
trl.but         =[];

for i=1:height(log_table)
    if (strcmp(log_table.Code(i), 'correct') || strcmp(log_table.Code(i), 'incorrect')) 
        
        chk_code                = double(log_table.Code(i-1));
        
        if ismember(chk_code, [4 8])
            trl.but             = [trl.but; i-1 chk_code]; % response prior to feedback
        end
        
    elseif strcmp(log_table.Code(i), 'noresp')
        
        trl.but             = [trl.but; i-1 0]; % no response
        
    end
end
% % collect the experiment specs & behavioural results
% compute trial length (including feedback)
data.triallength=[];

for i=2:length(trl.start)
    
    data.triallength(i)=log_table.Time(trl.feedback(i)+1)-log_table.Time(trl.start(i));
    
end

% compute real isi
data.isi=[];
for i=1:length(trl.isi)
    data.isi(i)=(log_table.Time(trl.stim(i,1)) - log_table.Time(trl.isi(i))) / 1000; % real isi
end


% collect performance (correct or incorrect)
data.perf=[];

for i=1:length(trl.feedback)
    
    if ismember(trl.but(i,2), [4 8]) % button press
        if (trl.but(i,2)==4 && trl.stim(i,end)==0) || (trl.but(i,2)==8 && trl.stim(i,end)~=0) % correct (1)
            data.perf=[data.perf 1];
        else % incorrect (-1)
            data.perf=[data.perf -1];
        end
    elseif trl.but(i,2)==0 % no button press (0)
        data.perf=[data.perf 0];
    end
    
end

% compute RTs
data.RT=[];
for i=1:length(trl.but)
    if trl.but(i,2)~=0
        data.RT(i)=log_table.Time(trl.but(i))-log_table.Time(trl.but(i)-1);
    elseif trl.but(i,2)==0
        data.RT(i)=nan;
    end
end

data.isi    = data.isi';
data.perf   = data.perf';