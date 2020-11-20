% computes the probablity associated with a permutation test between two
% paired group
%
% Julien Besle 10-29-2008

function probability = permutation_test(data,n_rand,tail)

if nargin<3
    tail = 'both';
end

if size(data,2)~=2
    error('Test not implemented for more than 2 conditions')
end


%computing actual value:
%[h p ci actual] = ttest(data(:,1)-data(:,2));
actual.tstat = mean(data(:,1)-data(:,2));
%actual.tstat = (sum(data(:,1)))^2+(sum(data(:,2)))^2;
accept_Ho = 0;

%initialize seed
seed = zeros(size(data,1),1);
while ~length(find(seed))
    seed = round(rand(size(data,1),1));
end

rand_t = zeros(min(n_rand,2^size(data,1)-1),1);
% h_waitbar = waitbar(0);
% waitbar(0,h_waitbar,'Computing permutations');
for i_rand = 1:min(n_rand,2^size(data,1)-1);
    %     waitbar(i_rand/min(n_rand,2^size(data,1)-1),h_waitbar);
    
    if i_rand == 1
        permuted_index = seed;
    else
        permuted_index = next_lfsr(permuted_index);
    end
    %if i_rand == 2^size(data,1)
    %    permuted_index
    %end
    permuted_data = data;
    permuted_data(permuted_index==1,1) = data(permuted_index==1,2);
    permuted_data(permuted_index==1,2) = data(permuted_index==1,1);
    %     [h p ci stat] = ttest(permuted_data(:,1)-permuted_data(:,2));
    stat.tstat = mean(permuted_data(:,1)-permuted_data(:,2));
    %stat.tstat = (sum(permuted_data(:,1)))^2+(sum(permuted_data(:,2)))^2;
    rand_t(i_rand) = stat.tstat;
    %or
    if strcmp(tail,'right')
        if actual.tstat<stat.tstat
            accept_Ho = accept_Ho +1;
        end
    elseif strcmp(tail,'left')
        if actual.tstat>stat.tstat
            accept_Ho = accept_Ho +1;
        end
    elseif strcmp(tail,'both')
        if abs(actual.tstat)<abs(stat.tstat)
            accept_Ho = accept_Ho +1;
        end
    else
        error('Wrong value for option tail')
    end
end
% close(h_waitbar);

sorted_t_distribution = sort(rand_t);


probability = accept_Ho/min(n_rand,2^size(data,1)-1);