# -*- coding: utf-8 -*-
"""
Symmetry Span task, a la Foster et al (2015).
Written by Jonas Lindeløv, Aug 2015
editied by Timo L Kvamme, Feb, 2022#

"""

from __future__ import division
import glob, time, os, random, ppc, csv
import numpy as np
from psychopy import visual, event, core, gui, monitors
import pandas as pd


# Monitor
displayResolution = [1680,1050]  # monitor size in pixels
MON_DISTANCE = 60  # distance in cm from eye lens to monitor
MON_WIDTH = 38.5  # width of monitor panel in cm
fullscreen = False


Experiment = "symmetry_span"
# Conditions
SPANS = [2, 3, 4, 5]
N_BLOCKS = 8

# Filename stuff
IMAGES_FOLDER = 'symmetries'
ASYM_START_TRIAL = 25  # 1-24 are symmetrical, 25+ are asymmetrical
ASYM_START_PRACTICE = 8
saveFolder = SAVE_FOLDER = 'data'

imgoverview = os.getcwd() + "/" + "task_overview.png"

# Stimuli
GRID_DIMENSIONS = (4, 4)  # [x, y], number of cells in grid
GRID_SIZE = 0.8  # degrees visual angle of each cell
GRID_DURATION = 45  # duration on screen
GRID_PAUSE = 15  # duration before recall
SYMM_PAUSE = 15
TRIAL_PAUSE = 60  # pause in beginning of trial
SYM_PROMT_MOUSE = 2.0
BUTTON_STYLE = {'fillColor':'LightGray', 'lineColor':None, 'interpolate':False}
FEEDBACK_DURATION = 120  # duration of feedback after finished trial
TEXT_HEIGHT = 0.5
imgInstructPos = 0,4

# Keys
KEYS_QUIT = ['escape']

# Instructions during experiment
TEXT_RECALL = u'Vælg felterne i den rækkefølge, de blev vist. Brug TOM knappen til glemte placeringer.'
TEXT_FEEDBACK_GRID = u'Du huskede %i placeringer korrekt ud af %i.\n'
TEXT_FEEDBACK_SYMMETRY = u'Du lavede %i symmetrifejl. '
TEXT_FEEDBACK_PERCENT = 'Symmetri-korrekthed: %i%%.'
TEXT_CONTINUE = u'\n\nTryk med musen for at forstætte. '
TEXT_ASK = u'Spørg venligst, hvis du er i tvivl om noget.'
# Instructions for practice



INSTRUCT_WELCOME1 = u"""
I dette eksperiment skal du huske placeringen af farvede firkanter på skærmen, samtidig med at du foretager vurderinger af nogle billeder.

I de næste minutter får du nogle øvelser, som gør dig bekendt med, hvordan eksperimentet fungerer.

Vi begynder med at øve "placering" delen af eksperimentet.""" + TEXT_CONTINUE
INSTRUCT_RECALL1 = u"""
I dette øvelsessæt vil firkanterne blive vist én ad gangen på skærmen.

Prøv at huske hvor hver firkant var, i den rækkefølge de blev præsenteret i.

Efter at 2-5 firkanter er vist, vil du se et gitter med de 16 mulige placeringer hvor firkanterne kunne have været.

Din opgave er at vælge hver placering i den rækkefølge, de blev præsenteret. Klik med musen på de passende felter. Det valgte felt bliver rødt.""" + TEXT_CONTINUE
INSTRUCT_RECALL2 = u"""
Når du har valgt alle firkanterne i den rigtige rækkefølge, tryk på SVAR knappen nederst til højre på skærmen.

Tryk på SLET ALT knappen hvis du laver en fejl og begynd så forfra.

Tryk på TOM hvis du glemmer en af placeringerne for at markere hvor i rækkefølgen du har glemt.

Husk, det er meget vigtigt at markere placeringerne i samme rækkefølge, som du ser dem. Hvis du glemmer én, så brug TOM knappen til at markere stedet i rækkefølgen.""" + TEXT_CONTINUE + TEXT_ASK
INSTRUCT_SYMMETRY1 = u"""
Nu skal du øve symmetri-delen af eksperimentet.

Der bliver vist et billede på skærmen, og du skal svare, om det er symmetrisk. Et billede er symmetrisk hvis det kan foldes langs en lodret midterlinje og den venstre del passer med den højre del. Med andre ord, billedet er symmetrisk hvis venstre og højre side er hinandens spejlbilleder. På næste skærm ser du et billede der ER SYMMETRISK.""" + TEXT_CONTINUE
INSTRUCT_SYMMETRY2 = u"""
Bemærk at dette billede er symmetrisk om den røde linje

Senere vil der ikke blive vist en rød linje.""" + TEXT_CONTINUE
INSTRUCT_SYMMETRY3 = u"""
Dette billede er IKKE symmetrisk.

Hvis du foldede dette billede langs den røde linje, ville boksene IKKE passe sammen.""" + TEXT_CONTINUE
INSTRUCT_SYMMETRY4 = u"""
Dette er et andet eksempel på et billede, der ER symmetrisk.

Hvis du foldede det vertikalt, ville de to sider passe sammen.""" + TEXT_CONTINUE
INSTRUCT_SYMMETRY5 = u"""
På næste skærmbillede vises endnu et symmetri-problem. 

Tryk på musen, når du har set, om billedet er symmetrisk. Når du trykker, vises der herefter en JA knap og et NEJ knap. Klik på JA knappen hvis billedet, du så, var symmetrisk. Klik på NEJ knappen hvis billedet ikke var symmetrisk.

Efter at du har klikket på en af boksene vil computeren fortælle dig, om du valgte rigtigt.

Det er MEGET vigtigt at du svarer korrekt på billederne.""" + TEXT_CONTINUE + TEXT_ASK

