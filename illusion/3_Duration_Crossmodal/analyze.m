close all
clear

id = input('Subject ID: ', 's');

fn = dir(sprintf('../results/Sub_%s/%s_Duration_crossmodal_*.mat', id, id));
load([fn.folder '/' fn.name]);

data.PMs(1).ref_intensity = 0.3;
data.PMs(1).paramsFree = [1 1 0 0];
r = CHToolbox_PMF_Analysis(data, true);