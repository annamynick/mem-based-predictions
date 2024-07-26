function [explicit_acc, explicit_data] = analyze_explicit(subject_id, expt)

project_dir = '';

switch expt
    case {'Experiment1'}
        path_info = readtable('path_info_Experiment1.xlsx');
        explicit_path = ['../../results/Experiment1/' ...
            path_info.explicit{strcmp(path_info.subject_id,subject_id)}];
    case {'Experiment6'}
        path_info = readtable('path_info_Experiment6.xlsx');
        match = find(strcmp(path_info.subject_id, subject_id) & strcmp(path_info.day, 'Day 2'));
            suffix = path_info{match,3};
        explicit_path = ['../../results/Experiment6/' ...
            cell2mat(suffix) '_explicit.txt'];
end

if ~isequal(explicit_path,'~/Dropbox_Lab/projects/oculusGo/Experiments/bhpc-go/Results/') | ...
    exist(explicit_path,'file') % if the explicit thing isn't empty
    data = readtable(explicit_path);
    data.Properties.VariableNames = {'sceneName','frontAngleYaw','displayYaw','snapshotSide','response','timestamp','rt'};
    explicit_data = data; % output variable
    ntrials = size(data,1);

    % find overall accuracy
    correct_responses = zeros(ntrials,1);
    for i = 1:ntrials
        if strcmp(data.snapshotSide{i},data.response{i})
            correct_responses(i) = 1;
        end
    end
    explicit_acc = sum(correct_responses)/ntrials;
else % if explicit is empty
    explicit_acc = NaN;
end

