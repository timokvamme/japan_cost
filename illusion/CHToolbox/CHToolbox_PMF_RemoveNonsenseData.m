function [PM] = CHToolbox_PMF_RemoveNonsenseData(PM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% used to remove the nonsense but space consuming parts in the PM structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fields = {'LUT', 'posteriorTplus1givenSuccess', 'posteriorTplus1givenFailure'};
PM = rmfield(PM, fields);

end