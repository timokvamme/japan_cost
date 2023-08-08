close all
clear

id = input('Subject ID: ', 's');

% filename = sprintf('../results/Sub_%s/%s_Filled_duration_psy.mat', id, id);

fn = dir(sprintf('../results/Sub_%s/%s_Filled_duration_psy_*.mat', id, id));
load([fn.folder '/' fn.name]);

data.PMs(1).paramsFree = [1 1 0 0];
r = CHToolbox_PMF_Analysis(data, true);