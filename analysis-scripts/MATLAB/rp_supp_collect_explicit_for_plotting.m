clear all; close all; clc

E1 = load('../data-mats/explicit_Experiment1.mat');
E6 = load('../data-mats/explicit_Experiment6.mat'); % glob rev 

max_length = 40;
E1_nanpad = nanpad(E1.explicit_acc', max_length) * 100;
E6_nanpad = nanpad(E6.explicit_acc', max_length) * 100;

all_explicit_acc_pct = [E1_nanpad  E6_nanpad];

writematrix(all_explicit_acc_pct,'../data-mats/explicit_acc_pct_E16.csv')
