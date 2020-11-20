function [min_p_val,p_val] = h_pValSort(x)

% input : cluster-based permutation stat structure 
% ouput : minimum p-value + vector of the p-values of all the clusters with
% indexed by their sign (+/-)

if isfield(x,'posclusters') && isfield(x,'negclusters') 
    if isempty(x.posclusters)
        p_val       = [x.negclusters.prob; repmat(-1,1,length([x.negclusters.prob]))];
    elseif isempty(x.negclusters)
        p_val       = [x.posclusters.prob; ones(1,length([x.posclusters.prob]))];
    else
        p_val       = horzcat([x.posclusters.prob ; ones(1,length([x.posclusters.prob]))],[x.negclusters.prob ; repmat(-1,1,length([x.negclusters.prob]))]);
    end
    
    p_val       = sortrows(p_val',1)';
    min_p_val   = min(p_val(1,:));
    
else
    
    p_val       = sortrows(unique(x.prob),1);
    min_p_val   = min(p_val);
    
end