INSTRUCT_TASK1 = u"""
Du skal nu øve begge dele af eksperimentet på én gang.
Når du har truffet dit valg om symmetri af billedet, vil en firkant-placering blive vist på skærmen. 
husk placeringen af firkanten!.""" + TEXT_CONTINUE

INSTRUCT_TASK2 = u"""
Efter firkanten forsvinder, vises der et andet symmetri-billede og igen en anden firkant.
Efter denne række af billeder og firkanter skal du svare, hvilke placeringer firkanten blev vist på. Brug musen til at vælge disse placeringer. Gør dit bedste for at få firkanterne markeret i den rigtige rækkefølge.
Det er vigtigt at du arbejder HURTIGT og PRÆCIST."""

INSTRUCT_TASK3 = u"""
Under feedbacken er der et rødt tal der.
viser hvor mange procent af symmetriproblemerne du har løst korrekt igennem hele eksperimentet.
Det er MEGET vigtigt, at du holder dette tal på mindst 85%"""

INSTRUCT_TASK4 = u"""Hvis du tager for lang tid til symmetriopgaverne vil computeren registere det som en fejl
Det er  MEGET vigtigt at løse problemet så hurtigt og præcist som muligt.""" + TEXT_CONTINUE


INSTRUCT_EXPERIMENT = u"""
Øvelserne er slut nu.

Det rigtige eksperiment er ligesom de øvelser du netop har gennemgået. Nogle symmetri-firkant sekvenser er længere end andre.

Det er vigtigt, at du gør dit bedste på både symmetri- og firkant-opgaverne.

Husk også at holde din symmetri-korrekthed over 85%.""" + TEXT_CONTINUE
INSTRUCT_BYE = u'Opgaven er slut. Tak for din deltagelse!'

PRESS_MOUSE_TO_PROCEED = u'tryk på museknappen for at komme videre'

"""
PSYCHOPY STIMS'N STUFF
"""

hypnotask_folder = "C:\\code\\projects\\hypnoalc\\hypnotask"
auxData = os.path.join(hypnotask_folder,"aux_data")

allocation_df = pd.read_csv(os.path.join(auxData,"allocation.csv"))
new_id = int(max(allocation_df["subjectID"])+1)

# Dialogue box
print("dlg pop-up")
dlg = {'id': new_id, 'session':[1, 2], 'instruct':True}
if not gui.DlgFromDict(dlg, order=['id', 'session', 'instruct']).OK:
    core.quit()

try:
    subjectID = "%04d" % int(dlg['id'])
except:
    print("incorrect subject id, must be integers, example: 0001")

instruct = dlg['instruct']

