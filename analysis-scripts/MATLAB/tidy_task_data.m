function [tidied_taskdata, tidied_contindata, exclusion_mat, exclude_trials] = tidy_task_data(taskdata, contindata, ntrials, expt)

% Global tidy
taskdata_duplicates = find(histcounts(taskdata.trialIdx,ntrials) > 1);
disp_if_not_empty('duplicates in taskdata: ', taskdata_duplicates)
taskdata_missing = setdiff(1:ntrials,taskdata.trialIdx);
disp_if_not_empty('missing in taskdata: ', taskdata_missing)
taskdata = unique(taskdata); % get rid of all *exactly* the doubled trials;
nonmatching_duplicates = (histcounts(taskdata.trialIdx,ntrials) > 1)';

% initialize exclusion criteria vectors
missing_task_trial = zeros(ntrials,1);
missing_contin_trial = zeros(ntrials,1);
too_fast = zeros(ntrials,1);
not_below_sd_thresh = zeros(ntrials,1);
not_above_sd_thresh = zeros(ntrials,1);
looked_wrong_way = zeros(ntrials,1);
didnt_see_prime = zeros(ntrials,1);
didnt_see_target = zeros(ntrials,1);
incorrect_response = zeros(ntrials,1);

fixed_look_wrong_way = zeros(ntrials,1);
zero_intercepts_lww = nan(ntrials,1); % looked wrong way
zero_intercepts_lcw = nan(ntrials,1); % looked correct way

for t = 1:ntrials
    trial_taskdata = taskdata(taskdata.trialIdx == t,:);
    trial_contindata = contindata(contindata.trialIdx == t,:);

    if isempty(trial_taskdata)
        missing_task_trial(t) = 1;
        disp(['missing task data: ' num2str(t) ])
    end

    if isempty(trial_contindata)
        missing_contin_trial(t) = 1;
    end

    % skip to the next trial if the task or contin data is missing
    if missing_task_trial(t) || missing_contin_trial(t)
        continue
    end

    % skip to the next trial if there were nonmatching duplicates for the
    % response
    if nonmatching_duplicates(t)
        continue
    end

    % Find responses that are too fast
    too_fast(t) = trial_taskdata.rt < .250;

    % Find responses that are 3sds from the mean in either direction
    not_below_sd_thresh(t) = trial_taskdata.rt > (mean(taskdata.rt)+(3 * std(taskdata.rt))); % 0 for slow, high rt responses
    not_above_sd_thresh(t) = trial_taskdata.rt < (mean(taskdata.rt)-(3 * std(taskdata.rt))); % 0 for fast, low rt responses

    % Find out if subject looked the wrong way
    looked_wrong_way(t) = subject_looked_wrong_way_by_trial(trial_contindata, 15);

    % Find timepoint when subject is facing zero (to apply avg value to
    % wrong ways later)
    if ~looked_wrong_way(t)
        zero_intercepts_lcw(t) = get_headturn_onset_2(trial_contindata); % find headturn onset in non-wrongway trials
    end

    % Find time of zero yaw intercept if subject looked wrong way; lopp off
    % extra timepoints in trial_data and contindata (needs to happen before
    % judging whether subject saw prime/target)
    if looked_wrong_way(t) && strcmp(expt,'Experiment3')
        [trial_contindata, contindata, fixed_look_wrong_way(t), zero_intercepts_lww(t)] = ...
            fix_looked_wrong_way_part1(trial_contindata, contindata, t);
    end

    % Did subject miss the prime?
    didnt_see_prime(t) = subject_didnt_see_prime(trial_contindata, 27.5);

    % Did subject miss the target?
    didnt_see_target(t) = subject_didnt_see_target(trial_contindata, 27.5);

    % Was response correct?
    incorrect_response(t) = ~strcmp(trial_taskdata.response,trial_taskdata.correctResponse);

end % end n trials

% Now that wrong-way continuous data has been lopped off, adjust rts for
% taskdata (and shift contindata based on lww/lcw)
if strcmp(expt,'Experiment3')
    [taskdata, contindata, looked_wrong_way] = fix_looked_wrong_way_part2(zero_intercepts_lcw, zero_intercepts_lww, taskdata, contindata, looked_wrong_way, fixed_look_wrong_way);
end

switch expt
    case {'Experiment1','Experiment3','Experiment2','Experiment6',...
            'PilotA','PilotB','PilotC'}
        not_first_exemplar = zeros(ntrials,1);
end

exclusion_mat = [...
    missing_task_trial ... % 1
    missing_contin_trial ... % 2    x
    too_fast ... % 3                x
    not_below_sd_thresh ... % 4     x
    not_above_sd_thresh ... % 5     x
    looked_wrong_way ... % 6        x
    didnt_see_prime ... % 7         x
    didnt_see_target ... % 8        x
    incorrect_response ... %9       x
    not_first_exemplar ... % 10     not used
    nonmatching_duplicates]; % 11

% make nans in locations where there are exclusions
exclude_trials = sum(exclusion_mat,2) > 0;

tidied_taskdata = taskdata(~exclude_trials,:);
tidied_contindata = contindata(ismember(contindata.trialIdx,find(~exclude_trials)),:);


end

function disp_if_not_empty(message,data)
if ~isempty(data)
    disp([message ': ' num2str(data)])
end
end

