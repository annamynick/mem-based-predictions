% New approach to analyze tasks which collects all participant data into a
% giant data structure, then performs exclusions, then performs stats and
% calculations. Designed in particular to also produce longform data that
% can be used in linear mixed effects models.
% formerly "analyze_tasks_2.m" 

clear all; close all; clc;
expt = 'PilotC'; % !! specify Experiment here:

% Experiment1:  Same-scene, Neutral, Different-scene
% Experiment2:  Unfamiliar scenes
% Experiment3:  Arrows
% Experiment 6: Same,Neu,Spatially displaced (N.B. This is "Experiment 4"
% in the manuscript) 
% PilotA: pilot data 
% PilotB: pilot data 
% PilotC: pilot data 

% ------------------------- No edits needed beyond this point -------------


% ----- Part 1: Collect all participant data in one place, and tidy it ----

% Add paths (other toolboxes used)
addpath('hhentschke')% by Harald Hentschke, available at https://www.mathworks.com/matlabcentral/fileexchange/32398-hhentschke-measures-of-effect-size-toolbox
addpath('sigstar') % by Rob Campbell, available at https://www.mathworks.com/matlabcentral/fileexchange/39696-raacampbell-sigstar
% hex2rbg script: by Chad Greene, available at https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb

% Get logistics for expt
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
    case 'PilotA'
        datapath = '../../results/PilotA';
        path_info = readtable('path_info_PilotA.xlsx');
        ntrials = 144;
        nconds = 3;
        threshold_trial_exclusion = [72 36 36] * .5;
        condition_names = {'Same-scene','Neutral','ThirdCondition'};
    case 'PilotB'
        datapath = '../../results/PilotB/';
        path_info = readtable('path_info_PilotB.xlsx');
        ntrials = 144;
        nconds = 3;
        threshold_trial_exclusion = [72 36 36] * .5;
        condition_names = {'Same-scene','Neutral','ThirdCondition'};
    case 'PilotC'
        datapath = '../../results/PilotC/';
        path_info = readtable('path_info_PilotC.xlsx');
        ntrials = 144;
        nconds = 3;
        threshold_trial_exclusion = [72 36 36] * .5;
        condition_names = {'Same-scene','Neutral','ThirdCondition'};
    case 'Experiment6'
        datapath = '../../results/Experiment6';
        path_info = readtable('path_info_Experiment6.xlsx');
        ntrials = 144;
        nconds = 3;
        threshold_trial_exclusion = [72 36 36] * .5;
        condition_names = {'Same-scene spatially congruent','Neutral','Same scene spatially-displaced'};
end

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
    case 'PilotA'
        subject_ids = {'Q16','Q36','Q26','Q05','Q20','Q29','Q25','Q04','Q17','Q18', ...
            'member006_si','member001_si','Q14_2','Q34_2','Q31_2','Q28_2','Q37_2',...
            'Q19_2','Q08','Q35_2','member003_si','caro115','member015_si'}; 
    case 'PilotB'
        subject_ids = {'wyeth503','wyeth504','wyeth506','wyeth512','wyeth514', ...
            'wyeth518','wyeth519','wyeth520','wyeth527','wyeth526','wyeth537', ...
            'wyeth538','wyeth536','wyeth545','wyeth547','wyeth546','wyeth533', ...
            'wyeth553','wyeth558','wyeth555','wyeth557','wyeth561','wyeth551', ...
            'wyeth556','wyeth560','wyeth549','wyeth562','wyeth563','wyeth564', ...
            'wyeth498','wyeth565'};
    case 'PilotC'
        subject_ids = {'akers608', 'akers607', 'akers610', ...
            'akers611','akers612', 'akers613', 'akers614', 'akers615', ...
            'akers616','akers617', 'member001', 'akers618', 'akers619', ...
            'akers620', 'akers621', 'akers622', 'akers623', 'akers624', ...
            'akers625', 'akers297', 'akers626', 'akers627', 'akers628', ...
            'akers629', 'akers630', 'akers634', 'akers635', 'akers643'};
    case 'Experiment6' % new spat displaced
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

