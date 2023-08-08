# -*- coding: utf-8 -*-
"""
By Jonas Lindeløv (2013)

TO DO:
    * DONE: Intro trials
    * DONE: rotation offset on "other" axis
    * DONE: pretest-posttest condition
    * DONE: test on CDE
    * DONE: train on one specified stimulus
    * DONE: Rotate both ways?
    * DONE: Timing according to day
    * DONE: Unique filenames
    * DONE: Feedback on tests
    * DONE: Feedback during training
    * DONE: Better timing of stimulus presentations
"""

from psychopy import visual, event, core, gui, monitors, sound
from itertools import product
import random, os, csv, time

"""
SET VARIABLES
"""
monWidth = 38  # in cm
monDistance = 60  # in cm
traininingRepetitions = 40  # ... times 4 trials
breakInterval = 10

quitKeys = ['escape', 'esc']
ansKeys = ['space', 'return']  # [mirror-key, same-key]

textBreak = u'Tryk for at fortsaette...'

# Specified introduction trials
instructTrials = [
    ('b', 'depth', 'normal', 0, u'Dette er den samme figur. Tryk derfor på ENTER.'),
    ('c', 'depth', 'mirror', 0, u'Dette er forskellige figurer. Tryk derfor på MELLEMRUM'),
    ('d', 'plane', 'normal', 40, u'Dette er den samme figur, selvom den er roteret. Tryk derfor på ENTER'),
    ('c', 'plane', 'normal', 160, u'Dette er den samme figur, selvom den er roteret. Tryk derfor på ENTER'),
    ('d', 'depth', 'mirror', 160, u'Dette er forskellige figurer. Tryk derfor på MELLEMRUM.'),
    ('b', 'plane', 'normal', 40, u'Prøv selv...'),
    ('c', 'plane', 'mirror', 100, u''),
    ('d', 'depth', 'mirror', 20, u''),
    ('c', 'depth', 'normal', 140, u''),
    ('b', 'plane', 'mirror', 60, u'')
]


"""
 INIT DIALOGUE
"""
# Intro-dialogue. Get subject-id and order.
V = {
    'id': '',
    'condition': ['instruct', 'pretest', 'training', 'posttest'],
    'trainCube': ['b', 'c', 'd']
}
if not gui.DlgFromDict(V).OK: core.quit()


"""
 INITIATE PSYCHOPY STIMULI
"""
myMon = monitors.Monitor('testMonitor', width=monWidth, distance=monDistance)
win = visual.Window(monitor=myMon, units='deg', fullscr=True, color='black', screen=1)
imageLeft = visual.ImageStim(win, pos=(-6.5, 0), size=11)
imageRight = visual.ImageStim(win, pos=(6.5, 0), size=11)
visual.Circle(win, radius=6, edges=128, pos=(-7.5,0), fillColor='white', lineColor=None).draw()
visual.Circle(win, radius=6, edges=128, pos=(7.5,0), fillColor='white', lineColor=None).draw()
circles = visual.BufferImageStim(win)       
instruction = visual.TextStim(win, pos=(2,8), height=1, text='Tryk for at starte...')
feedbackRight = sound.Sound('A', octave=6, secs=0.1)
feedbackWrong = sound.Sound('A', octave=4, secs=0.3)
trialClock = core.Clock()


"""
Functions
- makeTrialList
- makeStimulus
- runBlock
"""

def makeTrialList(condition):   
    """ Make list of trials for a specified condition """

    # Factors that are the same across condition
    trialList = []
    axiss = ['depth', 'plane']
    mirrors = ['normal', 'mirror']
    figureRotations = range(0, 351, 10)  # 0, 10, 20, ..., 350

    # Factors that depend on condition
    if condition == 'instruct':
        allParameters = instructTrials
    if condition in ('pretest', 'posttest'):
        figures = ['b', 'c', 'd']
        rotations = range(-180, 181, 20) + [0]  # -180, -160, ..., -20, 0, 0, 20, 40, ..., 180

    if condition == 'training':
        figures = [V['trainCube']]
        rotations = [90] * traininingRepetitions

    # Do combinations of parameters and randomize order
    if condition != 'instruct':
        allParameters = list(product(figures, axiss, mirrors, rotations))
        random.shuffle(allParameters)

    # Loop through all combinations of these variables to make individual trials
    for no, trialParameters in enumerate(allParameters):
        # Fill in the basic information in the trial
        trial = {
            'id': V['id'],
            'condition': condition,
            'no': no,
            'cube': trialParameters[0],
            'axis': trialParameters[1],
            'mirrored': trialParameters[2],
            'rotation': trialParameters[3],
            'ans': '',
            'score': '',
            'rt': '',
            'time':'',
            'timeSecs':''
        }

        # Find some images that satisfies the conditions. Retries if these images do not exist (some images were removed because parts of the figure was occluded)
        trial['fileLeft'] = trial['fileRight'] = 'does not exist'
        while not os.path.isfile(trial['fileLeft']) or not os.path.isfile(trial['fileRight']):
            # Determine rotation of left and right image. Should be random within 0-350 degrees.
            trial['rotOffset'] = random.choice(range(0, 351, 10))  # Rotation for both figures on the "other" axis, the one not manipulated by trial['rotation']
            trial['rotLeft'] = random.choice(figureRotations)
            trial['rotRight'] = trial['rotLeft'] + trial['rotation']*random.choice([1,-1])  # Clockwise or counter-clockwise
            if trial['rotRight'] > 350: trial['rotRight'] -= 360
            if trial['rotRight'] < 0: trial['rotRight'] += 360

            # Determine filenames from syntax. Here e.g. "cubes/cube a depth 80 normal.png"
            if trial['axis'] == 'depth':
                trial['fileLeft'] = u'cubes/cube ' + trial['cube'] + ' depth ' + str(trial['rotLeft']) + ' normal.png'
                trial['fileRight'] = u'cubes/cube ' + trial['cube'] + ' depth ' + str(trial['rotRight']) + ' ' + trial['mirrored'] + '.png'
            if trial['axis'] == 'plane':
                trial['fileLeft'] = u'cubes/cube ' + trial['cube'] + ' depth ' + str(trial['rotOffset']) + ' normal.png'
                trial['fileRight'] = u'cubes/cube ' + trial['cube'] + ' depth ' + str(trial['rotOffset']) + ' ' + trial['mirrored'] + '.png'

        trialList += [trial]

    # All trials generated. Yay. Return the finished trialList
    return trialList

