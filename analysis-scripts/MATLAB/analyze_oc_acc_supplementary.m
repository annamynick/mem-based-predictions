% % Jul 10 2023
% arm
% designed to address the PNAS reviewer comment:

% Related to comment no. 4: The analyses presented in the manuscript focus
% on RTs of correctly answered trials and the authors do not present
% accuracy data. If accuracy is not of central interest to the authors, it
% would still be useful to include details on the overall
% performance/accuracy.

clear all; close all; clc;

expts = {'Experiment1','Experiment2','Experiment3','Experiment6'};
expt_paper_names = {'Expt 1', 'Expt 2', 'Expt 3', 'Expt 4'};

padded_subj_number = 40; % so that there is enough room in my acc mtx 
acc = nan(numel(expts),padded_subj_number); % collect accuracies across expts; 

for e = 1:numel(expts)
    expt = expts{e};

    disp([expt]);
    disp(expt_paper_names{e})

    % load and prep data
    load(['exclusions_' expt '.mat'])
    
    nsubjs = sum(keep_subjs);
    ntrials = size(exclusion_mats,1);

    % Seems like there are two ways to do this analysis: (1) accuracy for
    % all 144 (or 216) trials, which is what is being done here, or (2)
    % accuracy for all the trials that are left in (after the other exclusions). 

    incorrect_response_layer = 9;
    incorrect_response_data = squeeze(exclusion_mats(:,incorrect_response_layer,keep_subjs)); % ntrials x nsubjects 
    pct_incorrect_responses = sum(incorrect_response_data)./ntrials;
    pct_correct_responses = (1 - pct_incorrect_responses) * 100;

    
    disp(['Mean percentage O/C accuracy: ' num2str(mean(pct_correct_responses),'%.2f')])
    disp(['SD percentage O/C accuracy: ' num2str(std(pct_correct_responses),'%.2f')])
    
    acc(e,1:nsubjs) = pct_correct_responses;

end


% plotting starts here   
n_expts = 4; 
ymean = nanmean(acc,2)';
bar(1:n_expts,ymean,'EdgeColor','k','FaceColor','w');
hold on;



x = repelem([1:numel(expts)],padded_subj_number)'; 
y = reshape(acc',[],1);





scatter(x,y,15, ...
    'filled', ...
    'MarkerFaceColor',hex2rgb('989798'), ...
    'MarkerFaceAlpha',.3, ...
    'XJitterWidth',.5, ...
    'XJitter','rand')

[~,p_ttest_e1,~,stats] = ttest(acc(1,:), 100/2); % test that the mean is different than chance (1/3: left, right, center)
[~,p_ttest_e2,~,stats] = ttest(acc(2,:), 100/2); % test that the mean is different than chance (1/3: left, right, center)
[~,p_ttest_e3,~,stats] = ttest(acc(3,:), 100/2); % test that the mean is different than chance (1/3: left, right, center)
[~,p_ttest_e4,~,stats] = ttest(acc(4,:), 100/2); % test that the mean is different than chance (1/3: left, right, center)


bar_data = ymean;
scatter_data = acc';
pval_data = [p_ttest_e1 p_ttest_e2 p_ttest_e3 p_ttest_e4];
mats_dir = '../../data-mats/';
save([mats_dir 'cb_supp_oc_data.mat'],'bar_data','scatter_data','expts','expt_paper_names','pval_data')



hold on
sigstar({[1]},p_ttest_e1);
sigstar({[2]},p_ttest_e2);
sigstar({[3]},p_ttest_e3);
sigstar({[4]},p_ttest_e4);


yline(50,'LineStyle',':') % line for chance 

ylim([0 105])
xticks([1:numel(expts)]); 
xticklabels({'Expt 1', 'Expt 2' 'Expt 3'})
yticks([0:.25:1]*100)

set(gca,'TickDir','out', ...
    'FontSize',9, ...
    'FontName','Helvetica', ...
    'Box','off', ...
    'LineWidth',.5, ...
    'XColor','k', ...
    'YColor','k')

ylabel('Open/Closed Accuracy (% correct)')
%axis square

set(gcf, ...
        'Units', 'inches', ...
        'PaperUnits', 'inches', ...
        'Position',  [0   0   2.7222   2], ...
        'PaperSize', [2.5 2.5]);
print(gcf,['~/Desktop/oc_acc_combined'],'-dpdf','-vector')