switch expt
    case 'Experiment1' % n = 26 (different-scene)
        session_format = {'remote','remote','remote','remote','remote','remote','remote','remote' 'remote' 'remote', ...
            'remote','remote','remote','remote','remote','remote','remote','remote','remote' ...
            ,'remote','remote','remote','remote','remote','remote','remote'};
    case {'Experiment3'} % n = 46 (arrows) % expt3-cont2
        session_format = {'remote','remote','remote', ...
            'inperson','inperson','inperson','inperson', ...
            'inperson','inperson','inperson','inperson','inperson', ...
            'inperson','inperson','inperson','inperson','inperson' ...
            'inperson','inperson','inperson','inperson','inperson', ...
            'inperson','inperson','inperson','inperson','inperson', ...
            'inperson','inperson','inperson','inperson','inperson', ...
            'inperson','inperson','inperson','inperson','inperson' ...
            'inperson','inperson','inperson','inperson','inperson', ...
            'inperson','inperson','inperson','remote'};
    case 'Experiment2' % n = 24 (unfamiliar-cont3)
        session_format = {'remote','remote','remote','remote'...
            'remote','remote','inperson','inperson','inperson','inperson','inperson','inperson'...
            'remote','inperson','inperson','inperson','inperson','inperson' ...
            'inperson','inperson','inperson','inperson','inperson','inperson'};
    case 'PilotA' % (glob rev og,'expt2')
        session_format = repmat({'remote'},1,length(subject_ids));
    case 'PilotB' % (loc rev og,'expt4')
        session_format = repmat({'inperson'},1,length(subject_ids));
    case 'PilotC'% (loc rev new,'expt4-rd')
        session_format = repmat({'inperson'},1,length(subject_ids));
    case 'Experiment6'% (loc rev new,'expt2-rd')
        session_format = repmat({'inperson'},1,length(subject_ids));
end

nsubjects = numel(subject_ids);