if not os.path.isdir(saveFolder): os.makedirs(saveFolder)  # Creates save folder if it doesn't exist
subjectSaveFolder = saveFolder + '\\subject_' + str(subjectID)
if not os.path.isdir(subjectSaveFolder): os.makedirs(subjectSaveFolder)


# Window
myMon = monitors.Monitor('testMonitor', width=MON_WIDTH, distance=MON_DISTANCE)  # Create monitor object from the variables above. This is needed to control size of stimuli in degrees.
myMon.setSizePix(displayResolution)
win = visual.Window(size=displayResolution,monitor=myMon, units='deg', color='white', fullscr=fullscreen, screen=1)

# Stuff for instructions
instruct_center = visual.TextStim(win, color='black', height=TEXT_HEIGHT,pos=(0,0))
instruct_top = visual.TextStim(win, color='black', height=TEXT_HEIGHT, pos=(0, 3))
instruct_bottom = visual.TextStim(win, color='black', height=TEXT_HEIGHT, pos=(0, -3))
instruct_image = visual.ImageStim(win, pos=(0, 3))
feedback_percent = visual.TextStim(win, text='', color='red', pos=(0,-3), height=TEXT_HEIGHT)
symresptext = visual.TextStim(win, pos=(0, 3),text='Var figuren symmetrisk?', color='black')

# Grid stims #
text_target = visual.TextStim(win, height=GRID_SIZE*0.5, color='black')
square_target = visual.Rect(win, height=GRID_SIZE, width=GRID_SIZE, lineColor='black', lineWidth=2, fillColor='red', interpolate=False)

square_grid = visual.Rect(win, height=GRID_SIZE, width=GRID_SIZE, lineColor='black', lineWidth=2, interpolate=False)
grid_coords = []
for y in range(GRID_DIMENSIONS[1] -1, -1, -1):  # from top to bottom
    for x in range(GRID_DIMENSIONS[0]):  # left to right
        grid_coords += [(GRID_SIZE*(x + 0.5 - 0.5*GRID_DIMENSIONS[0]), 
                         GRID_SIZE*(y + 0.5 - 0.5*GRID_DIMENSIONS[1]))]
        square_grid.pos = grid_coords[-1]  # set to this x, y coordinate
        square_grid.draw()
grid = visual.BufferImageStim(win)  # "screenshot"
win.clearBuffer()  # blank screen - we don't want to show it later

# Symmetry task response screen. Rect-buttons will be used to detect presses
symm_button_yes = visual.Rect(win, pos=(-3, 0), width=4, height=2.5, **BUTTON_STYLE)
symm_button_no = visual.Rect(win, pos=(3, 0), width=4, height=2.5, **BUTTON_STYLE)
symm_button_yes.draw()
symm_button_no.draw()
visual.TextStim(win, pos=(-3, 0), text='Ja', height=TEXT_HEIGHT, color='black').draw()
visual.TextStim(win, pos=(3, 0), text='Nej', height=TEXT_HEIGHT, color='black').draw()
symresptext.draw()
screen_symmetry = visual.BufferImageStim(win)
win.clearBuffer()

# Recall response screen. Rect-buttons will be used to detect presses
recall_button_clear = visual.Rect(win, pos=(-3, -3), width=2.5, height=1.5, **BUTTON_STYLE)
recall_button_respond = visual.Rect(win, pos=(3, -3), width=2.5, height=1.5, **BUTTON_STYLE)
recall_button_blank = visual.Rect(win, pos=(0, -3), width=2.5, height=1.5, **BUTTON_STYLE)

grid.draw()
instruct_top.text = TEXT_RECALL
instruct_top.draw()
recall_button_clear.draw()
recall_button_respond.draw()
recall_button_blank.draw()
visual.TextStim(win, pos=(-3, -3), text=u'SLET ALT', height=0.5, color='black').draw()
visual.TextStim(win, pos=(0, -3), text=u'INDSÆT\nTOM', height=0.5, color='black').draw()
visual.TextStim(win, pos=(3, -3), text=u'SVAR', height=0.5, color='black').draw()
screen_recall = visual.BufferImageStim(win)
win.clearBuffer()

# Other psychopy stuff
mouse = event.Mouse()
clock = core.Clock()

# A list of image-stimuli which can be used for the symmetry span task.
# We do it this so that we can load all images before each trial in order 
# to minimize processing during presentation.
stim_symm = []
for i in range(max(SPANS)):

    stim_symm += [visual.ImageStim(win)]

