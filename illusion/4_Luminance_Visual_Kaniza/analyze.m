close all
clear

id = input('Subject ID: ', 's');

fn = dir(sprintf('../results/Sub_%s/%s_Luminance_visual_kanizsa_*.mat', id, id));
all_data = load([fn.folder '/' fn.name]);

PM1 = all_data.data.PMs(1);
PM2 = all_data.data.PMs(2);

two_in_one = true;
if two_in_one
    % show two conditions in the same figure
    legends{1} = 'Kanizsa';
    legends{2} = 'Control';

    data.PMss{1} = PM1;
    data.PMss{2} = PM2;
    results = CHToolbox_PMF_Analysis_Free_2in1(data, legends, true);
else
    % show two conditions separately
    data.PMs(1) = PM1;
    data.PMs(2) = PM2;
    r = CHToolbox_PMF_Analysis(data, true);
end