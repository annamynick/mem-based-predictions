% Main script that analyzes median RT for all the memory-based-predictions
% experiments. 
% Written by Anna Mynick 2023

% To run: specify which Experiment's data you would like to analyze. Note
% that Experiments are marked differently in code (using "expt" or "cont")
% than in the corresponding manuscript, as follows:


clear all; close all; clc;
expt = 'Experiment6'; % !! specify Experiment here:
% Experiment1:  Same-scene, Neutral, Different-scene 
% Experiment2:  Unfamiliar scenes
% Experiment3:  Arrows
% Experiment6: Same-scene, Neutral, Same scene spatially displaced
% (Experiment 4 in MS) 

% ============== No edits needed beyond this point ========================

% Add paths (other toolboxes used)
addpath('hhentschke')% by Harald Hentschke, available at https://www.mathworks.com/matlabcentral/fileexchange/32398-hhentschke-measures-of-effect-size-toolbox
addpath('sigstar') % by Rob Campbell, available at https://www.mathworks.com/matlabcentral/fileexchange/39696-raacampbell-sigstar
% hex2rbg script: by Chad Greene, available at https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb

% Get logistics for expt;
switch expt
    case 'Experiment1'
        datapath = '../../results/Experiment1/';
        path_info = readtable('path_info_Experiment1.xlsx');
        ntrials = 144;
        nconds = 3;
        threshold_trial_exclusion = [72 36 36] * .5;
        condition_names = {'Same-scene','Neutral','Different-scene'};
    case 'Experiment3' 
        datapath = '../../results/Experiment3/';
        path_info = readtable('path_info_Experiment3.xlsx');
        ntrials = 216;
        nconds = 4;
        threshold_trial_exclusion = [108 36 36 36] * .5;
        condition_names = {'Same-scene valid','Neutral valid','Same-scene invalid' 'Neutral invalid'};
    case 'Experiment2'        
        datapath = '../../results/Experiment2/';
        path_info = readtable('path_info_Experiment2.xlsx');
        ntrials = 144;
        nconds = 3;
        threshold_trial_exclusion = [72 36 36] * .5;
        condition_names = {'Same-scene','Neutral','Different-scene'};
    case 'Experiment6'    
        datapath = '../../results/Experiment6/';
        path_info = readtable('path_info_Experiment6.xlsx');
        ntrials = 144;
        nconds = 3;
        threshold_trial_exclusion = [72 36 36] * .5;
        condition_names = {'Same-scene spatially congruent','Neutral','Same-scene spatially displaced'};
end
% Get subject_ids
switch expt
    case 'Experiment1' % n = 26 (different-scene)
        subject_ids = {'Q30','Q22','Q27','Q19','Q35','Q10','Q37','Q34' 'Q14' 'Q28', ...
            'Q31','Q21','Q18_2','Q29_2','member003_ds','Q26_2','Q38_2','Q36_2','Q16_2' ...
            ,'Q08_2','Q05_2','member006_ds','member001_ds','member010_ds','member015_ds','member014_ds'};
    case 'Experiment3' % n = 46 (arrows) 
        subject_ids = {'member007_new','member008_new','member010_new', ...
            'matisse320','matisse322','matisse323','matisse324', ...
            'matisse325','matisse326','matisse327','matisse328','matisse329', ...
            'matisse330','matisse331','matisse332','matisse335','matisse334' ...
            'matisse333','matisse336','matisse341','matisse342','matisse343', ...
            'matisse344','matisse351','matisse349','matisse350','matisse357', ...
            'matisse346','matisse352','matisse354','matisse355','matisse237', ...
            'matisse348','matisse360','matisse359','matisse361','matisse353' ...
            'matisse347','matisse363','matisse362','matisse367','matisse368', ...
            'matisse369','matisse370','matisse371','member003'};
    case 'Experiment2' % n = 24 (unfamiliar)
        subject_ids = {'member010_pilot','member008_pilot','member006_pilot','member001_pilot'...
            'member002_pilot','kahlo338_pilot','K1_i23','K2','K3','K4','K5','K6'...
            'member003','kahlo384','kahlo385','kahlo387','kahlo388','kahlo377' ...
            'kahlo380','kahlo381','kahlo389','kahlo390','kahlo382','kahlo383'};
    case 'Experiment6' % n=37 (spatially displaced) ('expt2-rd')
        subject_ids = {'degas711','degas713','degas716','degas714','degas715', ...
            'degas712','degas717','degas718','degas720', ...
            'degas721','degas722','degas723','degas724','degas725', ...
            'degas726','member012','degas727','degas645','degas297',...
            'degas989','degas728','degas729','degas730','degas731', ...
            'degas732','degas733','degas734','degas735','degas736', ...
            'degas737','degas738','degas751','degas752','degas754', ...
            'degas753','degas750','degas748','degas757','degas758',...
            'degas759','degas760','degas761','degas762','degas745'};
