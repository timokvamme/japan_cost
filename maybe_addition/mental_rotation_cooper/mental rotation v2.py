# -*- coding: utf-8 -*-
"""
By Jonas Kristoffer Lindeløv.
3D Cube version in 2013.
Refactored to 2D Cooper figures in May, 2015.
"""

import random
import ppc
import time
import glob
import numpy as np
from psychopy import visual, event, core, gui, monitors, sound

"""
SET VARIABLES
"""
MON_WIDTH = 34.4  # in cm
MON_DISTANCE = 80  # in cm
MON_SIZE = [1366, 768]  # in pixels

KEYS_QUIT = ['escape']
MIRRORS = {'space': True, 'return': False}

# Stimulus attributes
IMAGE_SIZE = 3  # in degrees
CIRCLE_SIZE = 4.5  # circle diameter
IMAGE_EXCENTRICITY = 3  # distance from midline on x-axis in degrees
ANIMATION_DURATION = 45  # number of frames to animate feedback on error.
TEXT_POS = [0, 4]
TEXT_HEIGHT = 0.5

FOLDER_SAVE = 'data'
BREAK_TEXT = u'Tryk F for at fortsætte...'
BREAK_KEYS = ['f']
BREAK_INTERVAL = 20  # number of trials

TEXT_WELCOME = """Du vil blive vist to figurer, som  er ens eller spejlvendte. Tryk på ENTER hvis de er ens. Tryk på MELLEMRUM hvis de ikke er ens. Tryk "F" for "Fortsæt"..."""
TEXT_PRETEST = """Nu går selve eksperimentet i gang. Du skal først og fremmest svare korrekt. Gør det så hurtigt du overhovedet kan, men kun når du har det korrekte svar. Der gives ingen feedback i form af tekst, lyde, eller animerede rotationer. Der kommer pauser ind imellem. Tryk "F" for "Fortsæt"..."""
TEXT_TRAIN = """Nu kommer der en træning, hvor du skal fokusere på at lave en korrekt mental rotation og at svare rigtigt, frem for at svare hurtigt. Du får feedback på, om du svarer rigtigt eller forkert. Tryk "F" for "Fortsæt"..."""
TEXT_POSTTEST = """Nu starter eksperimentets sidste fase, hvor du igen skal svare så korrekt og hurtigt, som du overhovedet kan. Der er ingen feedback. Tryk "F" for "Fortsæt"..."""
TEXT_DEBFIEFING = """Tak for din deltagelse!"""


# Condition settings
repetitions = {'instruct':1, 'pretest': 1, 'posttest':1, 'training':80}  # number of repetitions per condition
                                                                                                    
rotations_test = range(0, 180+1, 15)   # in degrees             
rotations_train = [90]  # in degrees
stimuli_train = ['cooper_figures/D12.png', 'cooper_figures/E11.png']
stimuli_all = glob.glob('cooper_figures/*.png')

# Instruction trials: see below around line 125


"""
 INIT DIALOGUE
"""
# Intro-dialogue. Get subject-id and order.
V = {
    'id': '',
    'age':'',
    'gender':['male', 'female'],
    'condition': ['all', 'instruct', 'pretest', 'training', 'posttest']
}
if not gui.DlgFromDict(V).OK: 
    core.quit()


"""
 INITIATE PSYCHOPY STIMULI/STUFF
"""
my_mon = monitors.Monitor('testMonitor', width=MON_WIDTH, distance=MON_DISTANCE)
my_mon.setSizePix(MON_SIZE)
win = visual.Window(monitor=my_mon, units='deg', fullscr=True, color='black', allowGUI=False)

visual.Circle(win, radius=CIRCLE_SIZE / float(2), edges=256, pos=(-IMAGE_EXCENTRICITY,0), fillColor='white', lineColor=None).draw()
visual.Circle(win, radius=CIRCLE_SIZE / float(2), edges=256, pos=(IMAGE_EXCENTRICITY,0), fillColor='white', lineColor=None).draw()
circles = visual.BufferImageStim(win)
stim_text = visual.TextStim(win, pos=TEXT_POS, height=TEXT_HEIGHT, text='Tryk for at starte...')

# An ImageStim for each image and for each presentation location
stims_left, stims_right = {}, {}
for image in stimuli_all:
    stims_left[image] = visual.ImageStim(win, image=image, size=IMAGE_SIZE, pos=[-IMAGE_EXCENTRICITY, 0])
    stims_right[image] = visual.ImageStim(win, image=image, size=IMAGE_SIZE, pos=[IMAGE_EXCENTRICITY, 0])

