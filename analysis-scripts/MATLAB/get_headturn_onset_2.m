function [zero_intercept, contindata] = get_headturn_onset_2(contindata)
% takes a single trial of continuous data and returns whether the subject
% didnt turn sufficiently in the direction of the target

contindata.targetSide = contindata.targetSide * 80/90; % changing the center point of the target side

d = diff(contindata.yawfixed,2);
if contindata.targetSide < 0    
    [~,i] = min(d);
else 
    [~,i] = max(d);
end 



zero_intercept = contindata.timestampfixed(i);
if isempty(zero_intercept)
    % cannot resolve turn intercept
   zero_intercept = nan;
   return
end 

% if contindata.trialIdx < 50
%     hold on
% %     plot(contindata.timestampfixed,[0 0 d'],'r')
%     plot(contindata.timestampfixed,contindata.yawfixed,'Color',[.3 .3 .3 .3])
%     scatter(zero_intercept,contindata.yawfixed(i), 'b')
% end
% subplot(2,1,1);
% plot(contindata.timestampfixed(1:end-2),diff(contindata.yawfixed,2))

% subplot(2,1,2);
% plot(contindata.timestampfixed,contindata.yawfixed)
% hold on;
% scatter(contindata.timestampfixed(i),contindata.yawfixed(i),100,'filled')

end 

