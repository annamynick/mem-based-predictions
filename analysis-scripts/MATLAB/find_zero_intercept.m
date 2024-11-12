function [zero_intercept, contindata] = find_zero_intercept(contindata)
% takes a single trial of continuous data and returns whether the subject
% didnt turn sufficiently in the direction of the target

contindata.targetSide = contindata.targetSide * 80/90; % changing the center point of the target side
t_threshold = .300; %ms amount of time past target onset before looking for local minima - avoids catching trials where people havent turned yet

lmin = islocalmin(abs(contindata.yawfixed)); % one reason to make this local is some participants go back down toward the middle after answering
past_threshold_onset = contindata.timestampfixed > t_threshold;
lp = find(lmin .* past_threshold_onset,1,'first'); % find first instance of local minima past thresh onset (where person moves through 0 to correct a wrong turn)  

distbtwndatayaw = median(abs(diff(contindata.yawfixed)));
distbtwndatatime = median(abs(diff(contindata.timestampfixed)));

% % % plot(contindata.timestampfixed, contindata.yawfixed,'Color',[.3 .3 .3 .3]);
% % % hold on
% % % scatter(contindata.timestampfixed(lp),contindata.yawfixed(lp));
% % % xline(.100,'r')
% % % xlim([0 2.5])
% % %  

if isempty(lp)
    % cannot resolve turn intercept
    zero_intercept = nan;
    return
end
zero_intercept = contindata.timestampfixed(lp);
contindata = contindata(lp:end,:); % replace contin data with the shortened version (wrong way turn lopped off) 
contindata.timestampfixed = contindata.timestampfixed - contindata.timestampfixed(1); % shift data back in time so zero intercept aligns with time 0 (first timepoint), 
end 
