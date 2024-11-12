function out = get_outliers(data, factor)
% This function takes in a vector of data and returns a binary vector indicating 
% outliers (outliers == 1) based on which participants are factor * std outside the average. 

out = zeros(size(data));
big_outliers = find(data > (mean(data) + (factor * std((data)))));
small_outliers = find(data < (mean(data) - (factor * std((data)))));

out(big_outliers) = 1;
out(small_outliers) = 1;

end 