# Register image files according to their type
stims = {
    'examples': sorted(glob.glob(os.path.join(IMAGES_FOLDER, 'example_*'))),
    'matrices': sorted(glob.glob(os.path.join(IMAGES_FOLDER, 'matrix*'))),
    'practice': sorted(glob.glob(os.path.join(IMAGES_FOLDER, 'pracsymm*'))),
    'pattern_all': sorted(glob.glob(os.path.join(IMAGES_FOLDER, 'symm*')))
}

# Update "stims" with the image ID
for stim_type in stims:
    for i, filename in enumerate(stims[stim_type]):
        stims[stim_type][i] = {'recording_filename': filename, 'id': int(list(filter(str.isdigit, filename))[0])}


"""
FUNCTIONS
"""

def block_to_phase_convert(block=-1):
    phase = ""
    if block == -1:
        phase = "practice"
    else:
        phase = "experiment_block_%s".format(str(block+1))

    return phase

def makeTrialList(spans=None, run_section=None, block=-1):
    trial_list = []
    patterns_loop = stims['pattern_all'].copy() if spans is None else stims['practice'].copy()
    spans_loop = SPANS if spans is None else spans

    subjectsavefolder = os.getcwd() + "/" + SAVE_FOLDER + "/" + "subject_" + subjectID
    if not os.path.exists(subjectsavefolder):os.makedirs(subjectsavefolder)

    phase = block_to_phase_convert(block)
    save_file = '%s/%s_%s_%s_ses%s_%s.csv' % (subjectsavefolder, subjectID, Experiment, phase, dlg['session'], time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime()))

    for span in spans_loop:
        # Select some patterns and remove them from the pool
        patterns_trial = random.sample(patterns_loop, span)
        if run_section in (None, 'symmetry'):
            for pattern in patterns_trial:
                patterns_loop.remove(pattern)  # remove from "stims"


        # Build trial info
        trial_list += [{
            # General
            'condition': 'experiment' if spans is None else 'practice',
            'span': span,
            'no': '',
            'id': dlg['id'],
            'session': dlg['session'],
            'abs_time': '',  # the absolute time that this trial was started
            'time': np.nan,
            'file_path': save_file,
            'block':block,

            
            
            # Square positions
            'grid_locations': random.sample(range(GRID_DIMENSIONS[0] * GRID_DIMENSIONS[1]), span),  # sample without replacement
            'grid_anss': [],  # answers
            'grid_rts': [],  # reaction time to individual presses
            'grid_rt': '',  # total reaction time of recall
            'grid_scores': [],
            'grid_score': '',
            
            # Symmetry task
            'symmetry_image_files': [pattern['recording_filename'] for pattern in patterns_trial],
            'symmetry_symmetrical': [int('_mirror' in pattern['recording_filename']) for pattern in patterns_trial],
            'symmetry_scores': [],  # per-pattern scores
            'symmetry_score': '',  # per-trial summed score
            'symmetry_rts': [],  # per-pattern RT
            'symmetry_rt': '',  # per-trial average RT
            'symmetry_running_correctness': ''
        }]
        
    # Shuffle and number trials. And return result.
    if spans is None:
        random.shuffle(trial_list)
    for i, trial in enumerate(trial_list):
        trial['no_global'] = block * len(trial_list) + i
        trial['no'] = i
    return trial_list


def ask(text='', keyList=None, textstim=instruct_center,showimg=None):
    """
    Ask subject something. Shows question and returns answer (keypress)
    and reaction time. Defaults to no text and all keys.
    """
    # Wait for mouse release
    # while mouse.getPressed()[0]:
    #     pass
    press = None
    event.clearEvents()

    # Draw the TextStims to visual buffer, then show it and reset timing immediately (at stimulus onset)


    if showimg:
        visual.ImageStim(win,image=showimg,pos=imgInstructPos).draw()
        textstim.pos = 0,-2

    textstim.text = text
    textstim.draw()

    win.flip()
    clock.reset()
    #core.wait(5)  # Continuing faster than this is not allowed

    # Halt everything and wait for (first) responses matching the keys given in the Q object.
    event.clearEvents()

    while not press:
        press = mouse.getPressed()[0]
        for key in event.getKeys():  # quit on escape
            if key in KEYS_QUIT:
                core.quit()
            if key == "backspace":
                press = "backspace"


    # Wait for mouse release and return
    while mouse.getPressed()[0]:
        pass
    return clock.getTime(),press

