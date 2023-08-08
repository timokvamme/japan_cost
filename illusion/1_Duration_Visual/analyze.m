close all
clear

id = input('Subject ID: ', 's');

% sbj_path = dir(sprintf('../results/unimodal/*%s', sbj_name));

fn = dir(sprintf('../results/Sub_%s/%s_Duration_visual_*.mat', id, id));
load([fn.folder '/' fn.name]);

data.PMs(1).ref_intensity = 0.5;
data.PMs(1).paramsFree = [1 1 0 0];
r = CHToolbox_PMF_Analysis(data, true);