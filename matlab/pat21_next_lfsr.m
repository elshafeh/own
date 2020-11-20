% generates the next pseudo-random sequence of k bits from a seed of same length
% loops after 2^k-1 runs
% the mask is given by create_mask_lfsr
% Julien Besle - 10-29-08


function next_seq = next_lfsr(seed,mask)

if size(seed,2)>1
    seed = seed';
end

if ~sum(find(seed))
    fprintf(1,'WARNING: seed is only zeroes\n');
end

if ~exist('mask','var') || isempty(mask)
    mask = create_lfsr_mask(length(seed));
end

last_bit = seed(end);
next_seq = [0;seed(1:end-1)];

if last_bit
    next_seq = xor(next_seq,mask);
end

