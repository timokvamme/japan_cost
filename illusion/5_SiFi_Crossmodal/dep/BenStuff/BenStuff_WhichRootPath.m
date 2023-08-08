function [ RootPath, WhichScreen ] = BenStuff_WhichRootPath(SystemNo)
%[ RootPath, WhichScreen ] = BenStuff_WhichRootPath(SystemNo)
%   pings back path to dropbox depending on current system and initialises
%   randomisation as needed
% System options are: 
%   1) Room101 
%   2) MB_Air 
%   3) ThinkPad
%   4) Desktop

if SystemNo==1
    WhichScreen=2;
    DropBoxRoot=['C:\Documents and Settings\Anybody\My Documents\MATLAB\ben\']; %room 101
elseif SystemNo==2
    DropBoxRoot=['/Users/Ben/Dropbox/work in progress/']; %MB Air
    WhichScreen=0;
     rng('shuffle');%initialise random number generator
elseif SystemNo==3
    DropBoxRoot=['C:\Users\Ben\Dropbox\work in progress\']; %ThinkPad
    WhichScreen=1;
     rng('shuffle');%initialise random number generator
elseif SystemNo==4
    DropBoxRoot=['C:\Users\bdehaas\Dropbox\work in progress\']; %Desktop
    WhichScreen=0;
    
     rng('shuffle');%initialise random number generator
end

if eist(DropBoxRoot)
    RootPath=DropBoxRoot;
else
    error('Couldnt set up requested path - please double-check your system selection');
end
end