end

nsubjects = numel(subject_ids);

% Make giant matrices for all subject data
rts = nan(nsubjects,ntrials); % one row per subject
conditions = nan(numel(subject_ids),ntrials); % one row per subject
exclusion_mats = nan(ntrials, 11, nsubjects); % [missing_task_trial missing_contin_trial too_fast not_below_sd_thresh not_above_sd_thresh looked_wrong_way didnt_turn_enough incorrect_response];
exclusion_binary = nan(ntrials, nsubjects);
contindatas = nan(nsubjects,15000,3);
image_pairs = cell(ntrials,2,nsubjects);% cell array containing the [prime target] names
target_sides =  nan(nsubjects,ntrials);
familiarity_data = cell(nsubjects, 18);
correct_responses =  cell(nsubjects,ntrials);

for s = 1:nsubjects
    subject_id = subject_ids{s};
    disp(subject_id);
    % Retrieve task data; add condition column where applicable
    switch expt
        case {'Experiment1'}
            taskdata = readtable([datapath '/' path_info.task{strcmp(path_info.subject_id,subject_id)}]);
            taskdata.condition = get_taskdata_conditions(taskdata);
        case 'Experiment3'
            suffix = return_path_info_suffix(path_info,subject_id,'task_expt3');
            taskdata = readtable([datapath '/' path_info.day2_extension{strcmp(path_info.subject_id,subject_id)} '_task_expt3' suffix]);
            taskdata.Properties.VariableNames = {'trialIdx', 'primeName', 'primeAngleYaw', 'targetName', 'targetAngleYaw', 'targetSide', 'arrowDirection', 'condition', 'correctResponse', 'response', 'roll', 'pitch', 'yaw', 'rt', 'timestamp'};
        case 'Experiment2'
            suffix = return_path_info_suffix(path_info,subject_id,'task_cont2');
            taskdata = readtable([datapath '/' path_info.extension{strcmp(path_info.subject_id,subject_id)} '_task_cont2' suffix]);
            taskdata.Properties.VariableNames = {'trialIdx', 'primeName', 'primeAngleYaw', 'targetName', 'targetAngleYaw', 'targetSide', 'arrowDirection', 'sameScenePrime', 'correctResponse', 'response', 'roll', 'pitch', 'yaw', 'rt', 'timestamp'};
            taskdata.condition = get_taskdata_conditions(taskdata);
        case 'Experiment6'
            match = find(strcmp(path_info.subject_id, subject_id) & strcmp(path_info.day, 'Day 2'));
            suffix = path_info{match,3};
            taskdata = readtable([datapath '/' cell2mat(suffix) '_task.txt']);
            taskdata.condition = get_taskdata_conditions(taskdata);
    end

    % get familiarity data
    switch expt
        case {'Experiment1'}
            if isempty(path_info.familiarity{s})
                warning(['missing familiarity: ' subject_id])
            else 
                fd = readtable([datapath '/' path_info.familiarity{strcmp(path_info.subject_id,subject_id)}]);
                familiarity_data(s,:) = fd.response;
                familiarity_scenes(s,:) = fd.primeName;
            end 
            
            
        case 'Experiment3'
            if isempty(path_info.day1_extension{strcmp(path_info.subject_id,subject_id)})
                warning(['missing familiarity: ' subject_id])
            else
                fd = readtable([datapath '/' path_info.day1_extension{strcmp(path_info.subject_id,subject_id)} '_familiarity']);
                if any(contains(fd.Properties.VariableNames,'response')) % if the thing exists correctly labeled
                    familiarity_data(s,:) = fd.response(1:18);
                    familiarity_scenes(s,:) = fd.primeName(1:18);
                else
                    familiarity_data(s,:) = fd.Var9(1:18);
                    familiarity_scenes(s,:) = fd.Var2(1:18);
                end
            end
        case 'Experiment6'
            match = find(strcmp(path_info.subject_id, subject_id) & strcmp(path_info.day, 'Day 1'));
            day1_suffix = path_info{match,3}; 
            fd = readtable([datapath '/' cell2mat(day1_suffix) '_familiarity.txt']);           
            familiarity_data(s,:) = fd.Var9(1:18);
            familiarity_scenes(s,:) = fd.Var2(1:18);
    end

    % get image pairs
    image_pairs(taskdata.trialIdx,:,s) = [taskdata.primeName taskdata.targetName];

    % get target sides 
    target_sides(s,taskdata.trialIdx)= taskdata.targetSide;  

    % get correct responses (open or closed) 
    correct_responses(s,taskdata.trialIdx) = taskdata.correctResponse;

    % Retreive continuous task data
    switch expt
        case {'Experiment1'}
            contindata = readtable([datapath '/' path_info.taskcontin{strcmp(path_info.subject_id,subject_id)}]);
            contindata.Properties.VariableNames = {'trialIdx','primeName', 'targetName', 'targetAngleYaw', 'targetSide','roll','pitch','yaw','timestamp1','timestamp2','timestamp3'};
        case 'Experiment3'
            suffix = return_path_info_suffix(path_info,subject_id,'taskContin_expt3');
            contindata = readtable([datapath '/' path_info.day2_extension{strcmp(path_info.subject_id,subject_id)} '_taskContin_expt3' suffix]);
            contindata.Properties.VariableNames = {'trialIdx','primeName', 'targetName', 'targetAngleYaw', 'targetSide', 'arrowDirection', 'roll', 'pitch', 'yaw', 'timestamp1', 'timestamp2', 'timestamp3'};
        case 'Experiment2'
            suffix = return_path_info_suffix(path_info,subject_id,'taskContin_cont2');
            contindata = readtable([datapath '/' ...
                path_info.extension{strcmp(path_info.subject_id,subject_id)} '_taskContin_cont2' suffix]);
            contindata.Properties.VariableNames = {'trialIdx', 'primeName', 'targetName', 'targetAngleYaw', 'targetSide', 'arrowDirection', 'roll', 'pitch' ,'yaw', 'timestamp1', 'timestamp2', 'timestamp3'};
        case 'Experiment6'
            match = find(strcmp(path_info.subject_id, subject_id) & strcmp(path_info.day, 'Day 2'));
            suffix = path_info{match,3};
            contindata = readtable([datapath '/' cell2mat(suffix) '_taskContin_.txt']);
            contindata.Properties.VariableNames = {'trialIdx','primeName', 'targetName', 'targetAngleYaw', 'targetSide','roll','pitch','yaw','timestamp1','timestamp2','timestamp3'};
            contindata.targetAngleYaw = zeros(size(contindata,1),1); % corrects for the fact that in this expt there is no need to correct the original target angle (all panos are pre-rotated so that 0 = starting direction)
    end

    [contindata] = add_fixed_columns(contindata, ntrials);

    % Tidy data
    [taskdata, contindata, exclusion_mat, exclude_trials] = tidy_task_data(taskdata, contindata, ntrials, expt);
    exclusion_mats(:,:,s) = exclusion_mat; % trials x exclusion-type x subject
    exclusion_binary(:,s) = exclude_trials; % trials x subject (1 if trial is getting excluded)
    rts(s,~exclude_trials) = taskdata.rt; % subject x trial
    conditions(s,~exclude_trials) = taskdata.condition; % subject x trial
    contindatas(s,1:numel(contindata.timestampfixed),:) = [contindata.trialIdx contindata.timestampfixed contindata.yawfixed];