# Other stuff
feedback_success = sound.Sound('A', octave=6, secs=0.1)
feedback_fail = sound.Sound('A', octave=4, secs=0.3)
writer = ppc.csvWriter(V['id'], FOLDER_SAVE)

# Calculate rotation sizes per frame to make a smooth sinusoidal rotation of 
# the stimulus
steps_raw = np.sin(np.pi * np.arange(ANIMATION_DURATION) / ANIMATION_DURATION)
steps_normalized = steps_raw / np.sum(steps_raw)

# Calculate number of total trials for progress reports
trials_test = len(stimuli_all)*repetitions['pretest']*len(MIRRORS)*len(rotations_test)
trials_train = len(stimuli_train) * repetitions['training'] * len(MIRRORS)*len(rotations_train)

"""
Functions
- makeTrialList
- makeStimulus
- runBlock
"""

def ask(text='', keyList=None):
    """
    Ask subject something. Shows question and returns answer (keypress)
    and reaction time. Defaults to no text and all keys.
    """
    # Draw the TextStims to visual buffer, then show it and reset timing immediately (at stimulus onset)
    stim_text.text = text
    stim_text.draw()
    time_flip = win.flip()  # time of core.monotonicClock.getTime() at flip

    # Halt everything and wait for (first) responses matching the keys given in the Q object.
    if keyList:
        keyList += KEYS_QUIT
    key, time_key = event.waitKeys(keyList=keyList, timeStamped=True)[0]  # timestamped according to core.monotonicClock.getTime() at keypress. Select the first and only answer.
    if key in KEYS_QUIT:  # Look at first reponse [0]. Quit everything if quit-key was pressed
        core.quit()
    return key, time_key - time_flip  # When answer given, return it.


def make_trial(condition, figure, mirror, rotation, instruction='', no=''):
    """ Returns a single trial with the canonical structure. """
    rotation_offset = random.randrange(0, 360)
    which_mirror = random.choice(['left', 'right'])
    
    return {
        'no': no,
        'id': V['id'],
        'condition': condition,
        'figure': figure,
        'mirror': mirror,
        'which_mirror': which_mirror,
        'rotation': rotation,
        'rotation_left': rotation_offset,
        'rotation_right': rotation_offset - rotation,
        'ans': '',
        'score': '',
        'rt': '',
        'time':'',
        'timeSecs':'',
        'instruction': instruction,
        'gender': V['gender'],
        'age': V['age']
    }

# Instruction trials. One for each figure
trial_list_instruct = [
    make_trial('instruct', figure='cooper_figures/D12.png', mirror=False, rotation=0, 
               instruction= u'Dette er den samme figur. Tryk derfor på ENTER.', no=1),
    make_trial('instruct', figure='cooper_figures/E11.png', mirror=True, rotation=0, 
               instruction= u'Dette er forskellige figurer. Tryk derfor på MELLEMRUM', no=2),
    
    make_trial('instruct', figure='cooper_figures/A6.png', mirror=False, rotation=40, 
               instruction= u'Dette er den samme figur, selvom den er roteret. Tryk derfor på ENTER. Den højre figur er altid roteret 0-180 grader, så du skal forestille dig, at du roterer den med uret for at se, om den er identisk eller spejlvendt i forhold til figuren til venstre.', no=3),
    make_trial('instruct', figure='cooper_figures/H20.png', mirror=False, rotation=160, 
               instruction= u'Dette er den samme figur, selvom højre figur er roteret. Tryk derfor på ENTER. Også denne er roteret med uret et sted mellem 0 og 180 grader.', no=4),
    make_trial('instruct', figure='cooper_figures/G16.png', mirror=True, rotation=160, 
               instruction= u'Dette er forskellige figurer. Tryk derfor på MELLEMRUM. Det er nemmere at se, hvis du mentalt roterer dem med uret, indtil de ville overlappe, hvis de overlapper mest muligt', no=5),
    
    make_trial('instruct', figure='cooper_figures/B8.png', mirror=False, rotation=40, 
               instruction= u'Lige tre figurers træning mere...', no=6),
    make_trial('instruct', figure='cooper_figures/F15.png', mirror=True, rotation=100, 
               instruction= u'', no=7),
    make_trial('instruct', figure='cooper_figures/C8.png', mirror=False, rotation=20, 
               instruction= u'', no=8)
]

