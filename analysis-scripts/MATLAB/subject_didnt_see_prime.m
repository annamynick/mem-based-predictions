function started_off_center = subject_didnt_see_prime(contindata, threshold)
% takes a single trial of continuous data and returns whether the subject
% didnt turn sufficiently in the direction of the target
% threshold - double, indicates how close subject needs to have gotten to
% the prime at least once during the prime-on interval (i.e. how far off 
% they need to be before trial gets excluded) 

contindata.targetSide = contindata.targetSide * 80/90; % changing the center point of the target side
threshold_window = [-threshold threshold]; % [window_min window_max]
prime_offset_time = .300; %ms 

% correct the yaws based on target angle yaw 
yaw_fixed = contindata.yaw - contindata.targetAngleYaw;

% get trial time (within the trial, starting at 0 which marks prime onset)
contindata.timestampfixed = seconds(contindata.timestamp2 - contindata.timestamp2(1));

% find yaw points before and at prime offset to check
check_yaws = yaw_fixed(contindata.timestampfixed <= prime_offset_time);
in_window = (check_yaws >= threshold_window(1)) & (check_yaws < threshold_window(2));

% if theres not a single timepoint that falls within the threshold, mark the trial  
if sum(in_window) == 0
    started_off_center = 1;
    
%     plot(contindata.timestampfixed, yaw_fixed,'r')
%     hold on;
%     yline(contindata.targetSide(1),'b','LineWidth',2);
%     yline(threshold_window(1),'b--')
%     yline(threshold_window(2),'b--')
%     xline(prime_offset_time,'r','LineWidth',2)
%     
else 
    started_off_center = 0;
    
%     plot(contindata.timestampfixed, yaw_fixed,'b')
%     hold on;
%     yline(contindata.targetSide(1),'b','LineWidth',2);
%     yline(threshold_window(1),'b--')
%     yline(threshold_window(2),'b--')
%     xline(prime_offset_time,'r','LineWidth',2)
end

end 
