function looked_wrong_way = subject_looked_wrong_way_by_trial(contindata, threshold_off)
% takes a single trial of continuous data and returns whether the subject
% looked the wrong way. 
% threshold off: how many degrees in the wrong direction can a subject look
% without the trial being eliminated
contindata.targetSide = contindata.targetSide * 80/90; % changing the center point of the target side

% % % % threshold_off = 15; %previously 15
threshold = abs(contindata.targetSide) + threshold_off;

% correct the yaws based on target angle yaw 
yaw_fixed = contindata.yaw - contindata.targetAngleYaw;

% find how far the subjects' gaze is from the target image across time 
comparison = abs(yaw_fixed - contindata.targetSide); 

% record any trials where the subject is more than the threshold amount
% away from the target
if any(comparison > threshold)
    looked_wrong_way = 1;
else 
    looked_wrong_way = 0;
end

end 