for s = 1:nsubjects
    subject_id = subject_ids{s};
    disp(subject_id);

    % Retrieve task data; add condition column where applicable
    switch expt
        case 'Experiment1'
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
        case 'PilotA'
            taskdata = readtable([datapath '/' path_info.task{strcmp(path_info.subject_id,subject_id)}]);
            taskdata.condition = get_taskdata_conditions(taskdata);
        case 'PilotB'
            suffix = return_path_info_suffix(path_info,subject_id,'task');
            taskdata = readtable([datapath '/' path_info.day2_extension{strcmp(path_info.subject_id,subject_id)} '_task' suffix]);
            taskdata.condition = convert_expt4_conds_to_doubles(taskdata);
        case 'PilotC'
            match = find(strcmp(path_info.subject_id, subject_id) & strcmp(path_info.day, 'Day 2'));
            suffix = path_info{match,3};
            taskdata = readtable([datapath '/' cell2mat(suffix) '_task.txt']);
            taskdata.condition = convert_expt4_conds_to_doubles(taskdata);
        case 'Experiment6'
            match = find(strcmp(path_info.subject_id, subject_id) & strcmp(path_info.day, 'Day 2'));
            suffix = path_info{match,3};
            taskdata = readtable([datapath '/' cell2mat(suffix) '_task.txt']);
            taskdata.condition = get_taskdata_conditions(taskdata);

    end
    taskdata = unique(taskdata); % get rid of any duplicate trials
    taskdata = sortrows(taskdata,'trialIdx'); % make sure trials are in order



    % get familiarity data
    switch expt
        case {'Experiment1','PilotA'}
            fdpath = [datapath '/' path_info.familiarity{strcmp(path_info.subject_id,subject_id)}];
            if ~exist([fdpath '.txt'])
                warning(['missing familiarity: ' subject_id])
                isMissingFamiliarity = 1;
            else
                isMissingFamiliarity = 0;
                fd = readtable([datapath '/' path_info.familiarity{strcmp(path_info.subject_id,subject_id)}]);
                fd = unique(fd);
                familiarity_data = fd.response;
                familiarity_scenes = fd.primeName;
            end
        case {'Experiment2'}
            isMissingFamiliarity = 1;
        case 'Experiment3'
            if isempty(path_info.day1_extension{strcmp(path_info.subject_id,subject_id)})
                warning(['missing familiarity: ' subject_id])
                isMissingFamiliarity = 1;

            else
                isMissingFamiliarity = 0;
                fd = readtable([datapath '/' path_info.day1_extension{strcmp(path_info.subject_id,subject_id)} '_familiarity']);
                fd = unique(fd);
                if any(contains(fd.Properties.VariableNames,'response')) % if the thing exists correctly labeled
                    familiarity_data = fd.response(1:18);
                    familiarity_scenes = fd.primeName(1:18);
                else
                    familiarity_data = fd.Var9(1:18);
                    familiarity_scenes = fd.Var2(1:18);
                end
            end
        case {'Experiment6','PilotC'}
            row = find(strcmp(path_info.day,'Day 1') & strcmp(path_info.subject_id, subject_id));
            fdpath = [datapath '/' path_info.datafile_extension{row} '_familiarity.txt'];
            if ~exist(fdpath,'file')

                warning(['missing familiarity: ' subject_id])
                isMissingFamiliarity = 1;
            else
                isMissingFamiliarity = 0;
                fd = readtable(fdpath);
                fd = unique(fd);
                if any(contains(fd.Properties.VariableNames,'response')) % if the thing exists correctly labeled
                    familiarity_data = fd.response(1:18);
                    familiarity_scenes = fd.primeName(1:18);
                else
                    familiarity_data = fd.Var9(1:18);
                    familiarity_scenes = fd.Var2(1:18);
                end
            end


        case {'PilotB'} % og loc rev (PilotB), new loc rev (PilotC)
            if isempty(path_info.day1_extension{strcmp(path_info.subject_id,subject_id)})
                warning(['missing familiarity: ' subject_id])
                isMissingFamiliarity = 1;

            else
                isMissingFamiliarity = 0;
                fd = readtable([datapath '/' path_info.day1_extension{strcmp(path_info.subject_id,subject_id)} '_familiarity']);
                fd = unique(fd);
                if any(contains(fd.Properties.VariableNames,'response')) % if the thing exists correctly labeled
                    familiarity_data = fd.response(1:18);
                    familiarity_scenes = fd.primeName(1:18);
                else
                    familiarity_data = fd.Var9(1:18);
                    familiarity_scenes = fd.Var2(1:18);
                end
            end

    end

    % map familiarity onto taskdata (familiarityPrime, familiarityTarget)
    if ~isMissingFamiliarity
        switch expt
            case {'Experiment1','Experiment6','PilotA'}
                fsn = [familiarity_scenes; {'neutral'}]; % familiarity scenes + neutral tacked on;
                fdn = [familiarity_data; {'na'}]; % familiarity data + na tacked on (corresponds to neutral)
                fam_idxs = cellfun(@(x) find(strcmp(fsn, x)), taskdata.primeName, 'UniformOutput',false); % scene numbers in terms of index in familiarity_scenes
                taskdata.familiarityPrime = cellfun(@(x) fdn{x}, fam_idxs, 'UniformOutput',false);

                fam_idxs = cellfun(@(x) find(strcmp(fsn, x)), taskdata.targetName, 'UniformOutput',false); % scene numbers in terms of index in familiarity_scenes
                taskdata.familiarityTarget = cellfun(@(x) fdn{x}, fam_idxs, 'UniformOutput',false);

            case {'Experiment3'}
                neu_idxs = find(contains(taskdata.primeName,'Neutral'));
                fsn = familiarity_scenes;
                fdn = [familiarity_data; {'na'}]; % familiarity data + na tacked on (corresponds to neutral)
                fam_idxs = cellfun(@(x) find(strcmp(fsn, x)), taskdata.primeName, 'UniformOutput',false); % scene numbers in terms of index in familiarity_scenes
                fam_idxs(neu_idxs) = {19};
                taskdata.familiarityPrime = cellfun(@(x) fdn{x}, fam_idxs, 'UniformOutput',false);

                fam_idxs = cellfun(@(x) find(strcmp(fsn, x)), taskdata.targetName, 'UniformOutput',false); % scene numbers in terms of index in familiarity_scenes
                taskdata.familiarityTarget = cellfun(@(x) fdn{x}, fam_idxs, 'UniformOutput',false);

            case {'PilotB','PilotC'}
                neu_idxs = find(contains(taskdata.primeName,'Neutral'));
                fsn = familiarity_scenes;
                fdn = [familiarity_data; {'na'}]; % familiarity data + na tacked on (corresponds to neutral)
                fam_idxs = cellfun(@(x) find(strcmp(fsn, x)), taskdata.primeName, 'UniformOutput',false); % scene numbers in terms of index in familiarity_scenes
                fam_idxs(neu_idxs) = {19};
                taskdata.familiarityPrime = cellfun(@(x) fdn{x}, fam_idxs, 'UniformOutput',false);

                taskdata.targetNameClean = cellfun(@(x) strrep(x,'_mirror',''), taskdata.targetName, 'UniformOutput', false); % so that the algorithm isnt confused by "_mirror"
                fam_idxs = cellfun(@(x) find(strcmp(fsn, x)), taskdata.targetNameClean, 'UniformOutput',false); % scene numbers in terms of index in familiarity_scenes
                taskdata.familiarityTarget = cellfun(@(x) fdn{x}, fam_idxs, 'UniformOutput',false);
                taskdata.targetNameClean = []; % remove field now that it's served its purpose

        end
    else
        taskdata.familiarityTarget = repelem({'missing'},height(taskdata),1);
        taskdata.familiarityPrime = repelem({'missing'},height(taskdata),1);
    end

    % add subject_id to table
    taskdata.subject_id = repmat({subject_id},1, height(taskdata))';

    % add session format to table
    taskdata.session_format = repmat({session_format{s}},1, height(taskdata))';

    % calculate scenewise explict accuracy memory (Experiment 1 only)
    taskdata.explicit_acc_scenewise_prime = nan(height(taskdata),1);
    taskdata.explicit_acc_scenewise_target = nan(height(taskdata),1);

    % Retrieve explicit acc (if applicable)
    switch expt
        case 'Experiment1'
            explicit_path = ['../../results/' expt '/' ...
                path_info.explicit{strcmp(path_info.subject_id,subject_id)}];
        case {'Experiment6','PilotC'}
            row = find(strcmp(path_info.day,'Day 2') & strcmp(path_info.subject_id, subject_id));
            explicit_path = [datapath '/' path_info.datafile_extension{row} '_explicit.txt'];
        case 'PilotA'
            explicit_path = ['../../results/PilotA/' ...
                path_info.explicit{strcmp(path_info.subject_id,subject_id)}];
        case 'PilotB'
            explicit_path =  [datapath '/' path_info.day2_extension{strcmp(path_info.subject_id,subject_id)} '_explicit'];
    end

    switch expt
        case {'Experiment1','Experiment6','PilotA','PilotB','PilotC'}

            explicitdata = readtable(explicit_path);
            explicitdata.Properties.VariableNames = {'sceneName','frontAngleYaw','displayYaw','snapshotSide','response','timestamp','rt'};
            explicitdata.isCorrect = strcmp(explicitdata.snapshotSide,explicitdata.response);
            for t = 1:height(taskdata)

                % for target image
                expl_inds = find(strcmp(explicitdata.sceneName,taskdata.targetName(t)));
                if numel(expl_inds) ~= 3
                    % warning(['incomplete explicit acc: ' taskdata.targetName{t}])
                else
                    taskdata.explicit_acc_scenewise_target(t) = ...
                        sum(explicitdata.isCorrect(expl_inds))/3;
                end

                % for prime image
                expl_inds = find(strcmp(explicitdata.sceneName,taskdata.primeName(t)));

                if strcmp(taskdata.primeName(t),'neutral')
                    continue
                end

                if numel(expl_inds) ~= 3
                    % warning(['incomplete explicit acc: ' subject_id ' ' taskdata.primeName{t}])
                else
                    taskdata.explicit_acc_scenewise_prime(t) = ...
                        sum(explicitdata.isCorrect(expl_inds))/3;
                end
            end
    end

    % Retreive continuous task data
    switch expt
        case {'Experiment1','PilotA'}
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
        case 'PilotB'
            suffix = return_path_info_suffix(path_info,subject_id,'taskContin');
            contindata = readtable([datapath '/' ...
                path_info.day2_extension{strcmp(path_info.subject_id,subject_id)} '_taskContin_' suffix]);
            contindata.Properties.VariableNames = {'trialIdx', 'primeName', 'targetName', 'targetSide', 'roll', 'pitch' ,'yaw', 'timestamp1', 'timestamp2', 'timestamp3'};
            contindata.targetAngleYaw = zeros(size(contindata,1),1); % corrects for the fact that in this expt there is no need to correct the original target angle (all panos are pre-rotated so that 0 = starting direction)
        case 'PilotC'
            match = find(strcmp(path_info.subject_id, subject_id) & strcmp(path_info.day, 'Day 2'));
            suffix = path_info{match,3};
            contindata = readtable([datapath '/' cell2mat(suffix) '_taskContin_.txt']);
            contindata.Properties.VariableNames = {'trialIdx', 'primeName', 'targetName', 'targetSide', 'roll', 'pitch' ,'yaw', 'timestamp1', 'timestamp2', 'timestamp3'};
            contindata.targetAngleYaw = zeros(size(contindata,1),1); % corrects for the fact that in this expt there is no need to correct the original target angle (all panos are pre-rotated so that 0 = starting direction)

    end

    [contindata] = add_fixed_columns(contindata, ntrials);
    cda.(subject_id) = contindata;
    sda.(subject_id) = taskdata;

    %Tidy data (1st pass, trial-level exclusions)
    [tda.(subject_id), ...
        ctda.(subject_id), ...
        ~, ...
        ~] ...
        = tidy_task_data(sda.(subject_id), cda.(subject_id), ntrials, expt);
    
    [~, ...
        ~, ...
        exclusion_mat, ...
        exclude_trial] ...
        = tidy_task_data(sda.(subject_id), cda.(subject_id), ntrials, expt);

    % just for the subjects who have missing taskdata 
    if size(sda.(subject_id),1) < ntrials
        % trim exclusion mat and exclude trial to correct size 
        has_trials = sda.(subject_id).trialIdx;
        exclusion_mat = exclusion_mat(has_trials,:); % exclusion mat is natively ntrials long
        exclude_trial = exclude_trial(has_trials);
        disp('Trimming exclusion mats to size for missing data ... ')
    end 
  

    % Then add exclusion details to SDA (for all participants) 
    sda.(subject_id).exclusion_mat = exclusion_mat;
    sda.(subject_id).exclude_trial = exclude_trial;


    % Calculate o/c accuracy of otherwise included trials
    correct = double(strcmp(sda.(subject_id).correctResponse,sda.(subject_id).response));
    incorrect = double(~correct);
    exclude_anyway = (sum(sda.(subject_id).exclusion_mat(:,[1:8 10:11]),2)) > 0 ; % see whether indices of not correct responses would have been excluded anyway
    correct(exclude_anyway == 1) = nan;
    incorrect(exclude_anyway == 1) = nan;
    oc_acc = (sum(correct==1))/(sum(~isnan(correct))); % overall accuracy

    % cycle through each of the conditions and calculate oc accuracy
    for c = 1:numel(condition_names)
        correct_for_cond = double((sda.(subject_id).condition == c)) .* correct;
        incorrect_for_cond = double((sda.(subject_id).condition == c)) .* incorrect;
        acc_for_condition = (sum(correct_for_cond==1))/(sum(correct_for_cond==1) + sum(incorrect_for_cond==1));
        tda.(subject_id).oc_acc_by_condition(tda.(subject_id).condition == c) = acc_for_condition; % add oc acc by condition to table
    end

    % add oc acc to table
    tda.(subject_id).oc_acc = repmat(oc_acc, height(tda.(subject_id)),1);

    % Tidy data (2nd pass, check if participant maintains enough data)
    switch expt
        case {'Experiment1','Experiment2','Experiment6','PilotA','PilotB','PilotC'}
            enough_data = sum(tda.(subject_id).condition == 1) >= threshold_trial_exclusion(1) ...
                & sum(tda.(subject_id).condition == 2) >= threshold_trial_exclusion(2) ...
                & sum(tda.(subject_id).condition == 3) >= threshold_trial_exclusion(3);
        case 'Experiment3'
            enough_data = sum(tda.(subject_id).condition == 1) >= threshold_trial_exclusion(1) ...
                & sum(tda.(subject_id).condition == 2) >= threshold_trial_exclusion(2) ...
                & sum(tda.(subject_id).condition == 3) >= threshold_trial_exclusion(3) ...
                & sum(tda.(subject_id).condition == 4) >= threshold_trial_exclusion(4);
    end

    % if enough data, keep subject; if not enough data, get rid of them in tidy data and mark them in sda
    if ~enough_data
        tda = rmfield(tda,{subject_id});
        sda.(subject_id).exclude_subject = repelem(1,height(sda.(subject_id)),1);
    else
        sda.(subject_id).exclude_subject = repelem(0,height(sda.(subject_id)),1);
    end

