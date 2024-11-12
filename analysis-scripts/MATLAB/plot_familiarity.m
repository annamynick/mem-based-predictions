% jan 20 2023 
% arm 

clear all;
close all;
expts = {'Experiment1','Experiment3' 'Experiment6'}; % Expt1 missing 1; Expt 3 missing 3 subjects
expt_names = {'Expt 1', 'Expt 3', 'Expt 4'};
n_expts = numel(expts);
nscenes = 18;
nsubjs_est = 30; % number subjects estimation
pctmean = nan(1,n_expts);
pctsd = nan(1,n_expts);

addpath('../../data-mats/')

bar_data = nan(1,n_expts);
scatter_data = nan(nsubjs_est,n_expts);

for e = 1:numel(expts)
    expt = expts{e};
    load(['familiarity_data_' expt '.mat'])

    familiarity_data = familiarity_data(keep_subjs,:);
    emptyCells = cellfun(@isempty,familiarity_data);% https://stackoverflow.com/questions/3400515/how-do-i-detect-empty-cells-in-a-cell-array
    [i,j] = find(emptyCells);
    familiarity_data(unique(i),:) = [];
    
    famil_mtx = nan(size(familiarity_data)); % each row is a subject
    nsubjs = size(familiarity_data,1);
    
    famil_mtx(contains(familiarity_data,'yes')) = 1;
    famil_mtx(contains(familiarity_data,'unsure')) = 0;
    famil_mtx(contains(familiarity_data,'no')) = 0;

    pct_recognized = (sum(famil_mtx,2)./nscenes)*100;
    disp(['mean pct recognized ' expt ' : ' num2str(mean(pct_recognized))])
    pctmean(e) = mean(pct_recognized);

    disp(['sd pct recognized ' expt ' : ' num2str(std(pct_recognized))])
    pctsd(e) = std(pct_recognized);

    bar(e,pctmean(e),'EdgeColor','k','FaceColor','w');
    hold on;
    scatter(repelem(e,nsubjs),pct_recognized, ...
        15, ...
        'filled', ...
        'MarkerFaceColor',hex2rgb('989798'), ...
        'MarkerFaceAlpha',.3, ...
        'XJitterWidth',.5, ...
        'XJitter','rand')
    ylim([0 105]);
    hold on


    bar_data(e) = pctmean(e);
    scatter_data(1:length(pct_recognized),e) = pct_recognized;

end
mats_dir = '../../data-mats/';
save([mats_dir 'cb_supp_familiarity_data.mat'],'bar_data','scatter_data','expts','expt_names')

    set(gca,'TickDir','out', ...
                'FontSize',9, ...
                'FontName','HelveticaNeue', ...
                'Box','off', ...
                'LineWidth',.5, ...
                'XColor','k', ...
                'YColor','k')
xticks(1:numel(expts))
xticklabels(expt_names)
yticks(0:25:100)
ylabel('% Real-life Familiarity')
axis square

set(gcf, ...
        'Units', 'inches', ...
        'Position',  [0   0   2   2.8], ...
        'PaperSize', [2.5 2.5]);
print(gcf,['~/Desktop/familiarity'],'-dpdf','-vector')