def symmetry_example(text, example_id):
    instruct_image.image = stims['examples'][example_id]['recording_filename']
    instruct_image.draw()
    ask(text, textstim=instruct_bottom)
    
    

def animate_click(stim, background):
    """ Changes the fillColor of a ShapeStim as long as the mouse is pressed on it. """
    stim.fillColor = 'gray'
    background.draw()
    stim.draw()
    win.flip()
    while mouse.isPressedIn(stim):  # wait
        pass
    stim.fillColor = BUTTON_STYLE['fillColor']

symmetry_correctness = []
def run_block(run_section=None, spans=None, block=-1):

    """
    Runs a block of trials.
    run_section is either None (run all), 'grid' or 'symmetry'
    spans is a list of ints with specific spans to run
    """

    global symmetry_correctness
    
    # Loop through trials        
    trialList = makeTrialList(spans, run_section, block)
    saveFile = trialList[0]["file_path"]
    saveFile = open(saveFile,"w")
    csvWriter = csv.writer(saveFile, delimiter=',', lineterminator="\n")
    csvWriter.writerow(trialList[1].keys())
    saveFile.flush()


    for trial in trialList:
        trial['abs_time'] = core.getAbsTime()
        trial['time'] = time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime())

        # Prepare trial
        for i, image in enumerate(trial['symmetry_image_files']):
            stim_symm[i].image = image
        
        # Encoding and procesing
        for i in range(trial['span']):
        #if 1 == 2:           
            if run_section in ('grid', None):
                # Show grid and target
                square_target.pos = grid_coords[trial['grid_locations'][i]]
                for frame in range(GRID_DURATION):
                    grid.draw()
                    square_target.draw()
                    win.flip()
                
                # Pause
                for frame in range(GRID_PAUSE):
                    win.flip()
            
            if run_section in ('symmetry', None):
                # Present symmetry task and wait for mouse response

                stim_symm[i].draw()

                win.flip()
                symshown = clock.getTime()


                while not mouse.getPressed()[0]:
                    if symshown + SYM_PROMT_MOUSE < clock.getTime():
                        stim_symm[i].draw()
                        visual.TextStim(win, pos=(0, 3),height=0.5, text=PRESS_MOUSE_TO_PROCEED, color='black').draw()
                        win.flip()
                    pass
                
                # Break before response
                for frame in range(SYMM_PAUSE):
                    win.flip()
        
                # Show symmetry response screen and wait for mouse release 
                # before continuing to get response
                screen_symmetry.draw()
                win.flip()
                clock.reset()
                while mouse.getPressed()[0]:
                    pass
            
                while True:
                    # Wait and score trial on mouse press
                    if  mouse.isPressedIn(symm_button_yes):
                        trial['symmetry_rts'] += [clock.getTime()]
                        trial['symmetry_scores'] += [int(trial['symmetry_symmetrical'][i] == 1)]
                        clock.reset()
                        animate_click(symm_button_yes, screen_symmetry)
                        break
                    if mouse.isPressedIn(symm_button_no):
                        trial['symmetry_rts'] += [clock.getTime()]
                        trial['symmetry_scores'] += [int(trial['symmetry_symmetrical'][i] == 0)]
                        animate_click(symm_button_no, screen_symmetry)
                        break
            
        # Recall
        event.clearEvents()
        if run_section in ('grid', None):
            rts = []
            win.callOnFlip(clock.reset)
            continue_recall = True
            while continue_recall:
                # Present grid with current selections and sequence numbers
                screen_recall.draw()
                for i, pos in enumerate(trial['grid_anss']):                
                    if pos is not -1: # blank trial
                        square_target.pos = grid_coords[pos]
                        square_target.draw()
                        text_target.pos = grid_coords[pos]
                        text_target.text = i + 1  # potentially slow
                        text_target.draw()
                
                # Flip and wait for mouse release if it's still pressed in
                win.flip()
                while mouse.getPressed()[0]:
                    pass
                
                # Get new responses. A continuous loop to capture mouse presses everywhere at everytime.
                continue_response = True
                while continue_response:
                    if event.getKeys(keyList=KEYS_QUIT):
                        core.quit()
                    # Draw grid and react to grid selections. Takes ~1 ms for 16 locations
                    for i, pos in enumerate(grid_coords):
                        square_grid.pos = pos
                        # This square is pressed, register response
                        if mouse.isPressedIn(square_grid):
                            if i not in trial['grid_anss']:  # ignore if this cell is already selected
                                trial['grid_anss'] += [i]
                                trial['grid_rts'] += [clock.getTime()]
                                rts += [clock.reset]
                            continue_response = False
                            break  # to leave square_grid at it's position
                    
                    # Check and react to button presses
                    if mouse.isPressedIn(recall_button_respond):
                        # Summarize recall
                        trial['grid_rt'] = clock.getTime()
                        trial['grid_anss'] += [-2]*(trial['span'] - len(trial['grid_anss']))  # fill in response if there are missing responses
                        trial['grid_scores'] += [int(trial['grid_anss'][i] == trial['grid_locations'][i]) for i in range(len(trial['grid_locations']))]  # score
                        trial['grid_score'] = sum(trial['grid_scores'])
                        
                        # Continue
                        continue_recall = False
                        animate_click(recall_button_respond, screen_recall)
                        break
                    elif mouse.isPressedIn(recall_button_clear):
                        trial['grid_anss'] = []
                        trial['grid_rts'] = []
                        trial['grid_scores'] = []
                        animate_click(recall_button_clear, screen_recall)
                        break
                    elif mouse.isPressedIn(recall_button_blank):
                        trial['grid_anss'] += [-1]
                        trial['grid_rts'] += [clock.getTime()]
                        trial['grid_scores'] += [0]
                        animate_click(recall_button_blank, screen_recall)
                        break
        
        # Feedback
        instruct_center.text = ''
        if run_section in ('grid', None):
            instruct_center.text = TEXT_FEEDBACK_GRID %(trial['grid_score'], trial['span'])
        if run_section in ('symmetry', None):
            # Summarize symmetry
            trial['symmetry_score'] = sum(trial['symmetry_scores'])
            trial['symmetry_rt'] = sum(trial['symmetry_rts'])
            symmetry_correctness += trial['symmetry_scores']
            trial['symmetry_running_correctness'] = int(100*(sum(symmetry_correctness) / len(symmetry_correctness)))
            instruct_center.text += TEXT_FEEDBACK_SYMMETRY % (trial['span'] - trial['symmetry_score'])
            feedback_percent.text = TEXT_FEEDBACK_PERCENT % trial['symmetry_running_correctness']
        for frame in range(FEEDBACK_DURATION):
            feedback_percent.draw()
            instruct_center.draw()
            win.flip()
        
        # Save
        print(trial)
        csvWriter.writerow(trial.values());saveFile.flush()
            
            
