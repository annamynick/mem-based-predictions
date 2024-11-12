% check to see whether trials where people are unfamiliar with the scenes
% still show the priming effect.
% jul 2024


clear all; close all; clc;

Experiments = {'Experiment1','Experiment3','Experiment6',...
    'PilotA','PilotB','PilotC'};


all = [];


for e = 1:numel(Experiments)
    Experiment = Experiments{e};

    lfd = readtable(['tda_lf_' Experiment]);
    nos = lfd(strcmp(lfd.familiarityTarget,'no'),:); % only take no to target
    nos = nos(ismember(nos.condition,[1 2]),:); % only take ss and neu (1 and 2)

    if ~isequal(unique(nos.condition),[1;2])
        error('unexpected condition got in')
    end 

    % each participant needs a median rt for each condition
    if any(isnan(nos.rt))
        error('nans in nos')
    end

    % Group the data by subject_id and condition 
    group_vars = {'subject_id', 'condition'};
    median_rts_table = groupsummary(nos, group_vars, 'median', 'rt');

    % tested to see what happens if I delete all the exemplars for one
    % condition (ans: only the outcome for the included condition is listed)

    % Count the number of unique conditions per subject
    complete_subjs_table = groupcounts(median_rts_table,"subject_id","none");
    complete_subjs = complete_subjs_table.subject_id(complete_subjs_table.GroupCount==2); % only take full participants

    % Filter the median_rts table by participants who should be included
    filtered_median_rts = median_rts_table(ismember(median_rts_table.subject_id, complete_subjs), :);

    % Display the filtered results
    disp(filtered_median_rts);


    % Unstack the table to create wide format
    wide_table = unstack(filtered_median_rts, 'median_rt', 'condition','GroupingVariables','subject_id');
    wide_table.Properties.VariableNames{'x1'} = 'ss';
    wide_table.Properties.VariableNames{'x2'} = 'neu';

    all = [all; wide_table];

end

subject_ids = all.subject_id;
avg_median = mean([all.ss all.neu],2); % get each participant mean across conds
big_outliers = get_outliers(avg_median,3); % 3 standard devs 
all(find(big_outliers == 1),:) = []; % whittle down all based on exclusions

median_rts = [all.ss all.neu];
bar_with_lines([all.ss all.neu])
xticklabels = {'Same-scene','Neutral'};

[H,P,CI,STATS] = ttest(all.ss,all.neu)
cohens_d = mean(all.ss - all.neu) / ...
                      std([all.ss; all.neu])

writematrix(median_rts,'../../data-mats/rp_nofamiliarity_w_exclus.csv')