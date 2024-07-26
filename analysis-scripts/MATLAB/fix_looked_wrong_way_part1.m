function [trial_contindata, contindata, fixed_look_wrong_way, zero_intercept_lww] = fix_looked_wrong_way_part1(trial_contindata, contindata ,t)
% Take in continous data for one trial, plus the continuous data overall,
% and (1) ammend the trial data to lopp off timepoints where the subject
% was looking the wrong way (2) lopp off those same time points in the
% corresponding continuous data (3) report the wrong-way intercept for the
% trial, so that rt can be calculated for this trial based on that
% timepoint
% t = trial number 

[zero_intercept_lww, trial_contindata] = find_zero_intercept(trial_contindata);
if ~isnan(zero_intercept_lww)
    timepoints_to_eliminate = size(contindata(contindata.trialIdx == t,:),1) - size(trial_contindata,1);
    contindata_inds = find(contindata.trialIdx == t);
    contindata(contindata_inds(1:timepoints_to_eliminate),:) = [];
    contindata(contindata.trialIdx == t,:) = trial_contindata; % put trial contindata (fixed) in place of contin data
    fixed_look_wrong_way = 1; % mark which trials are fixed wrong way
else 
    fixed_look_wrong_way = 0;
end

end % end function