def make_trial_list(condition):
    """ Make list of trials for a specified condition """
    trialList = []  # start with empty trial list

    # Factors that depend on condition
    if condition in ('pretest', 'posttest'):
        figures = stimuli_all
        rotations = rotations_test
    elif condition == 'training':
        figures = stimuli_train
        rotations = rotations_train
        
    # Loop through all combinations of these variables to make individual trials
    for figure in figures:
        for mirror in MIRRORS.values():
            for rotation in rotations:
                for repetition in range(repetitions[condition]):
                    trialList += [make_trial(condition, figure, mirror, rotation)]

    # Randomize order, number trials, and return.
    random.shuffle(trialList)
    for i, trial in enumerate(trialList):
        trial['no'] = i
    return trialList


def draw_stims(trial):
    """
    Draws circles, instruction, and stimuli with correct orientation/mirror.
    This is reasonably fast. Between 1 and 2 ms on my system.
    """
    circles.draw()

    # Select image an rotate
    stim_left = stims_left[trial['figure']]
    stim_right = stims_right[trial['figure']]
    stim_left.ori = trial['rotation_left']
    stim_right.ori = trial['rotation_right']
    
    # Draw left with/without mirror
    if trial['mirror'] and trial['which_mirror'] == 'left':
        stim_left.size *= [-1, 1]
        stim_left.draw()
        stim_left.size *= [-1, 1]  # reset
    else:
        stim_left.draw()
    
    # Draw right with/without mirror
    if trial['mirror'] and trial['which_mirror'] == 'right':
        stim_right.size *= [-1, 1]
        stim_right.draw()
        stim_right.size *= [-1, 1]  # reset
    else:
        stim_right.draw()
        

trials_elapsed = 0
def run_block(condition):
    """ # Run all trials of a specified condition """
    global trials_elapsed
    # The trial list!
    if condition == 'instruct':
        trial_list = trial_list_instruct
    else:
        trial_list = make_trial_list(condition)


    # Loop through trials
    for no, trial in enumerate(trial_list):
        # Set break text depending on condition. Wait for user to continue
        if not no % BREAK_INTERVAL:
            text_to_show = ''
            if no is not 0:
                # Prepare text on current progresss
                trials_total = round(100 * trials_elapsed / (trials_train + 2*trials_test))
                status_text = '\nDu har nu gennemført ' + str(trials_total) + ' %\n'
                
                # Prepare break text on timing for pretest/posttest
                if condition in ('pretest', 'posttest'):
                    time_diff = round(time.time() - trial_list[no - BREAK_INTERVAL]['timeSecs'], 1)
                    text_to_show += u'Din tid: ' + str(time_diff / BREAK_INTERVAL) + ' sekunder per svar!' + status_text
    
                # Training break text: proportion correct answer
                elif condition == 'training':
                    score = sum([previous_trial['score'] for previous_trial in trial_list[no - BREAK_INTERVAL:no]])
                    text_to_show += u'Du fik ' + str(int(100 * score / BREAK_INTERVAL)) + ' % korrekt!' + status_text
            
            # Display break
            circles.draw()
            text_to_show += '\nHusk ENTER for ens figurer. MELLEMRUM for spejlede figurer. Tryk F for at forsætte...'
            ask(text_to_show, BREAK_KEYS)
        
        # Prepare stimuli
        circles.draw()
        draw_stims(trial)
        
        # Show stimuli and wait for response.
        trial['timeSecs'] = time.time()
        trial['time'] = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
        key, rt = ask(trial['instruction'], MIRRORS.keys())
        if key in MIRRORS.keys():
            # Score and save trial
            trial['rt'] = rt * 1000
            trial['ans'] = MIRRORS[key]
            trial['score'] = MIRRORS[key] == trial['mirror']
            writer.write(trial)
            trials_elapsed += 1

            # Feedback during training and instruction
            if condition in ('training', 'instruct'):
                feedback_success.play() if trial['score'] else feedback_fail.play()
                if trial['rotation'] is not 0 and (condition == 'instruct' or not trial['score']):
                    steps = trial['rotation'] * steps_normalized
                    for step in steps:
                        trial['rotation_right'] += step
                        draw_stims(trial)
                        win.flip()
                    event.waitKeys()

"""
Actually run experiment.
Show instructions between blocks.
"""

ask(TEXT_WELCOME, BREAK_KEYS)

# Choose which section to run
if V['condition'] == 'all':
    run_block('instruct')

    ask(TEXT_PRETEST, BREAK_KEYS)
    run_block('pretest')
    
    ask(TEXT_TRAIN, BREAK_KEYS)
    run_block('training')
    
    ask(TEXT_POSTTEST, BREAK_KEYS)
    run_block('posttest')
else:
    run_block(V['condition'])

ask(TEXT_DEBFIEFING, BREAK_KEYS)