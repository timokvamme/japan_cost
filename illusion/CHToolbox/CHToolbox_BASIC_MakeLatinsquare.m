function [latinsquare] = CHToolbox_BASIC_MakeLatinsquare(N)

latinsquare = [1:N; ones(N-1, N)];
latinsquare = rem(cumsum(latinsquare)-1, N) + 1;