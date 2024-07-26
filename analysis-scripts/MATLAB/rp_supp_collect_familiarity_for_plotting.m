clear all; close all; clc; 

E1 = load('..//data-mats/familiarity_data_Experiment1.mat'); 
E3 = load('..//data-mats/familiarity_data_Experiment3.mat'); 
E6 = load('..//data-mats/familiarity_data_Experiment6.mat'); 

E1_yes_pct = calculate_yes_pct(E1);
E3_yes_pct = calculate_yes_pct(E3);
E6_yes_pct = calculate_yes_pct(E6);

max_length = 40;
E1_yes_pct_nanpad = nanpad(E1_yes_pct, max_length);
E3_yes_pct_nanpad = nanpad(E3_yes_pct, max_length);
E6_yes_pct_nanpad = nanpad(E6_yes_pct, max_length);

all_familiarity_pct = [E1_yes_pct_nanpad E3_yes_pct_nanpad E6_yes_pct_nanpad];

writematrix(all_familiarity_pct,'..//data-mats/familiarity_pct_E136.csv')


function yes_pct = calculate_yes_pct(Edata)
    fd_Edata = Edata.familiarity_data(Edata.keep_subjs == 1,:); % rows are subjects, columns are scenes
    
    % remove empty rows (empty subjs) 
    empties = any(cellfun(@isempty, fd_Edata),2);
    fd_Edata(empties == 1,:) = [];
    
    % now calculate yesses
    A = cellfun(@(x) strcmp(x,'yes'), fd_Edata, 'UniformOutput', false);
    yes_pct = (sum(cell2mat(A),2) / 18) * 100;
end 