def makeStimulus(trial):
    """ Time consuming stimulus preparation (~300 ms) """

    # Prepare stimuli: set images
    imageLeft.setImage(trial['fileLeft'])
    imageRight.setImage(trial['fileRight'])

    # Prepare stimuli: set rotations
    if trial['axis'] == 'plane':
        imageLeft.setOri(trial['rotLeft'])
        imageRight.setOri(trial['rotRight'])
    if trial['axis'] == 'depth':
        imageLeft.setOri(trial['rotOffset'])
        imageRight.setOri(trial['rotOffset'])

    # Draw screen output
    circles.draw()
    imageLeft.draw()
    imageRight.draw()
    if trial['condition'] == 'instruct':
        instruction.setText(instructTrials[trial['no']][4])
        instruction.draw()

    # Take screenshot and return as stimulus
    stim = visual.BufferImageStim(win)
    win.clearBuffer()
    return stim

def runBlock(condition):
    """ # Run all trials of a specified condition """

    # The trial list!
    trialList = makeTrialList(condition)

    # Setting up data saving
    saveFolder = 'data'
    if not os.path.isdir(saveFolder): os.makedirs(saveFolder)                # Creates save folder if it doesn't exist
    saveFile = saveFolder + '/data_' + str(V['id']) +'_' + condition + '_(' +time.strftime('%Y-%m-%d %H-%M-%S', time.localtime()) +').csv'# Filename for csv. E.g. "templateData/data_subject1_pretest_(2013-04-15_14-00-10).csv"
    csvWriter = csv.writer(open(saveFile, 'wb'), delimiter=';').writerow     # The writer function to csv. Writes single rows at a time
    csvWriter(trialList[1].keys())                                         # Write headings to csv.

    # Prepare stimulus for the very first trial. Improves timing.
    stim = makeStimulus(trialList[0])

    # Loop through trials
    for no, trial in enumerate(trialList):
        # Set break text depending on condition. Wait for user to continue
        if no % breakInterval == 0 and no != 0:
            # Test: Time elapsed in seconds
            if condition in ('pretest', 'posttest'):
                timeDiff = round(time.time() - trialList[no - breakInterval]['timeSecs'], 1)
                instruction.setText('Din tid: ' + str(timeDiff) + ' sekunder!\n' + textBreak)

            # Trainin: proportion correct answer
            if condition == 'training':
                score = 0
                for prevtrial in trialList[no - breakInterval:no]:
                    score += prevtrial['score']
                instruction.setText('Du fik ' + str(int(100 * score / breakInterval)) + ' % korrekt!\n' + textBreak)

            # Display break: circles + text
            circles.draw()
            instruction.draw()
            win.flip()
            event.waitKeys()

        # Show stimuli and begin timer
        stim.draw()
        win.flip()
        trialClock.reset()
        trial['timeSecs'] = time.time()
        trial['time'] = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())

        # Improve timing by preparing stimuli for next trial (if this is not the last).
        # but assumes that setStimuli-time is shorter than answer-time!
        if no + 1 != len(trialList):
            stim = makeStimulus(trialList[no + 1])

        # Wait for response. Quit if a quitKey is pressed. Record response and RT if ansKey is pressed.
        response = event.waitKeys(keyList=ansKeys + quitKeys)
        if response[0] in quitKeys: core.quit()
        if response[0] in ansKeys:
            trial['rt'] = int(trialClock.getTime() * 1000)
            trial['ans'] = 'mirror' if response[0] == ansKeys[0] else 'normal'
            trial['score'] = int(trial['ans'] == trial['mirrored'])

            # Reward during training
            if condition == 'training':
                if trial['score']: feedbackRight.play()
                else: feedbackWrong.play()

        # Write trial and show it in console
        csvWriter(trial.values())

"""
Actually run experiment
"""
circles.draw()
instruction.draw()
win.flip()
event.waitKeys()

runBlock(V['condition'])