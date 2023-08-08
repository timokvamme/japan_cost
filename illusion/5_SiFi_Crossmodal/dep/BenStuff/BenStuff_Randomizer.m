function Choice=BenStuff_Randomizer(Options)
% Choice=BenStuff_Randomizer(Options)
% be a lazy bum and let the heavens decide
%
% 'Options' is a cellstring
%
% found a bug? please let me know
% benjamindehaas@gmail.com

if nargin<1
    Options={'Do a PostDoc', 'Develop that app and sell it to Google', 'Grow a beard, cycle India and never come back'};
end

rng('shuffle');%initialise random number generator

Options=Options(randperm(numel(Options)));%vectorise and re-order at random
Choice=Options{1};

end