end % end 1:nsubjects

% Which subjects have enough remaining trials after tidying? (keep_subjs)
switch expt
    case {'Experiment1','Experiment2','Experiment6'}
        keep_subjs = sum(conditions == 1,2) >= threshold_trial_exclusion(1) ...
            & sum(conditions == 2,2) >= threshold_trial_exclusion(2) ...
            & sum(conditions == 3,2) >= threshold_trial_exclusion(3);
    case 'Experiment3'
        keep_subjs = sum(conditions == 1,2) >= threshold_trial_exclusion(1) ...
            & sum(conditions == 2,2) >= threshold_trial_exclusion(2) ...
            & sum(conditions == 3,2) >= threshold_trial_exclusion(3) ...
            & sum(conditions == 4,2) >= threshold_trial_exclusion(4);
end

% Update data based on keep_subjs (1st pass)
rts(keep_subjs == 0,:) = nan;
conditions(keep_subjs == 0,:) = nan;
exclusion_mats(:,:,keep_subjs == 0) = nan;
exclusion_binary(:,keep_subjs == 0) = nan;

% Separate rts by condition (subject x condition x trial)
bar_groups = nan(nsubjects, nconds, ntrials);
for c = 1:nconds
    m = nan(size(rts)); m(conditions == c) = rts(conditions == c);
    bar_groups(:,c,:) = m;
