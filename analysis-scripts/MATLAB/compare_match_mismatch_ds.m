% Are different scene responses that happen to have the same congruent
% answer faster?
% Nov 3 2023

% command from analyze_tasks: save('compare_match_mismatch_ds.mat','keep_subjs','rts','conditions','image_pairs','target_sides','exclusion_binary')

clear all; close all; clc
mats_dir = '../data-mats/';
% Import tidied task data from experiment 1
load([mats_dir 'compare_match_mismatch_ds.mat'])
scene_info = readtable('scene_info.xlsx');

% Filter only to different scene responses

nan_indices = isnan(exclusion_binary);
exclusion_binary(nan_indices) = 0;
inclusion_binary = ~exclusion_binary;
inclusion_binary(conditions' ~= 3) = 0; % don't include non-ds trials

% Find different - scene responses where the different scene happens to
% have the correct answer

med_cong_rts = nan(numel(keep_subjs),1);
med_incong_rts = nan(numel(keep_subjs),1);

for s = 1:numel(keep_subjs)
    if ~keep_subjs(s)
        continue
    end

    disp(['subj: ' num2str(s)])

    cong_rts = [];
    incong_rts = [];

    for t = 1:144
        if inclusion_binary(t,s) == 1

            disp(['subj: ' num2str(s) ' trial: ' num2str(t)])

            % Figure out whether the target_side was open or closed (correct
            % answer)
            target_name = image_pairs{t,2,s};
            target_open_side = scene_info.open_side{strcmp(scene_info.scene_name, target_name)};

            % Figure out whether the different scene target_side was open or
            % closed
            prime_name = image_pairs{t,1,s};
            prime_open_side = scene_info.open_side{strcmp(scene_info.scene_name, prime_name)};
            
            disp(['image pair: prime: ' prime_name ' target: ' target_name])
            disp(['prime open side: ' prime_open_side ' target open side ' target_open_side])

            % If open sides match, add to congruent rts; else add to
            % incongruent rts
            if strcmp(prime_open_side,target_open_side)
                cong_rts = [cong_rts; rts(s,t)];
            else
                incong_rts = [incong_rts; rts(s,t)];
            end

            med_cong_rts(s) = median(cong_rts);
            med_incong_rts(s) = median(incong_rts);

        end
    end
end

% remove nans 
med_cong_rts = med_cong_rts(~isnan(med_cong_rts));
med_incong_rts = med_incong_rts(~isnan(med_incong_rts));

nobs = numel(med_cong_rts);
figure()


% stats 
[~, pval, ttestci, stats] = ttest(med_cong_rts, med_incong_rts);


% save for current bio supplemental submission 
bar_data = [mean(med_cong_rts) mean(med_incong_rts)];
scatter_data = [med_cong_rts med_incong_rts]; 
pval_between_bars = pval; 
x_labels = {'same layout', 'opposite layout'};
save([mats_dir 'cb_supp_match_mismatch_ds_data.mat'],'bar_data','scatter_data','pval_between_bars','x_labels');

bar([mean(med_cong_rts) mean(med_incong_rts)],'EdgeColor','k','FaceColor','w')
xticklabels({'same layout', 'opposite layout'})
hold on
scatter(ones(nobs,1), med_cong_rts, 15, ...
    'filled', ...
    'MarkerFaceColor',hex2rgb('989798'), ...
    'MarkerFaceAlpha',.3); 
scatter(2 * ones(nobs,1), med_incong_rts, 15, ...
    'filled', ...
    'MarkerFaceColor',hex2rgb('989798'), ...
    'MarkerFaceAlpha',.3); 

for i = 1:nobs
    hold on
    disp(med_cong_rts(i))
    plot([1 2], [med_cong_rts(i), med_incong_rts(i)],'Color',[.3 .3 .3])
end 


set(gca,'TickDir','out', ...
    'FontSize',9, ...
    'FontName','Helvetica', ...
    'Box','off', ...
    'LineWidth',.5, ...
    'XColor','k', ...
    'YColor','k')

ylabel('Response Time (s)')

set(gcf, ...
        'Units', 'inches', ...
        'Position',  [0   0   2.8   2.8], ...
        'PaperSize', [2.9 2.9]);
print(gcf,['~/Desktop/compare_match_mismatch_ds'],'-dpdf','-vector')

