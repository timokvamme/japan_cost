TrialTypeOrder = Results.TrialTypeOrder;
Answers = Results.Answers;

results = zeros(1, 6);
type_num = zeros(1, 6);
for i = 1:length(TrialTypeOrder(:, 1))
    types = TrialTypeOrder(i, :);
    answers = Answers(i, :);
    for j = 1:length(types)
        results(types(j)) = results(types(j)) + answers(j);
        type_num(types(j)) = type_num(types(j)) + 1;
    end
end

type_avg = results ./ type_num;
x = categorical([Results.Params.TrialTypeNames]);
figure;
% bar(x, type_avg);
bar(1:6, type_avg);
ylabel('Average perceived flash number');