end

% Tidy data (3rd pass, remove outlier participants)

% separate rts by condition (subject x condition x trial)
tsubjs = fieldnames(tda); % tidied subject_ids (so far)
bar_groups = nan(numel(tsubjs), nconds, ntrials);
for s = 1:numel(tsubjs)
    subject_id = tsubjs{s};
    for c = 1:nconds
        [inds,~] = find(tda.(subject_id).condition == c); % get of the condition (tidied indices)
        [inds_a] = tda.(subject_id).trialIdx(inds); % get actual trial indexes for those trials
        bar_groups(s,c,inds_a) = tda.(subject_id).rt(inds);
    end
end

% find group-level outlier participants
median_rts = nanmedian(bar_groups,3); % subject x condition
median_rts_across_conds = nanmedian(bar_groups,[2 3]); % each subjs' median rt across conditions
group_median = nanmedian(bar_groups,'all');
group_stdev = nanstd(median_rts_across_conds);
lower_outliers = median_rts_across_conds < group_median - (2 * group_stdev);
upper_outliers = median_rts_across_conds > group_median + (2 * group_stdev);
outlier_inds = find(lower_outliers | upper_outliers);
outlier_names = tsubjs(outlier_inds); % subjs to remove (by name)
tda = rmfield(tda,outlier_names); % remove subjs from tda
for s = 1:numel(tsubjs)
    subject_id = tsubjs{s};
    if any(ismember(subject_id,outlier_names))
        sda.(subject_id).exclude_subject = repelem(1,height(sda.(subject_id)),1);
    end
