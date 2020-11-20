function [design,neighbours] = h_create_design_neighbours(subj,single_data,data_type,test)

% Creates Neighbours & Design
% subj : number of subjetcs
% data :either 'meg' or 'eeg' , usually meg
% test : 't' for a t-test or 'a' for anova

if strcmp(data_type,'meg')
    
    cfg         = [];
    cfg.method  = 'triangulation';
    cfg.layout  = 'CTF275.lay';
    neighbours  = ft_prepare_neighbours(cfg);
    
elseif strcmp(data_type,'eeg') 
    
    load elan_sens.mat
    
    cfg.method          =   'triangulation' ;
    cfg.sens            =   sens ;
    cfg.layout          =   'elan_lay.mat' ;
    neighbours          =   ft_prepare_neighbours(cfg);
    
else
    
    neighbours = [];
    for n = 1:length(single_data.label)
        neighbours(n).label = single_data.label{n};
        neighbours(n).neighblabel = {};
    end
    
end

% Create Design

if strcmp(test,'t')
    
    design = zeros(2,2*subj);
    for i = 1:subj
        design(1,i) = i;
    end
    for i = 1:subj
        design(1,subj+i) = i;
    end
    design(2,1:subj)        = 1;
    design(2,subj+1:2*subj) = 2;
    
    clear cfg i subj;
    
elseif strcmp(test,'itc1')
    
    design  = [];
    
    for y = 1:2
        for i = 1:subj
            tmp1    = 1:length(single_data.trialinfo);
            tmp2    =  repmat(y,1,length(tmp1));
            toto    = [tmp1;tmp2];
            design  = [design toto];
        end
    end

elseif strcmp(test,'itc2')
    
    tmp1    = [1:length(single_data.trialinfo)*subj 1:length(single_data.trialinfo)*subj];
    tmp2    = [ones(1,length(tmp1)/2) 2*ones(1,length(tmp1)/2)];
    
    design  = [tmp1;tmp2];

else
    
    design=zeros(2,3*subj);
    for i=1:subj
        design(1,i)=i;
    end
    for i=1:subj
        design(1,subj+i)=i;
    end
    for i=1:subj
        design(1,subj*2+i)=i;
    end
    design(2,1:subj)=1;
    design(2,subj+1:2*subj)=2;
    design(2,subj*2+1:3*subj)=3;
    
end