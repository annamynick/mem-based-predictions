function didnt_turn_to_target = subject_didnt_see_target(contindata, threshold)
% takes a single trial of continuous data and returns whether the subject
% didnt turn sufficiently in the direction of the target 
% threshold - double, how far subject can be from target (in either
% direction) during target-on timepoints

contindata.targetSide = contindata.targetSide * 80/90; % changing the center point of the target side
threshold_window = [contindata.targetSide(1) - threshold    contindata.targetSide(1) + threshold]; % [window_min window_max]
target_onset_time = .300; %ms 

% correct the yaws based on target angle yaw
yaw_fixed = contindata.yaw - contindata.targetAngleYaw;

% get trial time (within the trial, starting at 0 which marks prime onset)
contindata.timestampfixed = seconds(contindata.timestamp2 - contindata.timestamp2(1));

% find yaw points at and beyond target onset to check
check_yaws = yaw_fixed(contindata.timestampfixed > target_onset_time);
in_window = (check_yaws >= threshold_window(1)) & (check_yaws < threshold_window(2));

% record any trials that didn't have a timepoint where subject reached 
% within target window
if sum(in_window) == 0
    didnt_turn_to_target = 1;
%     
%     plot(contindata.timestampfixed, yaw_fixed,'r')
%     hold on;
%     yline(contindata.targetSide(1),'b','LineWidth',2);
%     yline(threshold_window(1),'b--')
%     yline(threshold_window(2),'b--')
%     xline(target_onset_time,'r','LineWidth',2)
else
    didnt_turn_to_target = 0;
%     
%     plot(contindata.timestampfixed, yaw_fixed,'b')
%     hold on;
%     yline(contindata.targetSide(1),'b','LineWidth',2);
%     yline(threshold_window(1),'b--')
%     yline(threshold_window(2),'b--')
%     xline(target_onset_time,'r','LineWidth',2)
end

end