end
clearvars bar_groups % removing because contains untidied remaining subjs
median_rts(outlier_inds,:) = [];
keeper_ids = tsubjs;
keeper_ids(outlier_inds,:) = [];
nkeepers = numel(keeper_ids);

% ----- Part 2: Collect relevant data for analysis (e.g. RTs) -------------

% Put data into longformat for mixed effects analysis
tda_long = [];
tsubjs = fieldnames(tda);
for s = 1:numel(tsubjs)
    subject_id = tsubjs{s};
    tda_long = [tda_long; tda.(subject_id)];
end

switch expt
    case 'Experiment3'
        tda_long.arrowValidity(tda_long.condition == 1 | tda_long.condition == 2) = {'valid'};
        tda_long.arrowValidity(tda_long.condition == 3 | tda_long.condition == 4) = {'invalid'};
        tda_long.primeCondition(tda_long.condition == 1 | tda_long.condition == 3) = {'Same-scene'};
        tda_long.primeCondition(tda_long.condition == 2 | tda_long.condition == 4) = {'Neutral'};
end


writetable(tda_long,['../../data-mats/tda_lf_' expt '.csv'])
save(['../../data-mats/sda_' expt '.mat'],'sda')

% Put median_rts into longformat (with participant ids) for ANOVA
conds = repelem(condition_names', nkeepers, 1);
expts = repelem({expt},numel(tsubjs) * nconds,1);
medrts = reshape(median_rts, nkeepers * nconds, []);
subjs = repmat(keeper_ids,nconds,1);
median_rts_long = table(expts,subjs,conds,medrts,'VariableNames',{'expt','subject_id','condition','median_rt'});
writetable(median_rts_long,['median_rts_lf_' expt '.csv'])


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
        % disp(['missing contin trial data for ' num2str(t)])
        continue
    end
    contindata.timestampfixed(inds) = seconds(contindata.timestamp2(inds) - contindata.timestamp2(inds(1)));
end
end

function conditions = convert_expt4_conds_to_doubles(taskdata)
% same idea as "get_taskdata_conditions", but for expt 4 (which has
% conditions written into output rather than as doubles (or conversions
% from "sameScenePrime" variable
conditions = nan(size(taskdata,1),1);
for i = 1:size(taskdata,1)

    if strcmp(taskdata.condition(i),'ss')
        conditions(i) = 1;
    elseif strcmp(taskdata.condition(i),'neutral')
        conditions(i) = 2;
    elseif strcmp(taskdata.condition(i),'mirror')
        conditions(i) = 3;
    end  % end if statement

end % end for statement
end % end funciton