end

% Find subjects to remove based on variation from group median (2nd pass)
median_rts = nanmedian(bar_groups,3); % subject x condition
median_rts_across_conds = nanmedian(bar_groups,[2 3]); % each subjs' median rt across conditions
group_median = nanmedian(bar_groups,'all');
group_stdev = nanstd(median_rts_across_conds);
lower_outliers = median_rts_across_conds < group_median - (2 * group_stdev);
upper_outliers = median_rts_across_conds > group_median + (2 * group_stdev);

% Update keep_subjs and median_rts, and exclusion mats
keep_subjs(upper_outliers | lower_outliers) = 0;
median_rts(keep_subjs == 0,:) = []; % eliminate all rows of non-keep-subjs
exclusion_mats(:,:,(upper_outliers | lower_outliers)) = 1; 
exclusion_binary(:,(upper_outliers | lower_outliers)) = 1;
rts(keep_subjs == 0) = nan; 

% Figure out how many trials, for each condition, went into each
% participants calculation: [subject x condition]
n_included_trials = sum(~isnan(bar_groups),3);

% zscore participants' rts and find "dif_score" that way
zscored_dif_ss_neu = nan(numel(subject_ids),1);
for s = 1:numel(subject_ids)
   
        % for each condition, I want to all of one participants' rts. then i want to z-score those values. so I want a matrix that is subj x cond  
        ss = squeeze(bar_groups(s,1,:));
        neu = squeeze(bar_groups(s,2,:));

        ss(isnan(ss)) = [];
        neu(isnan(neu)) = [];

        ssz = zscore(ss);
        neuz = zscore(neu); 

        zscored_dif_ss_neu(s) = median(ssz) - median (neuz);   
end

% Calculate diff scores (something - neutral)
switch expt
    case {'Experiment1','Experiment2','Experiment6'}
        dif_scores = [median_rts(:,1) - median_rts(:,2)  median_rts(:,3) - median_rts(:,2)];  % ss - neu, cond3 - neu
        %         dif_score_names = {[condition_names{1} ' - ' condition_names{2}], [condition_names{3} ' - ' condition_names{2}]};
        dif_score_names = {condition_names{1}, condition_names{3}};
    case 'Experiment3'
        dif_scores = [median_rts(:,1) - median_rts(:,2)  median_rts(:,3) - median_rts(:,4)]; % ssv - neuv, ssi - neui
        %         dif_score_names = {[condition_names{1} ' - ' condition_names{2}], [condition_names{3} ' - ' condition_names{4}]};
        dif_score_names = {'Valid','Invalid'};

end

% Run pairwise T-tests between bars
pvals = nan(1,3);
pvals_corrected = nan(1,3);
cohens_d = nan(1,3);