"""
EXCECUTE
"""
writer = ppc.csv_writer(str(dlg['id']) + '_trials', folder=subjectSaveFolder) # writer.write(trial) will write individual trials with low latency

if __name__ == "__main__":

    if instruct:
        #Welcome practice recall
        ask(INSTRUCT_WELCOME1)
        ask(INSTRUCT_RECALL1)
        ask(INSTRUCT_RECALL2)
        run_block(run_section='grid', spans=[2,2,3])

        # Instructions for symmetry task
        ask(INSTRUCT_SYMMETRY1)
        symmetry_example(INSTRUCT_SYMMETRY2, 0)
        symmetry_example(INSTRUCT_SYMMETRY3, 1)
        symmetry_example(INSTRUCT_SYMMETRY4, 2)
        ask(INSTRUCT_SYMMETRY5)
        run_block(run_section='symmetry', spans=[1, 3])

        # Practice both
        ask(INSTRUCT_TASK1,showimg=imgoverview)
        ask(INSTRUCT_TASK2,showimg=imgoverview)
        ask(INSTRUCT_TASK3,showimg=imgoverview)
        run_block(spans=[2,3])

    # Actual experiment
    ask(INSTRUCT_EXPERIMENT)
    for block in range(N_BLOCKS):
        run_block(block=block)

# Bye bye, have a good one
ask(INSTRUCT_BYE)