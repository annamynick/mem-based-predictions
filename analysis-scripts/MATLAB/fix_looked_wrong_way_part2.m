function [taskdata, contindata, looked_wrong_way] = fix_looked_wrong_way_part2(zero_intercepts_lcw, zero_intercepts_lww, taskdata, contindata, looked_wrong_way, fixed_look_wrong_way)
% using corrected contindata, this function takes in contindata with
% wrong-way timepoints already chopped off, taskdata, and the full vectors
% of zero intercepts of trials when subject looked the correct/incorrect
% way (lcw,lww) and updates taskdata and contindata to adjust the lww to
% the average lcw 

% calculate correct yaw to set looked_wrong_ways to
left = zero_intercepts_lcw(taskdata.targetSide == -90);
right = zero_intercepts_lcw(taskdata.targetSide == 90);
% figure()
% hold on;
% scatter(left,1:108,100,'filled','MarkerFaceAlpha',.5,'MarkerFaceColor',hex2rgb('e6194b'))
% scatter(right,1:108,100,'filled','MarkerFaceAlpha',.5,'MarkerFaceColor',hex2rgb('3cb44b'))
% xlim([0 2.5])

avg_lcw_intercept_left = nanmean(left);
avg_lcw_intercept_right = nanmean(right);
% scatter(avg_lcw_intercept_left,109,150,'filled','MarkerFaceAlpha',.5,'MarkerFaceColor',hex2rgb('e6194b'),'MarkerEdgeColor','k','LineWidth',2)
% scatter(avg_lcw_intercept_right,109,150,'filled','MarkerFaceAlpha',.5,'MarkerFaceColor',hex2rgb('3cb44b'),'MarkerEdgeColor','k','LineWidth',2)
% xlim([0 2.5])
% ylim([0 112])
% yticklabels([])

for t = 1:max(taskdata.trialIdx)
    if fixed_look_wrong_way(t)
        
        if taskdata.targetSide(t) == -90
            taskdata.rt(t) = taskdata.rt(t) - zero_intercepts_lww(t) + avg_lcw_intercept_left;
            contindata.timestampfixed(contindata.trialIdx == t) = contindata.timestampfixed(contindata.trialIdx == t) + avg_lcw_intercept_left;
        elseif taskdata.targetSide(t) == 90
            taskdata.rt(t) = taskdata.rt(t) - zero_intercepts_lww(t) + avg_lcw_intercept_right;
            contindata.timestampfixed(contindata.trialIdx == t) = contindata.timestampfixed(contindata.trialIdx == t) + avg_lcw_intercept_right;
        end
        looked_wrong_way(t) = 0;
    end
end

end % end function 