switch expt
    case {'Experiment1','Experiment2','Experiment6'}
        ttest_bar_placement = {[1 2] [2 3] [1 3]};
        [~,pvals(1),ttestci_12,stats_12] = ttest(median_rts(:,1),median_rts(:,2)); % ss neu
        [~,pvals(2),ttestci_23,stats_23] = ttest(median_rts(:,2),median_rts(:,3)); % neu cond3
        [~,pvals(3),ttestci_13,stats_13] = ttest(median_rts(:,1),median_rts(:,3)); % ss cond3
        
        % stuff for bonferroni (if req): 
        ntests = 3; % [1 2] [2 3] [1 3]
        pvals_corrected = pvals * ntests;
        if strcmp(expt, 'Experiment6'), pvals_corrected = pvals; end

        % stuff for cohen's d 
        % "difference between the means of each group, all divided by the
        % standard deviation of the data"
        % from https://rcompanion.org/handbook/I_04.html
        cohens_d_12 = mean(median_rts(:,1) - median_rts(:,2)) / ...
                      std([median_rts(:,1); median_rts(:,2)]);
        cohens_d_23 = mean(median_rts(:,2) - median_rts(:,3)) / ...
                      std([median_rts(:,2); median_rts(:,3)]);
        cohens_d_13 = mean(median_rts(:,1) - median_rts(:,3)) / ...
                      std([median_rts(:,1); median_rts(:,3)]);
        
        cohens_d(1:3) = [cohens_d_12 cohens_d_23 cohens_d_13];

        % calculations for confidence interval 
        disp([expt ' confidence intervals:'])
        disp(['ttestci_12: CI[' num2str(ttestci_12(1), '%.2f') ','  num2str(ttestci_12(2), '%.2f') ']'])
        disp(['ttestci_23: CI[' num2str(ttestci_23(1), '%.2f') ','  num2str(ttestci_23(2), '%.2f') ']'])
        disp(['ttestci_13: CI[' num2str(ttestci_13(1), '%.2f') ','  num2str(ttestci_13(2), '%.2f') ']'])

    case 'Experiment3'
        ttest_bar_placement = {[1 2] [3 4] [1 4]}; % last bar placement shouldnt have anything
        [~,pvals(1),ttestci_12,stats_12] = ttest(median_rts(:,1),median_rts(:,2)); % ssv neuv
        [~,pvals(2),ttestci_34,stats_34] = ttest(median_rts(:,3),median_rts(:,4)); % ssi neui
        
        % stuff for bonferroni: 
        ntests = 6; % [1 2] [1 3] [1 4] [2 3] [2 4] [3 4] 
        pvals_corrected = pvals * ntests;

        % stuff for cohen's d 
        cohens_d_12 = mean(median_rts(:,1) - median_rts(:,2)) / ...
                      std([median_rts(:,1); median_rts(:,2)]);
        cohens_d_34 = mean(median_rts(:,3) - median_rts(:,4)) / ...
                      std([median_rts(:,3); median_rts(:,4)]);
        cohens_d(1:2) = [cohens_d_12 cohens_d_34];

         % calculations for confidence interval 
        disp([expt ' confidence intervals:'])
        disp(['ttestci_12: CI[' num2str(ttestci_12(1), '%.2f') ','  num2str(ttestci_12(2), '%.2f') ']'])
        disp(['ttestci_34: CI[' num2str(ttestci_34(1), '%.2f') ','  num2str(ttestci_34(2), '%.2f') ']'])        
end

% ==================== Save data-mats =====================================
mats_dir = '../../data-mats/';

% save the median Rts (stuff for bar plots) 
save([mats_dir 'median_rts_' expt '.mat'],'expt','keep_subjs','condition_names','subject_ids','median_rts','conditions')
save([mats_dir 'dif_scores_' expt '.mat'],'expt','keep_subjs','condition_names','subject_ids','dif_scores','conditions')

% save familiarity data
if ~strcmp(expt,'Experiment2')
    save([mats_dir 'familiarity_data_' expt '.mat'],'familiarity_data','familiarity_scenes','keep_subjs','subject_ids','expt')
end

% save exclusions data 
save([mats_dir 'exclusions_' expt '.mat'],'expt','keep_subjs','condition_names','subject_ids','median_rts','exclusion_mats','exclusion_binary')

% save rt data with image pairs
save([mats_dir 'rt_and_image_pairs_' expt '.mat'],'rts','conditions','image_pairs','correct_responses','keep_subjs','subject_ids','expt','exclusion_binary')

% calculate and save explicit memory versus difference scores (ss-ds, ss-neu)
switch expt
    case {'Experiment1','Experiment6'}
        dif_best_worst = median_rts(:,3)  - median_rts(:,1);
        dif_best_neu = median_rts(:,2)  - median_rts(:,1);

        explicit_acc = nan(size(subject_ids));
        for s = 1:numel(subject_ids)
            subject_id = subject_ids{s};
            if keep_subjs(s) == 1
                [explicit_acc(s),~] = analyze_explicit(subject_id, expt);
            end
        end
        explicit_acc = explicit_acc(keep_subjs); % get rid of empty (non-kept subj) entries
        n_included_trials = n_included_trials(keep_subjs,:);
        save([mats_dir 'priming_v_explicit_' expt '.mat'], 'explicit_acc','dif_best_worst','dif_best_neu','subject_ids','keep_subjs','n_included_trials')
        save([mats_dir 'explicit_' expt '.mat'],'explicit_acc')
