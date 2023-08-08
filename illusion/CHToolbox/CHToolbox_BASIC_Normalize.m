function [results] = CHToolbox_BASIC_Normalize(raw, target_range)

results = (raw - target_range(1)) ./ (target_range(2) - target_range(1));