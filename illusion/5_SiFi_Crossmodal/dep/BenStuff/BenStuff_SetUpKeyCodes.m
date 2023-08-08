function KeyCodes=BenStuff_SetUpKeyCodes
% KeyCodes=BenStuff_SetUpKeyCodes
% 
% outputs a struct containing Keycodes
% 
% uses PTB code
% nicked and modified from Sam 11/2014
%
% found a bug? please let me know!
% benjamindehaas@gmail.com
%

KbName('UnifyKeyNames');

Foo=BenStuff_PTB_Stamp;
IsWin=Foo.WhichMachine.windows;

% Setup keycode structure for typical keys
KeyCodes.Left = KbName('leftarrow');
KeyCodes.Up = KbName('uparrow');
KeyCodes.Right = KbName('rightarrow');
KeyCodes.Down = KbName('downarrow');
KeyCodes.Space = KbName('space');
KeyCodes.Enter = KbName('return');
KeyCodes.Esc = KbName('escape');
KeyCodes.Escape = KbName('escape');

if IsWin
    KeyCodes.Backspace = KbName('BackSpace');
end