end

% save match mismatch for Different-scene trials
switch expt
    case 'Experiment1'
        save([mats_dir 'compare_match_mismatch_ds.mat'],'keep_subjs','rts','conditions','image_pairs','target_sides','exclusion_binary')
end 

% ============================= Plots start here ==========================
switch expt
    case 'Experiment1'
        bar_colors =  {'#136289','#508AA8','#A0BCC5'};
    case 'Experiment3'
        bar_colors = {'#136289','#508AA8','#136289','#508AA8'};
    case 'Experiment2'
        bar_colors = {'#CE4C4C','#E77D6A','#FFB8A0'};
    case 'Experiment6'
        bar_colors =  {'#136289','#508AA8','#ADC5A0'};
end
bar_colors = cell2mat(arrayfun(@(x) hex2rgb(x), bar_colors', 'UniformOutput', false));

% Plot 1: Bar plot all conditions -----------------------------------------
do_bar_all_conds = 1;
if do_bar_all_conds
    figure();
    b = bar(mean(median_rts), ...
        'FaceColor','flat', ...
        'EdgeColor','flat', ...
        'LineWidth', .1, ...
        'BarWidth', .5);
    for i = 1:nconds
        b.CData(i,:) = bar_colors(i,:);
    end
    hold on;
    plot(1:nconds, median_rts', ...
        'Marker', 'o', ...
        'MarkerSize', 3, ...
        'Color', [hex2rgb('#D3D3D3') 0.5], ... % line color
        'MarkerFaceColor','None', ... % no option for alpha
        'MarkerEdgeColor', hex2rgb('#D3D3D3'), ...
        'LineWidth', .5)
    set(gca,'xtick',[], ...
        'TickDir','out', ...
        'FontSize',7, ...
        'FontName','Arial', ...
        'XColor','k',...
        'YColor','k',...
        'Box','off', ...
        'LineWidth',.5)%, ...

    ylabel('Reaction Time (s)')
    xticklabels(condition_names)
    xticks([1:nconds])
    xtickangle(0)
    yticks([.7:.1:1.7])
    ylim([.65 1.75])


    % just 2 p vals for expt 3 plots 
    if strcmp(expt,'Experiment3')
        sigstar(ttest_bar_placement(1:2),pvals_corrected([1 2]))
    else
        sigstar(ttest_bar_placement,pvals_corrected([1 2 3]))
    end 

    
    set(gcf, ...
        'Units', 'inches', ...
        'Position',  [0   0   1.7   2.5], ...
        'PaperSize', [2.5 2.5]);
    print(gcf,['../../plots/barsmall_' expt '_n' num2str(sum(keep_subjs))],'-dpdf','-vector')
    hold off
end

%  ================ Helper functions ======================================

function suffix = return_path_info_suffix(path_info,subject_id,file_type)
% Return the suffix "fixed" onto the filetype if path_info specifies that
% file needed fixing.

filenames_to_fix  = path_info.fixed{strcmp(path_info.subject_id,subject_id)};
if ~isempty(filenames_to_fix)
    strsplit(filenames_to_fix,',');
    if contains(filenames_to_fix,file_type)
        suffix = '_fixed';
    else
        suffix = '';
    end
else
    suffix = '';
end

end

function condition = get_trial_condition(data)

% Return trial condition of a specific index (one line of task data) 1 =
% same scene 2 = neutral 3 = cond3 (si or ds)
if data.sameScenePrime == 1
    condition = 1;
elseif strcmp(data.primeName,'neutral')
    condition = 2;
else
    condition = 3;
end
end % end function

function conditions = get_taskdata_conditions(taskdata)
% loop through taskdata for expts 1 or 2; for each trial, get return the
% condition (as a number)
conditions = nan(size(taskdata,1),1);
for i = 1:size(taskdata,1)
    conditions(i) = get_trial_condition(taskdata(i,:));
end
end

function [contindata] = add_fixed_columns(contindata, ntrials)
% add yawfixed and timestampfixed columns to contindata

contindata.yawfixed = contindata.yaw - contindata.targetAngleYaw;

for t = 1:ntrials
    inds = find(contindata.trialIdx == t);
    if isempty(inds)
        disp(['missing trial data for ' num2str(t)])        
        continue
    end
    contindata.timestampfixed(inds) = seconds(contindata.timestamp2(inds) - contindata.timestamp2(inds(1)));
end
end
