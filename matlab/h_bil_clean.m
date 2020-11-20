function h_bil_clean(subjectName)

% decluttering files to optimise space :)

file_list{1}        = ['P:/3015079.01/data/' subjectName '/preproc/' subjectName '_firstcuelock_raw_dwnsample.mat'];
file_list{2}        = ['P:/3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_preICA.mat'];
file_list{3}        = ['P:/3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAcomp.mat'];
file_list{4}        = ['P:/3015079.01/data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean.mat'];
file_list{5}        = ['P:/3015079.01/data/' subjectName '/preproc/' subjectName '_firstRej_trialInfo.mat'];

for nf = 1:length(file_list)
    fprintf('deleting %s\n',file_list{nf});
    if ismac
        system(['rm ' file_list{nf}]);
    else
        delete(file_list{nf});
    end
end