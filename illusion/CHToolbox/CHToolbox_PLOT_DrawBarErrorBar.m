function CHToolbox_BASIC_DrawBarErrorBar(data_mean, data_std, chart_config)
	
figure;
bar(data_mean);

hold on;
ngroups = size(data_mean, 1);
nbars = size(data_mean, 2);
groupwidth = min(0.8, nbars/(nbars+1.5));

if ~isempty(data_std)
	hold on;
	for i = 1:nbars
		x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
		errorbar(x, data_mean(:,i), data_std(:,i), 'b', 'Linestyle', 'None');
	end
end

hold on;

if isfield(chart_config, 'xlabel')
	xlabel(chart_config.xlabel);
end

if isfield(chart_config, 'ylabel')
	ylabel(chart_config.ylabel);
end

if isfield(chart_config, 'ctg')
	set(gca, 'XTickLabel', chart_config.ctg);
end

if isfield(chart_config, 'ttl')
	title(chart_config.ttl);
end

if isfield(chart_config, 'lgd')
	legend(chart_config.lgd);
end

hold off;


end