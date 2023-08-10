# -*- coding: utf-8 -*-
"""
Project:  Japan_cost -
Script: "BRT_experiment"
Created on 26 July 11.07 2023

@author: 'Timo Kvamme

edit settings in the BRT_settings.py file
requires psychopy and pygaze (for eyetracking)

#todo test setup

#todo fix so that gabor patches are actual grating stims - for more control
#


"""
# ---------------------------------------------------------------#
# ------------------------- IMPORTS -----------------------------#
# ---------------------------------------------------------------#

from __future__ import division
import os

import pandas as pd

os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = "hide"

import psychopy.core, psychopy.event, psychopy.gui, psychopy.visual, pygame
from math import atan2, degrees
from myFunctions import *
from BRT_settings import BRT_settings
from itertools import product

from psychopy.hardware import keyboard
from psychopy import visual, core, monitors

# from pygaze.display import Display
# from pygaze.screen import Screen
# from pygaze.eyetracker import EyeTracker
# import pygaze.libtime as timer




class BRT_experiment(BRT_settings):
    def __init__(self):
        print('running %s' % __class__.__name__)
        self.experiment = "BRT"
        self.experiment_version = "1.1"
        self.display_settings()
        self.directory_settings()
        self.stimuli_settings()
        self.position_settings()
        self.eyetracking_settings()
        self.keyboard_settings()
        self.timing_settings()
        self.execution_settings()
        if self.doDlg: self.dlg()
        self.dlg_activated_settings()
        self.language_settings()
        self.trials_settings()
        self.initiate_psychopy_stimuli()

    def dlg(self):
        # ---------------------------------------------------------------#
        # ------------------ Dialog Box DLG  ----------------------------#
        # ---------------------------------------------------------------#
        dash_print('running %s' % inspect.stack()[0][3])

        if self.nextSubjectCalc: self.subjectID = str(calculate_next_subject(self.saveFolder))

        dlg = psychopy.gui.Dlg(title=self.experiment)
        dlg.addText('Subject info')
        dlg.addField('SubjectID', self.subjectID)
        dlg.addField('input', choices= self.input)
        dlg.addField("session", choices=self.sessionChoices)
        dlg.addField("intro", self.intro)
        dlg.addField("instruct", self.instruct)
        dlg.addField('doBRHorizontalAdjust', self.doBRHorizontalAdjust)
        dlg.addField('calibrationBR', self.calibrationBR)
        dlg.addField("ET", self.ET)
        dlg.addField("testMode", self.testMode)
        dlg.addField('Language', choices=self.defaultLanguages)
        dlg.addField('viewMode', choices=self.viewModes)
        dlg.addField('rateVivid', self.rateVivid)
        dlg.addField('eyeDom', choices=self.eyeDomChoices)
        dlg.show()

        if dlg.OK:  # user clicked OK button
            self.subjectID = dlg.data[dlg.inputFieldNames.index("SubjectID")]
            self.input = dlg.data[dlg.inputFieldNames.index("input")]
            self.session = dlg.data[dlg.inputFieldNames.index("session")]
            self.intro = dlg.data[dlg.inputFieldNames.index("intro")]
            self.instruct = dlg.data[dlg.inputFieldNames.index("instruct")]
            self.doBRHorizontalAdjust = dlg.data[dlg.inputFieldNames.index("doBRHorizontalAdjust")]
            self.calibrationBR = dlg.data[dlg.inputFieldNames.index("calibrationBR")]
            self.ET = dlg.data[dlg.inputFieldNames.index("ET")]
            self.testMode = dlg.data[dlg.inputFieldNames.index("testMode")]
            self.language = dlg.data[dlg.inputFieldNames.index("Language")]
            self.viewMode = dlg.data[dlg.inputFieldNames.index("viewMode")]
            self.rateVivid = dlg.data[dlg.inputFieldNames.index("rateVivid")]
            self.eyeDom = dlg.data[dlg.inputFieldNames.index("eyeDom")]


        else:
            panic_print('User Pressed Cancel')
            os._exit(1)
        print("dlg fine")

        try:
            self.subjectID = "%04d" % int(dlg['id'])
        except:
            print("incorrect subject id, must be integers, example: 0001")

        self.modID2 = int(self.subjectID) % 2 == 0
        self.modID4 = int(self.subjectID) % 4 == 0
        self.subjectSaveFolder = pathjoin(self.saveFolder,paste('subject_',self.subjectID))
        self.eyeDomFile = pathjoin(self.subjectSaveFolder,paste('subject_',self.subjectID,"_eyeDom.csv"))
        make_os_print(self.subjectSaveFolder)
        write_setting_to_file(self.eyeDomFile)


    def initiate_psychopy_stimuli(self):
        # ---------------------------------------------------------------#
        # ------------------ Initiate Psychopy Stimuli ------------------#
        # ---------------------------------------------------------------#
        dash_print('running %s' % inspect.stack()[0][3])

        self.degPerPx = degrees(atan2(.5 * self.monHeight, self.monDistance)) / (.5 * (self.displayResolution[1]))
        print('%s degrees correspond to a single pixel' % self.degPerPx)

        self.mon = monitors.Monitor('testmonitor', width=self.monWidth, distance=self.monDistance)
        self.mon.save()
        self.win = visual.Window(self.displayResolution, monitor=self.mon,  # name of the PsychoPy Monitor Config record_file if used.
                                 units="deg",  # coordinate space to use.
                                 fullscr=self.fullscreen,  # We need full screen mode.
                                 allowGUI=False,  # We want it to be borderless
                                 screen=1, color=self.backgroundColor)


        # initiate mouse
        self.mouse = psychopy.event.Mouse(visible=True, newPos=None, win=self.win)
        # inititalize kb
        self.kb = keyboard.Keyboard()

        # Create a ImageStim Object to show the image with in the PP function.
        self.stim = visual.ImageStim(self.win, pos=self.posFix, size=self.pictureSize)




        self.stimFix = psychopy.visual.TextStim(self.win, "+", color=self.foregroundColor, pos=self.posFix, bold=False,
                                                height=self.fixHeight, wrapWidth=self.wrapWidth)







        self.gabor_blue_pos = self.leftPos
        self.gabor_red_pos = self.rightPos

        if self.doBRHorizontalAdjust == False:
            try:
                BRadjustment_csv_path = self.saveFolder + '\\subject_' + str(self.subjectID) + '\\' + 'subject_' + str(
                    str(self.subjectID)) + "_calibrationBR" + '.csv'
                BRadjustment = pd.read_csv(BRadjustment_csv_path)
                self.gabor_red_pos = BRadjustment["gabor_red_pos"]
                self.gabor_blue_pos = BRadjustment["gabor_red_pos"]
                if self.viewMode == "googles":
                    self.mouseIndicatorPos = self.posCenter
                else:
                    self.mouseIndicatorPos = self.gabor_blue_pos if self.eyeDom == "left" else self.gabor_red_pos

            except:

                print("could not find subject values for horizontal adjust reruning")
                self.doBRHorizontalAdjust = True

        self.gabor_center = visual.ImageStim(
                win=self.win,
                name='image_1',
                image=pathjoin(self.stimuliFolder,'gabor_r60_b100.png'), mask=None,
                ori=0, pos=self.posCenter, size=self.sizeGabor,
                color=[1,1,1], colorSpace='rgb', opacity=0.8,
                flipHoriz=False, flipVert=False,
                texRes=128, interpolate=True, depth=-2.0)


        self.gabor_red = visual.ImageStim(
                win=self.win,
                name='image_1',
                image=pathjoin(self.stimuliFolder,'gabor_red.png'), mask=None,
                ori=0, pos=self.gabor_red_pos, size=self.sizeGabor,
                color=[1,1,1], colorSpace='rgb', opacity=0.8,
                flipHoriz=False, flipVert=False,
                texRes=128, interpolate=True, depth=-2.0)

        self.gabor_blue = visual.ImageStim(
                win=self.win,
                name='image_2',
                image=pathjoin(self.stimuliFolder,'gabor_blue.png'), mask=None,
                ori=0, pos=self.gabor_blue_pos, size=self.sizeGabor,
                color=[1,1,1], colorSpace='rgb', opacity=0.8,
                flipHoriz=False, flipVert=False,
                texRes=128, interpolate=True, depth=-2.0)


        self.grl = visual.ImageStim(
                win=self.win,
                name='image_1',
                image=pathjoin(self.stimuliFolder,'gabor_red.png'), mask=None,
                ori=0, pos=self.gabor_blue_pos, size=self.sizeGabor,
                color=[1,1,1], colorSpace='rgb', opacity=0.8,
                flipHoriz=False, flipVert=False,
                texRes=128, interpolate=True, depth=-2.0)

        self.gbr = visual.ImageStim(
                win=self.win,
                name='image_2',
                image=pathjoin(self.stimuliFolder,'gabor_blue.png'), mask=None,
                ori=0, pos=self.gabor_red_pos, size=self.sizeGabor,
                color=[1,1,1], colorSpace='rgb', opacity=0.8,
                flipHoriz=False, flipVert=False,
                texRes=128, interpolate=True, depth=-2.0)


        self.left_red_rect = visual.Rect(
                        win=self.win,
                        pos=self.gabor_blue_pos,
                        width=self.sizeGabor[0],
                        height=self.sizeGabor[0],
                        fillColor="red",
                        lineColor="red",
                        opacity=0.7)


        self.left_blue_rect = visual.Rect(
                        win=self.win,
                        pos=self.gabor_blue_pos,
                        width=self.sizeGabor[0],
                        height=self.sizeGabor[0],
                        fillColor="blue",
                        lineColor="blue",
                        opacity=0.7)

        self.right_red_rect = visual.Rect(
                        win=self.win,
                        pos=self.gabor_red_pos,
                        width=self.sizeGabor[0],
                        height=self.sizeGabor[0],
                        fillColor="red",
                        lineColor="red",
                        opacity=0.7)


        self.right_blue_rect = visual.Rect(
                        win=self.win,
                        pos=self.gabor_red_pos,
                        width=self.sizeGabor[0],
                        height=self.sizeGabor[0],
                        fillColor="blue",
                        lineColor="blue",
                        opacity=0.7)

        self.ratingScaleVivid = psychopy.visual.Slider(self.win, ticks=range(-150, 150), labels=["low", "high"],
                                                       startValue=None, pos=self.posCenter,
                                                       size=(8, 1), units=None, flip=False, ori=90, style='slider',
                                                       styleTweaks=[],
                                                       granularity=0, readOnly=False, labelColor=self.foregroundColor,
                                                       markerColor=self.scaleMarkerColor,
                                                       lineColor=self.foregroundColor, colorSpace='rgb', opacity=None,
                                                       font=self.font,
                                                       depth=0, name=None, labelHeight=None, labelWrapWidth=2000,
                                                       autoDraw=False,
                                                       autoLog=True, color=False, fillColor=False, borderColor=False)


        self.ratingScaleVivid1 = psychopy.visual.Slider(self.win, ticks=range(-150, 150), labels=["low", "high"],
                                                        startValue=None, pos=self.gabor_blue_pos,
                                                        size=(8, 1), units=None, flip=False, ori=90,
                                                        style='slider',
                                                        styleTweaks=[],
                                                        granularity=0, readOnly=False,
                                                        labelColor=self.foregroundColor,
                                                        markerColor=self.scaleMarkerColor,
                                                        lineColor=self.foregroundColor, colorSpace='rgb',
                                                        opacity=None, font=self.font,
                                                        depth=0, name=None, labelHeight=None, labelWrapWidth=2000,
                                                        autoDraw=False,
                                                        autoLog=True, color=False, fillColor=False,
                                                        borderColor=False)

        self.ratingScaleVivid2 = psychopy.visual.Slider(self.win, ticks=range(-150, 150), labels=["low", "high"],
                                                        startValue=None, pos=self.gabor_red_pos,
                                                        size=(8, 1), units=None, flip=False, ori=90,
                                                        style='slider',
                                                        styleTweaks=[],
                                                        granularity=0, readOnly=False,
                                                        labelColor=self.foregroundColor,
                                                        markerColor=self.scaleMarkerColor,
                                                        lineColor=self.foregroundColor, colorSpace='rgb',
                                                        opacity=None, font=self.font,
                                                        depth=0, name=None, labelHeight=None, labelWrapWidth=2000,
                                                        autoDraw=False,
                                                        autoLog=True, color=False, fillColor=False,
                                                        borderColor=False)

        # initiate stim
        self.win.clearBuffer()
        self.gabor_blue.draw()
        self.gabor_red.draw()
        self.stim = visual.BufferImageStim(self.win)
        self.win.clearBuffer()

        self.stimTextPrime = psychopy.visual.TextStim(self.win, "R", color=self.foregroundColor, pos=self.posFix, bold=False,
                                                height=self.textHeight, wrapWidth=self.wrapWidth)


        self.prime = self.stimTextPrime

        self.instructionText = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posCenter,
                                                           height=self.textHeight, text=self.ansText,
                                                           wrapWidth=self.wrapWidth)
        self.instructionText2 = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posCenter,
                                                           height=self.textHeight, text=self.ansText,
                                                           wrapWidth=self.wrapWidth)

        self.instructionAnsText = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posCenter,
                                                           height=self.textHeight, text=self.ansText,
                                                           wrapWidth=self.wrapWidth)

        self.instructionAnsText0 = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posBelowLeft,
                                               height=self.textHeight, text=self.ansText0, wrapWidth=self.wrapWidth)
        self.instructionAnsText1 = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posBelow,
                                               height=self.textHeight, text=self.ansText1, wrapWidth=self.wrapWidth)
        self.instructionAnsText2 = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posBelowRight,
                                               height=self.textHeight, text=self.ansText2, wrapWidth=self.wrapWidth)

        self.imageryInstruct = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posFarAbove,
                                               height=self.textHeight, text=self.imageryInstructText, wrapWidth=self.wrapWidth)

        self.imgCircle = psychopy.visual.Circle(self.win, fillColor=self.backgroundColor,lineColor=self.foregroundColor,radius=self.imgCircleradius,
                                                pos=self.posCenter, opacity=self.opacityCircle)


        self.instructionTextLeft = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posFarFarAboveLeft,
                                                   height=self.textHeightSmall, text=self.textBreak, wrapWidth=self.wrapWidth)

        self.instructionTextRight = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posFarFarAboveRight,
                                                    height=self.textHeightSmall, text=self.textBreak, wrapWidth=self.wrapWidth)




        self.instructionBelow = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posBelow, height=self.textHeight, text=self.textBreak,
                                                wrapWidth=self.wrapWidth)
        self.instructionAbove = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posAbove, height=self.textHeight,
                                                text=self.pressToContinue, wrapWidth=self.wrapWidth)


        self.instructionTextFarBelow = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posFarBelow, height=self.textHeight,
                                                       text=self.pressToContinue, wrapWidth=self.wrapWidth)

        self.instructionTextFarAbove = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posFarAbove, height=self.textHeight,
                                                       text=self.pressToContinue, wrapWidth=self.wrapWidth)

        self.instructionTextFarFarAbove = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posFarFarAbove, height=self.textHeightSmall,
                                                             text=self.pressToContinue, wrapWidth=self.wrapWidth)

        self.instructionTextFarFarFarAbove = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posFarFarFarAbove, height=self.textHeightSmall,
                                                          text=self.pressToContinue, wrapWidth=self.wrapWidth)

        self.instructionTextFarFarBelow = visual.TextStim(self.win, color=self.foregroundColor, pos=self.textPosFarFarBelow, height=self.textHeightSmall,
                                                          text=self.pressToContinue, wrapWidth=self.wrapWidth)

        self.feedbackWrongText = visual.TextStim(self.win, color="red", pos=self.posBelow, height=self.textHeight, text=self.textBreak,
                                                 wrapWidth=self.wrapWidth)

        self.feedbackFixationText = visual.TextStim(self.win, color=self.foregroundColor, pos=self.posBelow, height=self.textHeight, text=self.textBreak,
                                                    wrapWidth=self.wrapWidth)
        self.feedbackFixationText.setText(self.fixationText)
        self.myCircle = psychopy.visual.Circle(self.win, radius=self.fixCircleradius, pos=self.posFix, opacity=self.opacityCircle)
        # myCircle.setFillColor((1,1,1) ,colorSpace='rgb') # black
        self.myCircle.setLineColor((1, -1, -1), colorSpace='rgb')  # red
        # inititalize Clocks
        self.myClock = psychopy.core.Clock()


        # For testing
        self.gazeDot = visual.GratingStim(self.win, tex=None, mask="gauss", pos=(0, 0), size=(66, 66), color='green',
                                     units=self.units)

        self.loadingBarBackground = psychopy.visual.Rect(
            win=self.win,
            width=self.loadBarWidth + (self.loadBarWidth * 0.03),
            height=self.loadbarHeight + (self.loadbarHeight * 0.03),
            fillColor="black",
            lineColor="black",
            lineColorSpace='rgb',
            fillColorSpace='rgb',
            pos=(0, self.loadbarYpos), lineWidth=0.0, opacity=1.0, contrast=1.0)

        self.loadingBarInside = psychopy.visual.Rect(
            win=self.win,
            width=0,
            height=self.loadbarHeight,
            fillColor="green",
            lineColor="green",
            lineColorSpace='rgb',
            fillColorSpace='rgb',
            pos=(-self.loadBarWidth / 2, self.loadbarYpos), lineWidth=1, opacity=1.0, contrast=1.0, depth=0)

        try:
            self.ActualFrameRate = self.win.getActualFrameRate()
            self.FramesPerSeconds = 1000.0 / int(self.ActualFrameRate)
        except:
            print("cant get win.getActualFrameRate()")


    def loading_bar(self,*drawEveryFrame,continueText,framesOrTime=2.0):
        """
        makes a loading bar where the participant can't progress while it's
        loading

        :param drawEveryFrame: list of psychopy objects, text or images that are drawn every frame
            of the loading bar
        :param continueText: the psychopy text object that is displayed at the end of the loading bar which
            says Continue
        :param framesOrTime: int or float
            if int it says how many frames you want to show the loading bar
            the last frame will show the continue text,
            if its a float then it assumes thats the time, 2.0 is two seconds
            2.1 is two seconds and 100 miliseconds
            it will then use the stored value self.ActualFrameRate to calculate amount of frames
        :return:
        """
        loadingBarBackground = self.loadingBarBackground
        loadingBarInside = self.loadingBarInside
        win = self.win
        loadBarWidth = self.loadBarWidth

        while self.FramesPerSeconds == None:
            try:
                self.ActualFrameRate = self.win.getActualFrameRate()
                self.FramesPerSeconds = 1000.0 / int(self.ActualFrameRate)
            except:
                print("cant get win.getActualFrameRate()")

        if isinstance(framesOrTime,float):

            timeInMiliseconds = framesOrTime * 1000
            frames = math.ceil(timeInMiliseconds / self.FramesPerSeconds)

        elif isinstance(framesOrTime,int):
            frames = framesOrTime

        else:
            panic_print("Wrong type input to framesOrTime, please input int for frames or float for time")

        frames = xrange(frames)

        drawEveryFrame = drawEveryFrame

        for frame in frames:

            for staticDraw in drawEveryFrame:
                staticDraw.draw()

            loadingBarBackground.draw()
            loadingBarInside.size = (loadBarWidth / (frames[-1] + 1)) * (3 + frame), self.loadbarHeight
            loadingBarInside.pos = (-self.loadBarWidth / 2) + ((((self.loadBarWidth / (frames[-1] + 1))) * frame) / 2), self.loadbarYpos
            loadingBarInside.draw()

            if frame == len(frames) - 1:
                continueText.draw()




            win.flip()

    def wait_for_psychopy_response(self,keylist=[' ','space', 'enter','RETURN','return'],quitKeys=['escape', 'esc'],
                                       quitAutomatically=True):

        print("wait_for_psychopy_response")
        response = self.kb.waitKeys(keyList=keylist + quitKeys)
        if quitAutomatically:
            if response in quitKeys: psychopy.core.quit()
            else:
                pass

        return response



    def make_trial_list(self, phase="BRT_img_trials"):
        """ Make list of trials for a specified condition
        :param phase:
            the phase of the experiment, which can change

        """


        # ---------------------------------------------------------------#
        # ------------------ Make Trial List ----------------------------#
        # ---------------------------------------------------------------#
        dash_print('running %s' % inspect.stack()[0][3])

        # Factors that are the same across phases and groups
        print("Making New Trial List: SubjectID=%s,session=%s, phase=%s," % (self.subjectID, self.session, phase))
        trialList = []

        # Setting up subject save folder, and pp save folder


        saveFile = pathjoin(self.subjectSaveFolder,
                            paste('subject',self.subjectID,phase,
                            "ses",self.session,timestamp(),".csv",sep="_"))



        if phase == "BRT_img_instruct":
            allParameters = self.instructTrials
            trialParamSeed=False

        elif phase == "BRT_img_practice":
            loc = ["BR"]

        elif phase == "BRT_img_trials" or phase == "BRT_calibration":
            numTrials = self.numTrialsBRT_img
            type = ["img"] * self.numImgTrials + ["mock"]
            primeType = ["R","B"]
            loc = ["BR"]
            trialX = int(len(type) / len(primeType) / len(loc))

            allParameters = list(product(range(trialX), type, primeType, loc))
            random.seed(self.subjectID)
            random.shuffle(allParameters)



        for no, trialParameters in enumerate(allParameters):
            # Fill in the basic information in the trial
            if "instruct" not in phase:
                x = 1

            if self.viewMode == "googles":
                bo,ro = self.find_best_contrast_img(self.gabor_blue_opacity,self.gabor_red_opacity)
                contrast_img = pathjoin(self.stimuliFolder,paste("gabor_r",ro,"_","b",bo,".png",sep=""))


            trial = {
                'id': self.subjectID,
                'phase': phase,
                'session': self.session,
                'no': no,
                'type': trialParameters[1],
                'prime': trialParameters[2],
                'loc':trialParameters[3],
                'iti': self.iti,
                'contrast_blue':self.gabor_blue_opacity,
                'contrast_red': self.gabor_red_opacity,
                'img':contrast_img if self.viewMode == "googles" else np.nan,
                'contrast2_blue':  np.nan,
                'contrast2_red':  np.nan,
                'lum_left': np.nan,
                'lum_right': np.nan,
                'domAns': np.nan,
                'domAns2': np.nan,
                'vivid':np.nan,
                'vividrt': np.nan,
                'rt': np.nan,
                'eyeDom': self.eyeDom,
                'trialInitTime':np.nan,
                'stimShownTime':np.nan,
                'time': np.nan,
                'timeSecs': np.nan,
                'filePath': saveFile,
                'experiment_version': self.experiment_version,

            }

            trialList += [trial]

        print("length of trialList = %s trials" % len(trialList))

        trialListPandas = pd.DataFrame.from_dict(trialList)
        self.trialList = trialList

        return trialList


    def make_stimulus(self, trial):

        """ stimulus preperation"""

        # Prepare stimuli: set images


        if self.viewMode == "mirrors":
            if trial["type"] == "img":
                # location
                if trial["loc"] == "BR":
                    self.gabor_blue.pos = self.leftPosCalc
                    self.gabor_red.pos = self.rightPosCalc
                elif trial["loc"] == "RB":
                    self.gabor_blue.pos = self.rightPosCalc
                    self.gabor_red.pos = self.leftPosCalc
                else:
                    print("inccorect loc set in make_stimulus")

                # contrast / opacity
                self.gabor_blue.opacity = self.gabor_blue_opacity
                self.gabor_red.opacity = self.gabor_red_opacity

                print("red: %s"% self.gabor_red.opacity)
                print("blue: %s" % self.gabor_blue.opacity)

                self.win.clearBuffer()
                self.gabor_red.draw()
                self.gabor_blue.draw()

                self.stim = visual.BufferImageStim(self.win)
                self.win.clearBuffer()

            elif trial["type"] == "adaptation":
                # location
                if trial["loc"] == "BR":
                    self.gabor_blue.pos = self.leftPosCalc
                    self.gabor_red.pos = self.rightPosCalc
                elif trial["loc"] == "RB":
                    self.gabor_blue.pos = self.rightPosCalc
                    self.gabor_red.pos = self.leftPosCalc
                else:
                    print("inccorect loc set in make_stimulus")

                # contrast / opacity
                self.gabor_blue.opacity = self.full_gabor_opacity
                self.gabor_red.opacity = self.full_gabor_opacity


                self.win.clearBuffer()
                if trial["domAns"] == "red":
                    self.gabor_red.pos = self.leftPosCalc
                    self.gabor_red.draw()
                    self.gabor_red.pos = self.rightPosCalc
                    self.gabor_red.draw()

                if trial["domAns"] == "blue":
                    self.gabor_blue.pos = self.leftPosCalc
                    self.gabor_blue.draw()
                    self.gabor_blue.pos = self.rightPosCalc
                    self.gabor_blue.draw()

                self.stim = visual.BufferImageStim(self.win)
                self.win.clearBuffer()


            elif trial["type"] == "mock":
                if trial["no"] % 2 == 0:
                    self.gabor_blue.opacity = self.full_gabor_opacity

                    self.gabor_blue.pos = self.leftPosCalc
                    self.gabor_blue.draw()
                    self.gabor_blue.pos = self.rightPosCalc
                    self.gabor_blue.draw()

                else:
                    self.gabor_red.opacity = self.full_gabor_opacity
                    self.gabor_red.pos = self.leftPosCalc
                    self.gabor_red.draw()
                    self.gabor_red.pos = self.rightPosCalc
                    self.gabor_red.draw()

            else:
                print("incorrect type of trial in make_stimulus")
        else:

            if trial["type"] == "img":

                self.gabor_center.setImage(trial["img"])

                self.win.clearBuffer()
                self.gabor_center.draw()
                self.stim = visual.BufferImageStim(self.win)
                self.win.clearBuffer()

            elif trial["type"] == "adaptation":

                self.win.clearBuffer()
                if trial["domAns"] == "red":

                    self.gabor_red.pos = self.posCenter
                    self.gabor_red.draw()

                if trial["domAns"] == "blue":
                    self.gabor_blue.pos = self.posCenter
                    self.gabor_blue.draw()

                self.stim = visual.BufferImageStim(self.win)
                self.win.clearBuffer()


            elif trial["type"] == "mock":
                if trial["no"] % 2 == 0:
                    self.gabor_red.pos = self.posCenter
                    self.gabor_red.draw()

                else:
                    self.gabor_blue.pos = self.posCenter
                    self.gabor_blue.draw()

                self.stim = visual.BufferImageStim(self.win)
                self.win.clearBuffer()

            else:
                print("incorrect type of trial in make_stimulus")

        return self.stim



    def make_prime(self,trial):

        """ prime preperation """

        if self.primeText == "simple":
            self.stimTextPrime.text = trial["prime"]
        else:
            if self.viewMode == "googles":
                self.stimTextPrime.text = "Here you imagine a %s grating stimulus" % (
                    self.stim1 if trial["prime"] == "R" else self.stim2)

            else:
                self.stimTextPrime.text = "Here you\n" \
                                  "imagine a\n" \
                                  " %s \n" \
                                  "grating\n" \
                                  "stimulus" % (
                                      self.stim1 if trial["prime"] == "R" else self.stim2)


        if self.viewMode == "googles":


            self.win.clearBuffer()
            self.stimTextPrime.setPos(self.posFarAbove)
            self.stimTextPrime.draw()
            self.prime = visual.BufferImageStim(self.win)
            self.win.clearBuffer()
        else:
            self.win.clearBuffer()
            self.stimTextPrime.setPos(self.gabor_blue_pos)
            self.stimTextPrime.draw()
            self.stimTextPrime.setPos(self.gabor_red_pos)
            self.stimTextPrime.draw()


            self.prime = visual.BufferImageStim(self.win)
            self.win.clearBuffer()

        return self.prime


    def find_best_contrast_img(self,bo,ro):
        ixd = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        ixdd = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

        bo = closest_value([0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0], bo)
        ro = closest_value([0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0], ro)

        bo = ixd[ixdd.index(bo)]
        ro = ixd[ixdd.index(ro)]

        return bo, ro



    def make_imagery_circle(self,trial):


        self.stimTextPrime.text = trial["prime"]
        if self.viewMode == "googles":

            self.imgCircle.draw()
            self.stimTextPrime.draw()
            self.imageryInstruct = visual.BufferImageStim(self.win)
            self.win.clearBuffer()

        else:
            self.stimTextPrime.setPos((self.gabor_blue_pos[0],self.posFarAbove[1]))
            self.imgCircle.setPos(self.gabor_blue_pos)
            self.imgCircle.draw()
            self.stimTextPrime.draw()

            self.stimTextPrime.setPos((self.gabor_red_pos[0],self.posFarAbove[1]))
            self.imgCircle.setPos(self.gabor_red_pos)
            self.imgCircle.draw()
            self.stimTextPrime.draw()

            self.imageryInstruct = visual.BufferImageStim(self.win)
            self.win.clearBuffer()

        return self.imageryInstruct

    def stim_win_flip_call(self, trial,myClock):
            trial["stimShownTime"] = myClock.getTime()
        # see Paradigm in tnccmp_experiment for more

    def get_rate_vivid(self):
        if self.viewMode == "googles":
            self.mouseIndicatorPos = self.posCenter
        else:
            self.mouseIndicatorPos = self.gabor_blue_pos if self.eyeDom == "left" else self.gabor_red_pos

        self.win.setMouseVisible(True)
        self.mouse.setPos(self.mouseIndicatorPos)

        if self.viewMode == "googles":
            ratingScaleVivid = self.ratingScaleVivid
            ratingScaleVivid.reset()
            self.win.setMouseVisible(True)
            self.mouse.setPos(self.posCenter)

            self.instructionAbove.setPos(self.posFarAbove)
            self.instructionAbove.setText(self.vividnessJudgementText)
            while ratingScaleVivid.rating == None:
                ratingScaleVivid.draw()
                self.instructionAbove.draw()
                self.win.flip()

            rating = ratingScaleVivid.getRating()
            rt=ratingScaleVivid.getRT()

        else:
            ratingScaleVivid1 = self.ratingScaleVivid1
            ratingScaleVivid2 = self.ratingScaleVivid2


            ratingScaleVivid1.reset()
            ratingScaleVivid2.reset()



            self.instructionAbove.setText(self.vividnessJudgementText)
            self.instructionTextFarAbove.setText(self.vividnessJudgementText)
            instructionTextAbove1 = self.instructionAbove
            instructionTextAbove2 = self.instructionTextFarAbove

            instructionTextAbove1.setPos((self.gabor_blue_pos[0],self.posFarAbove[1]))
            instructionTextAbove2.setPos((self.gabor_red_pos[0],self.posFarAbove[1]))


            while ratingScaleVivid1.rating == None and ratingScaleVivid2.rating == None:
                ratingScaleVivid1.draw()
                ratingScaleVivid2.draw()

                instructionTextAbove1.draw()
                instructionTextAbove2.draw()
                self.win.flip()

            if ratingScaleVivid1.rating != None:
                rating = ratingScaleVivid1.getRating()
                rt=ratingScaleVivid1.getRT()
            else:
                rating = ratingScaleVivid2.getRating()
                rt=ratingScaleVivid2.getRT()


        return rating, rt
    def get_dominance_percept(self):


        if self.viewMode == "googles":
            # Dominance percept response
            self.instructionAnsText.draw()
            self.instructionAnsText0.draw()
            self.instructionAnsText1.draw()
            self.instructionAnsText2.draw()
            self.win.flip()

            # fix this
            ansInt = wait_for_psychopy_kb_mouse_response(win=self.win,keyList=self.ansKeys  + self.continueKey,
                                                         mousePoints=[self.posBelowLeft,
                                                                      self.posBelow,self.posBelowRight],
                                                         mouseMinDistance=self.minDistanceToAns,
                                                         mouseInit=self.mouseIndicatorPos)

            ansInt = [v for v in ansInt.values()][0]
            if ansInt in ["1","2","3"]:
                ansInt = int(ansInt) - 1

            try:
                if isinstance(ansInt,int):
                    if ansInt >= 3:ansInt -= 3
            except:
                pass

            if ansInt in self.ansKeys:
                ansInt = self.ansKeys.index(ansInt)



            # old method only keyboard
            #ansInt = int(wait_for_keyboard_psychopy_response(keyList=self.ansKeys))

            if ansInt == 0: self.instructionAnsText0.color = self.chosenColor1
            if ansInt == 1: self.instructionAnsText1.color = self.chosenColorMix
            if ansInt == 2: self.instructionAnsText2.color = self.chosenColor2

            waitTill = self.myClock.getTime() + self.confirmRespTime
            while waitTill > self.myClock.getTime():
                self.instructionAnsText.draw()
                self.instructionAnsText0.draw()
                self.instructionAnsText1.draw()
                self.instructionAnsText2.draw()
                self.win.flip()

            if ansInt == 0: self.instructionAnsText0.color = self.foregroundColor
            if ansInt == 1: self.instructionAnsText1.color = self.foregroundColor
            if ansInt == 2: self.instructionAnsText2.color = self.foregroundColor


        else: # mirror
            # Dominance percept response

            self.instructionAnsText.setPos(self.posAboveLeft)
            self.instructionAnsText.draw()
            self.instructionAnsText.setPos(self.posAboveRight)
            self.instructionAnsText.draw()

            self.instructionAnsText0.setPos((self.gabor_blue_pos[0],self.posCloseAbove[1]))
            self.instructionAnsText1.setPos((self.gabor_blue_pos[0],self.posCenter[1]))
            self.instructionAnsText2.setPos((self.gabor_blue_pos[0],self.posCloseBelow[1]))

            self.instructionAnsText0.draw()
            self.instructionAnsText1.draw()
            self.instructionAnsText2.draw()

            self.instructionAnsText0.setPos((self.gabor_red_pos[0],self.posCloseAbove[1]))
            self.instructionAnsText1.setPos((self.gabor_red_pos[0],self.posCenter[1]))
            self.instructionAnsText2.setPos((self.gabor_red_pos[0],self.posCloseBelow[1]))

            self.instructionAnsText0.draw()
            self.instructionAnsText1.draw()
            self.instructionAnsText2.draw()



            self.win.flip()
            self.win.setMouseVisible(True)

            # positions, red, mix, blue, red, mix, blue

            pos_of_interest = [(self.gabor_blue_pos[0],self.posCloseAbove[1]),
                               (self.gabor_blue_pos[0],self.posCenter[1]),
                               (self.gabor_blue_pos[0],self.posCloseBelow[1]),
                               (self.gabor_red_pos[0], self.posCloseAbove[1]),
                               (self.gabor_red_pos[0], self.posCenter[1]),
                               (self.gabor_red_pos[0], self.posCloseBelow[1])]
            # fix this
            ansInt = wait_for_psychopy_kb_mouse_response(win=self.win, keyList=self.ansKeys + self.recalibrationKey + self.continueKey,
                                                         mousePoints=pos_of_interest,
                                                         mouseMinDistance=self.minDistanceToAns,
                                                         mouseInit=self.mouseIndicatorPos)
            ansInt = [v for v in ansInt.values()][0]
            if ansInt in ["1","2","3"]:
                ansInt = int(ansInt) - 1

            try:
                if isinstance(ansInt,int):
                    if ansInt >= 3:ansInt -= 3
            except:
                pass

            if ansInt in self.ansKeys:
                ansInt = self.ansKeys.index(ansInt)

            # old method only keyboard
            # ansInt = int(wait_for_keyboard_psychopy_response(keyList=self.ansKeys))

            if ansInt == 0: self.instructionAnsText0.color = self.chosenColor1
            if ansInt == 1: self.instructionAnsText1.color = self.chosenColorMix
            if ansInt == 2: self.instructionAnsText2.color = self.chosenColor2

            waitTill = self.myClock.getTime() + self.confirmRespTime
            while waitTill > self.myClock.getTime():
                self.instructionAnsText.setPos(self.posAboveLeft)
                self.instructionAnsText.draw()
                self.instructionAnsText.setPos(self.posAboveRight)
                self.instructionAnsText.draw()

                self.instructionAnsText0.setPos((self.gabor_blue_pos[0], self.posCloseAbove[1]))
                self.instructionAnsText1.setPos((self.gabor_blue_pos[0], self.posCenter[1]))
                self.instructionAnsText2.setPos((self.gabor_blue_pos[0], self.posCloseBelow[1]))

                self.instructionAnsText0.draw()
                self.instructionAnsText1.draw()
                self.instructionAnsText2.draw()

                self.instructionAnsText0.setPos((self.gabor_red_pos[0], self.posCloseAbove[1]))
                self.instructionAnsText1.setPos((self.gabor_red_pos[0], self.posCenter[1]))
                self.instructionAnsText2.setPos((self.gabor_red_pos[0], self.posCloseBelow[1]))

                self.instructionAnsText0.draw()
                self.instructionAnsText1.draw()
                self.instructionAnsText2.draw()

                self.win.flip()

            if ansInt == 0: self.instructionAnsText0.color = self.foregroundColor
            if ansInt == 1: self.instructionAnsText1.color = self.foregroundColor
            if ansInt == 2: self.instructionAnsText2.color = self.foregroundColor

        return ansInt



    def run_BRT_img_introduction(self):

        if self.viewMode == "googles":
            self.instructionText.setText(self.introText)
            self.instructionText.pos = self.posAbove
            self.instructionTextFarFarBelow.setText(self.pressToContinue)

            self.instructionText.draw()
            self.instructionTextFarFarBelow.draw()
            self.gabor_red.draw()
            self.gabor_blue.draw()


        else:
            self.instructionText.setText(self.introText)
            self.instructionText.setPos(self.posAboveLeft)
            self.instructionText.draw()
            self.instructionText.setPos(self.posAboveRight)
            self.instructionText.draw()

            self.gabor_blue.setPos((self.gabor_blue_pos[0],self.posBelow[1]))
            self.gabor_blue.draw()
            self.gabor_red.setPos((self.gabor_blue_pos[0], self.posFarFarBelow[1]))
            self.gabor_red.draw()

            self.gabor_blue.setPos((self.gabor_red_pos[0],self.posBelow[1]))
            self.gabor_blue.draw()
            self.gabor_red.setPos((self.gabor_red_pos[0], self.posFarFarBelow[1]))
            self.gabor_red.draw()



        self.win.flip()
        self.win.setMouseVisible(False)

        print("after loading bar")
        response = self.wait_for_psychopy_response()
        print(response)
        self.draw_text_instruct(text=self.introText)


    def run_BRHorizontalAdjust(self):


        self.instructionText.setText(self.horizontalAdjustText)
        self.instructionText.pos = self.posFarAbove

        instructText1 = self.instructionAnsText0
        instructText1.setText("text")
        instructText1.setPos((self.leftPosCalc[0],self.posAbove[1]))
        instructText2 = self.instructionAnsText1
        instructText2.setText("text")
        instructText2.setPos((self.rightPosCalc[0],self.posAbove[1]))
        self.gabor_blue.pos = self.leftPosCalc
        self.gabor_red.pos = self.rightPosCalc



        self.win.setMouseVisible(False)
        adjusted = False

        while adjusted == False:


            self.gabor_blue.draw()
            self.gabor_red.draw()
            instructText1.draw()
            instructText2.draw()
            self.instructionText.draw()


            response = psychopy.event.getKeys(keyList=["left","right","up","down"] + self.scaleAcceptKeys + self.quitKeys)
            self.win.flip()
            #print(response)
            #print(self.horizontalStepRate)

            if response:
                if response[0] == "left":
                    self.gabor_blue.pos = (self.gabor_blue.pos[0] - self.horizontalStepRate,self.leftPosCalc[1])
                    self.gabor_red.pos = (self.gabor_red.pos[0] + self.horizontalStepRate,self.rightPosCalc[1])
                    instructText1.pos = (self.gabor_blue.pos[0] - self.horizontalStepRate,self.posAbove[1])
                    instructText2.pos = (self.gabor_red.pos[0] + self.horizontalStepRate,self.posAbove[1])

                elif response[0] == "right":
                    self.gabor_blue.pos = (self.gabor_blue.pos[0] + self.horizontalStepRate,self.leftPosCalc[1])
                    self.gabor_red.pos = (self.gabor_red.pos[0] - self.horizontalStepRate,self.rightPosCalc[1])
                    instructText1.pos = (self.gabor_blue.pos[0] + self.horizontalStepRate,self.posAbove[1])
                    instructText2.pos = (self.gabor_red.pos[0] - self.horizontalStepRate,self.posAbove[1])

                elif response[0] == "up":
                    self.horizontalStepRate = self.horizontalStepRate + self.horizontalStepRateChange

                elif response[0] == "down":
                    self.horizontalStepRate = self.horizontalStepRate - self.horizontalStepRateChange

                elif response[0] in self.scaleAcceptKeys:
                    adjusted = True
                    self.leftPosCalc = self.gabor_blue.pos
                    self.rightPosCalc = self.gabor_red.pos

        self.instructionText.setText("Stimuli calibrated")
        self.instructionText.draw()

        if self.viewMode == "googles":
            self.mouseIndicatorPos = self.posCenter
        else:
            self.mouseIndicatorPos = self.gabor_blue.pos if self.eyeDom == "left" else self.gabor_red.pos


        self.win.flip()
        core.wait(0.5)


        calibrationBRdf = pd.DataFrame(data={"gabor_red_pos": self.gabor_red.pos[0],
                                      "gabor_blue_pos": self.gabor_blue.pos[0],
                                      "subjectID": self.subjectID,
                                           "time":time.strftime('%Y_%m_%d_%H_%M_%S',time.localtime())}, index=[0])


        BRadjustment_csv_path = self.subjectSaveFolder + '\\' + 'subject_' + str(str(self.subjectID)) + "_calibrationBR" + '.csv'
        calibrationBRdf.to_csv(BRadjustment_csv_path)


        instructText1.setText(self.ansText0)
        instructText2.setText(self.ansText1)

    def run_adaptation_calibrationBR(self):
        """
        The adaptive procedure included in Nadine’s github code (staircase.m)
        comes from Bergmann et al., 2016 (but just as a reminder, Nadine never
        used it in her study because they calculated the full psychometric curve).
        It first presents the rivalry display, asks the participant which was dominant
        and then it shows the dominant stimulus at full contrast for 4 seconds before
        showing the rivalry display again. The adaptation effect should increase the
        probability of the participant seeing the other stimulus in the subsequent trial.
        If they see the dominant stimulus again as dominant or sees about an equal mix of
        the two stimuli, then the contrast of the dominant stimulus is decreased and the other
        increased (based on a pre-determined stepsize) until there are switches almost all the
        time and therefore the contrast of each grating stabilizes. In the current code this continues
        for a pre-determined number of trials, which I guess is just chosen by the experimenter during
        the piloting phase. I think the code could be altered though so that it continues until e.g.
        the contrast values for the stimuli are the same for the last 5 trials, or something like that.

        The number of trials is now set to 20 but you might want to change this;
        The stepSize of the changes in contrast are now fixed at 0.02 but you might want to
        increase or decrease that depending on the exact contrast values. In the last row of
        the staircase.m script, need to add a line to save the variables in C matrix:
        'save(fullfile(output,saveName)); %save everything'


        :return:
        """


        self.calibrationSCHistory = []
        self.calibrationPerceptHistory = []
        self.calibrationPerceptValues = [0.0,0.5,1.0]

        trialList = self.make_trial_list(phase="BRT_calibration")
        trial = trialList[0]
        saveFile = trialList[0]["filePath"]

        file = open(saveFile, "w")
        print('Writing to record_file {0}'.format(saveFile))
        csvWriter = csv.writer(file, delimiter=',', lineterminator="\n")
        csvWriter.writerow(trialList[0].keys())

        stim = self.make_stimulus(trial)


        calibrationComplete = False
        no = 0
        while calibrationComplete == False:

            # Initial fixation cross ( right after ppt has responed)
            waitTill = self.myClock.getTime() + trial["iti"]
            while self.myClock.getTime() < waitTill:
                self.stimFix.draw()
                self.win.flip()


            # Binocular Rivalry - stimulus
            self.win.setMouseVisible(False)
            waitTill = self.myClock.getTime() + self.stimTime
            while waitTill > self.myClock.getTime():
                stim.draw()
                self.win.flip()

            # Response Dominance Percept
            ansInt = self.get_dominance_percept()
            if ansInt == "c": self.run_BRHorizontalAdjust()
            if ansInt == "f": calibrationComplete = True
            try:trial["domAns"] = self.ansTypesName[ansInt]
            except:pass
            trial["no"] = no
            trial["contrast_blue"] = self.gabor_blue_opacity
            trial["contrast_red"] = self.gabor_red_opacity
            if self.removeMixTrialsCalibrationResult and trial["domAns"] == "mix":pass
            else:
                try:
                    self.calibrationPerceptHistory.append(self.calibrationPerceptValues[ansInt])
                except:pass

            if trial["domAns"] != "mix":

                trial["type"] = "adaptation"
                stim = self.make_stimulus(trial)

                # adaptation effect induction
                self.win.setMouseVisible(False)

                waitTill = self.myClock.getTime() + self.domPerceptAdaptTimePresent
                while waitTill > self.myClock.getTime():
                    stim.draw()
                    self.win.flip()

                # ITI
                waitTill = self.myClock.getTime() + trial["iti"]
                while self.myClock.getTime() < waitTill:
                    self.stimFix.draw()
                    self.win.flip()

                trial["type"] = "img"
                stim = self.make_stimulus(trial)

                # Binocular Rivalry - stimulus 2
                self.win.setMouseVisible(False)
                waitTill = self.myClock.getTime() + self.stimTime
                while waitTill > self.myClock.getTime():
                    stim.draw()
                    self.win.flip()

                # Response Dominance Percept 2
                ansInt = self.get_dominance_percept()
                if ansInt == "c":self.run_BRHorizontalAdjust()
                if ansInt == "f":calibrationComplete = True
                try:  trial["domAns2"] = self.ansTypesName[ansInt]
                except:pass

                # if the ppt sees the same percept, or a mix of the two, then decrease the contrast for that percept
                if trial["domAns"] == "blue" and (trial["domAns2"] == "blue" or trial["domAns2"] == "mix"):
                    self.gabor_blue_opacity = self.gabor_blue_opacity  - self.calibrationStep
                    self.gabor_red_opacity = self.gabor_red_opacity + self.calibrationStep
                    self.calibrationSCHistory.append("dom_persist")

                elif trial["domAns"] == "red" and (trial["domAns2"] == "red" or trial["domAns2"] == "mix"):
                    self.gabor_blue_opacity = self.gabor_blue_opacity  + self.calibrationStep
                    self.gabor_red_opacity = self.gabor_red_opacity - self.calibrationStep
                    self.calibrationSCHistory.append("dom_persist")
                else:
                    # the adaptation effect worked
                    self.calibrationSCHistory.append("switch")


                bo = round(self.gabor_blue.opacity,2)
                ro = round(self.gabor_red.opacity,2)
                print("blue: %s" % bo)
                print("red: %s" % ro)

                trial["contrast2_blue"] = self.gabor_blue_opacity
                trial["contrast2_red"] = self.gabor_red_opacity

            csvWriter.writerow(trial.values());file.flush()
            #switch_history = self.calibrationSCHistory[-self.switchHistoryWindow:]
            switch_history = self.calibrationSCHistory

            percept_history = self.calibrationPerceptHistory[-self.switchHistoryWindow:]
            if len(switch_history) > self.numTrialsMinCalibrationBR -1 and switch_history.count("switch") >= self.minSwitches:
                calibrationComplete = True


            else: # continue
                stim = self.make_stimulus(trialList[no + 1])
                no += 1

            bo = round(self.gabor_blue.opacity, 2)
            ro = round(self.gabor_red.opacity, 2)
            print("blue: %s" % bo)
            print("red: %s" % ro)


    def run_adaptation_calibration_merlinBR(self):
        """
        same adaptive staricase, but with the contrast images from the stimuli folder


        :return:
        """


        self.calibrationSCHistory = []
        self.calibrationPerceptHistory = []
        self.calibrationPerceptValues = [0.0,0.5,1.0]
        self.calibrationStep = 0.10


        trialList = self.make_trial_list(phase="BRT_calibration")
        trial = trialList[0]
        saveFile = trialList[0]["filePath"]

        file = open(saveFile, "w")
        print('Writing to record_file {0}'.format(saveFile))
        csvWriter = csv.writer(file, delimiter=',', lineterminator="\n")
        csvWriter.writerow(trialList[0].keys())

        stim = self.make_stimulus(trial)


        calibrationComplete = False
        no = 0
        while calibrationComplete == False:

            # Initial fixation cross ( right after ppt has responed)
            waitTill = self.myClock.getTime() + trial["iti"]
            while self.myClock.getTime() < waitTill:
                self.stimFix.draw()
                self.win.flip()


            # Binocular Rivalry - stimulus
            self.win.setMouseVisible(False)
            waitTill = self.myClock.getTime() + self.stimTime
            while waitTill > self.myClock.getTime():
                stim.draw()
                self.win.flip()

            # Response Dominance Percept
            ansInt = self.get_dominance_percept()
            if ansInt == "c": self.run_BRHorizontalAdjust()
            if ansInt == "f": calibrationComplete = True
            try:trial["domAns"] = self.ansTypesName[ansInt]
            except:pass
            trial["no"] = no
            trial["contrast_blue"] = self.gabor_blue_opacity
            trial["contrast_red"] = self.gabor_red_opacity
            if self.removeMixTrialsCalibrationResult and trial["domAns"] == "mix":pass
            else:
                try:
                    self.calibrationPerceptHistory.append(self.calibrationPerceptValues[ansInt])
                except:pass

            if trial["domAns"] != "mix":

                trial["type"] = "adaptation"
                stim = self.make_stimulus(trial)

                # adaptation effect induction
                self.win.setMouseVisible(False)

                waitTill = self.myClock.getTime() + self.domPerceptAdaptTimePresent
                while waitTill > self.myClock.getTime():
                    stim.draw()
                    self.win.flip()

                # ITI
                waitTill = self.myClock.getTime() + trial["iti"]
                while self.myClock.getTime() < waitTill:
                    self.stimFix.draw()
                    self.win.flip()

                trial["type"] = "img"
                stim = self.make_stimulus(trial)

                # Binocular Rivalry - stimulus 2
                self.win.setMouseVisible(False)
                waitTill = self.myClock.getTime() + self.stimTime
                while waitTill > self.myClock.getTime():
                    stim.draw()
                    self.win.flip()

                # Response Dominance Percept 2
                ansInt = self.get_dominance_percept()
                if ansInt == "c":self.run_BRHorizontalAdjust()
                if ansInt == "f":calibrationComplete = True
                try:  trial["domAns2"] = self.ansTypesName[ansInt]
                except:pass

                # if the ppt sees the same percept, or a mix of the two, then decrease the contrast for that percept
                if trial["domAns"] == "blue" and (trial["domAns2"] == "blue" or trial["domAns2"] == "mix"):
                    self.gabor_blue_opacity = self.gabor_blue_opacity  - self.calibrationStep
                    self.gabor_red_opacity = self.gabor_red_opacity + self.calibrationStep
                    if self.gabor_red_opacity > 1.0: self.gabor_red_opacity = 1.0
                    self.calibrationSCHistory.append("dom_persist")
                    bo, ro = self.find_best_contrast_img(self.gabor_blue_opacity, self.gabor_red_opacity)
                    trial["img"] = pathjoin(self.stimuliFolder, paste("gabor_r", ro, "_", "b", bo, ".png", sep=""))

                elif trial["domAns"] == "red" and (trial["domAns2"] == "red" or trial["domAns2"] == "mix"):
                    self.gabor_blue_opacity = self.gabor_blue_opacity  + self.calibrationStep
                    self.gabor_red_opacity = self.gabor_red_opacity - self.calibrationStep
                    if self.gabor_blue_opacity > 1.0: self.gabor_blue_opacity = 1.0
                    self.calibrationSCHistory.append("dom_persist")
                    bo, ro = self.find_best_contrast_img(self.gabor_blue_opacity, self.gabor_red_opacity)
                    trial["img"] = pathjoin(self.stimuliFolder, paste("gabor_r", ro, "_", "b", bo, ".png", sep=""))

                else:
                    # the adaptation effect worked
                    self.calibrationSCHistory.append("switch")


                bo = round(self.gabor_blue.opacity,2)
                ro = round(self.gabor_red.opacity,2)
                print("blue: %s" % bo)
                print("red: %s" % ro)

                trial["contrast2_blue"] = self.gabor_blue_opacity
                trial["contrast2_red"] = self.gabor_red_opacity

            csvWriter.writerow(trial.values());file.flush()
            #switch_history = self.calibrationSCHistory[-self.switchHistoryWindow:]
            switch_history = self.calibrationSCHistory

            percept_history = self.calibrationPerceptHistory[-self.switchHistoryWindow:]
            if len(switch_history) > self.numTrialsMinCalibrationBR -1 and switch_history.count("switch") >= self.minSwitches:
                calibrationComplete = True


            else: # continue
                stim = self.make_stimulus(trial)
                no += 1

            bo = round(self.gabor_blue.opacity, 2)
            ro = round(self.gabor_red.opacity, 2)
            print("blue: %s" % bo)
            print("red: %s" % ro)



    def run_hfpi_calibrationBR(self):
        """
        heterochromatic flicker photometry for isoluminance
        calbiration


        :return:
        """
        #
        # self.win.setMouseVisible(False)
        # calibrationComplete = False
        #
        # instructText = self.instructionText
        # instructText.setText(self.calibrationHFPIText)
        # instructText.setPos(self.posAbove)
        #
        # while calibrationComplete == False:
        #     self.left_blue_rect.draw()
        #     self.right_blue_rect.draw()
        #     instructText.draw()
        #     self.win.flip()
        #     self.left_red_rect.draw()
        #     self.right_red_rect.draw()
        #     instructText.draw()
        #     self.win.flip()
        #
        #
        #     resp = psychopy.event.getKeys(keyList=self.calibrate_hfpi_keys + self.scaleAcceptKeys + self.quitKeys)
        #
        #     if len(resp):
        #         if resp[0] in self.quitKeys:
        #             psychopy.core.quit()
        #         elif resp[0] == self.calibrate_hfpi_keys[0]:
        #             self.left_blue_rect.opacity -= self.calibrationStepSmall
        #             self.right_blue_rect.opacity -= self.calibrationStepSmall
        #             self.left_red_rect.opacity += self.calibrationStepSmall
        #             self.right_red_rect.opacity += self.calibrationStepSmall
        #
        #         elif resp[0] == self.calibrate_hfpi_keys[1]:
        #             self.left_blue_rect.opacity += self.calibrationStepSmall
        #             self.right_blue_rect.opacity += self.calibrationStepSmall
        #             self.left_red_rect.opacity -= self.calibrationStepSmall
        #             self.right_red_rect.opacity -= self.calibrationStepSmall
        #
        #         elif resp[0] in self.scaleAcceptKeys:
        #             calibrationComplete = True
        #
        #         ro = round(self.left_red_rect.opacity,2)
        #         bo = round(self.left_blue_rect.opacity,2)
        #         print("red: %s" % ro)
        #         print("blue: %s" % bo)
        #         instructText.text = "red: %s blue %s" % (ro,bo)
        #

        if self.viewMode == "mirrors":
            self.win.setMouseVisible(False)
            calibrationComplete = False

            instructText = self.instructionText
            instructText.setText(self.calibrationHFPIText)
            instructText.setPos(self.posAbove)

            self.gabor_blue.pos = self.leftPosCalc
            self.gabor_red.pos = self.rightPosCalc
            self.grl.pos = self.leftPosCalc
            self.gbr.pos = self.rightPosCalc


            while calibrationComplete == False:
                self.gabor_red.draw()
                self.grl.draw()
                instructText.draw()
                self.win.flip()
                if self.hz > 60: core.wait(0.008)
                self.gabor_blue.draw()
                self.gbr.draw()
                instructText.draw()
                self.win.flip()
                if self.hz > 60: core.wait(0.008)

                resp = psychopy.event.getKeys(keyList=self.calibrate_hfpi_keys + self.scaleAcceptKeys + self.quitKeys)

                if len(resp):
                    if resp[0] in self.quitKeys:
                        psychopy.core.quit()
                    elif resp[0] == self.calibrate_hfpi_keys[0]:
                        self.gabor_blue.opacity -= self.calibrationStepSmall
                        self.gbr.opacity -= self.calibrationStepSmall
                        self.gabor_red.opacity += self.calibrationStepSmall
                        self.grl.opacity += self.calibrationStepSmall

                    elif resp[0] == self.calibrate_hfpi_keys[1]:
                        self.gabor_blue.opacity += self.calibrationStepSmall
                        self.gbr.opacity += self.calibrationStepSmall
                        self.gabor_red.opacity -= self.calibrationStepSmall
                        self.grl.opacity -= self.calibrationStepSmall

                    elif resp[0] in self.scaleAcceptKeys:

                        calibrationComplete = True
                        bo = self.gabor_blue.opacity
                        ro = self.gabor_red.opacity

                        if bo > ro:diff = 1.0 - bo
                        else:diff = 1.0 - ro

                        self.gabor_blue.opacity += diff
                        self.gabor_red.opacity += diff

                        self.gabor_blue_opacity = self.gabor_blue.opacity
                        self.gabor_red_opacity = self.gabor_red.opacity



                    bo = round(self.gabor_blue.opacity,2)
                    ro = round(self.gabor_red.opacity,2)
                    print("blue: %s" % bo)
                    print("red: %s" % ro)

                    instructText.text = "red: %s blue %s" % (ro,bo)
        else:
            psychopy.event.clearEvents()
            self.win.setMouseVisible(False)
            calibrationComplete = False

            instructText = self.instructionText
            instructText.setText(self.calibrationHFPIText)
            instructText.setPos(self.posAbove)

            self.gabor_blue.pos = self.posCenter
            self.gabor_red.pos = self.posCenter


            while calibrationComplete == False:
                self.gabor_red.draw()
                instructText.draw()
                self.win.flip()
                if self.hz > 60: core.wait(0.008)
                self.gabor_blue.draw()
                instructText.draw()
                self.win.flip()
                if self.hz > 60: core.wait(0.008)

                resp = psychopy.event.getKeys(keyList=self.calibrate_hfpi_keys + self.scaleAcceptKeys + self.quitKeys)

                if len(resp):
                    if resp[0] in self.quitKeys:
                        psychopy.core.quit()
                    elif resp[0] == self.calibrate_hfpi_keys[0]:
                        self.gabor_blue.opacity -= self.calibrationStepSmall
                        self.gabor_red.opacity += self.calibrationStepSmall


                    elif resp[0] == self.calibrate_hfpi_keys[1]:
                        self.gabor_blue.opacity += self.calibrationStepSmall

                        self.gabor_red.opacity -= self.calibrationStepSmall


                    elif resp[0] in self.scaleAcceptKeys:
                        self.win.clearBuffer()
                        self.win.flip()
                        calibrationComplete = True
                        bo = self.gabor_blue.opacity
                        ro = self.gabor_red.opacity

                        if bo > ro:
                            diff = 1.0 - bo
                        else:
                            diff = 1.0 - ro

                        self.gabor_blue.opacity += diff
                        self.gabor_red.opacity += diff

                        self.gabor_blue_opacity = self.gabor_blue.opacity
                        self.gabor_red_opacity = self.gabor_red.opacity

                    bo = round(self.gabor_blue.opacity, 2)
                    ro = round(self.gabor_red.opacity, 2)
                    print("blue: %s" % bo)
                    print("red: %s" % ro)



    def draw_text_instruct(self, text="text to present"):

        if self.viewMode == "googles:":
            self.instructionText.setText(text)
            self.instructionText.pos = self.posAbove
            self.instructionTextFarFarBelow.setText(self.pressToContinue)

            self.instructionText.draw()
            self.instructionTextFarFarBelow.draw()


        else:
            self.instructionText.setText(text)
            self.instructionText.setPos(self.posAboveLeft)
            self.instructionText.draw()
            self.instructionText.setPos(self.posAboveRight)
            self.instructionText.draw()



    def run_BRT_switch_rate(self, phase="BRT_switchrate"):

        """
        runs a phase of BRT_img
        the imagery component, from Dijkstra 2019, Keogh & Pearson 2018

        """

        dash_print('running %s' % inspect.stack()[0][3])

        saveFile = pathjoin(self.subjectSaveFolder,
                            paste('subject',self.subjectID,phase,
                            "ses",self.session,timestamp(),".csv",sep="_"))

        file = open(saveFile, "w")
        csvWriter = csv.writer(file, delimiter=',', lineterminator="\n")

        trialList = self.make_trial_list("BRT_img_trials")
        trial = trialList[0]
        csvWriter.writerow(trialList[0].keys())
        stim = self.make_stimulus(trialList[0])
        trial["phase"] = phase

        win = self.win
        kb = keyboard.Keyboard()
        stimFix = self.stimFix
        myClock = self.myClock
        myClock.reset()

        instructionText = self.instructionText
        instructionText.setText(self.switchRateInstructText)

        instructionText2 = self.instructionText2
        instructionText2.setText(self.switchRateInstructText)

        instructionText.setPos((self.leftPosCalc[0],self.posAbove[1]))
        instructionText2.setPos((self.rightPosCalc[0],self.posAbove[1]))


        win.setMouseVisible(False)
        switchRateComplete=False
        while switchRateComplete==False:


            stim.draw()
            instructionText.draw()
            instructionText2.draw()
            win.flip()


            resp = psychopy.event.getKeys(keyList=self.calibrate_hfpi_keys + self.scaleAcceptKeys + self.quitKeys)

            if len(resp):
                if resp[0] in self.quitKeys:
                    psychopy.core.quit()
                elif resp[0] == self.calibrate_hfpi_keys[0]:
                    trial["rt"] = myClock.getTime()
                    trial["domAns"] = self.chosenColor2
                    csvWriter.writerow(trial.values())
                    file.flush()
                    instructionText.text = self.chosenColor2
                    instructionText2.text = self.chosenColor2

                elif resp[0] == self.calibrate_hfpi_keys[1]:
                    trial["rt"] = myClock.getTime()
                    trial["domAns"] = self.chosenColor1
                    csvWriter.writerow(trial.values())
                    file.flush()
                    instructionText.text = self.chosenColor1
                    instructionText2.text = self.chosenColor1

                elif resp[0] in self.scaleAcceptKeys:

                    switchRateComplete = True




    def run_BRT_img(self, phase="BRT_img_trials"):

        """
        runs a phase of BRT_img
        the imagery component, from Dijkstra 2019, Keogh & Pearson 2018

        """

        dash_print('running %s' % inspect.stack()[0][3])


        trialList = self.make_trial_list(phase)
        saveFile = trialList[0]["filePath"]
        print('Writing to record_file {0}'.format(saveFile))

        file = open(saveFile, "w")
        csvWriter = csv.writer(file, delimiter=',', lineterminator="\n")
        csvWriter.writerow(trialList[0].keys())


        stim = self.make_stimulus(trialList[0])

        win = self.win
        kb = keyboard.Keyboard()
        stimFix = self.stimFix
        myClock = self.myClock
        myClock.reset()

        instructionText = self.instructionText

        imageryCircle = self.make_imagery_circle(trialList[0])


        prime = self.make_prime(trialList[0])


        no = 0
        dash_print("ready to run experiment for loop")
        while no != len(trialList):

            # Trial Over - Non Critical time part
            trial = trialList[no]
            print("trial no: %s" % no)
            trial["time"] = timestamp()
            trial["timeSecs"] = myClock.getTime()
            trial["trialInitTime"] =  myClock.getTime()

            print(trial["type"])

            win.setMouseVisible(False)

            # Initial fixation cross ( right after ppt has responed)
            waitTill = myClock.getTime() + trial["iti"]
            while myClock.getTime() < waitTill:
                stimFix.draw()
                win.flip()

            # # Cue
            if no < self.instructImgOnFirstNTrials:
                waitTill = myClock.getTime() + self.cueTimeLong
            else:
                waitTill = myClock.getTime() + self.cueTime


            while waitTill > myClock.getTime():
                prime.draw()
                #if "instruct" in phase and self.primeText != "simple":instructionText.draw()
                win.flip()

            # Imagine
            waitTill = myClock.getTime() + self.imagineTime
            win.setMouseVisible(False)
            while waitTill > myClock.getTime():
                imageryCircle.draw()
                #if "instruct" in phase and self.primeText != "simple":instructionText.draw()
                win.flip()



            # vividness questionaire
            if self.rateVivid:
                win.setMouseVisible(True)
                rating, rt = self.get_rate_vivid()

                trial["vivid"] = rating
                trial["vividrt"] = rt

            # Binocular Rivalry - stimulus
            waitTill = myClock.getTime() + self.stimTime
            while waitTill > myClock.getTime():
                stim.draw()
                win.flip()

            # Response Dominance Percept
            ansInt = self.get_dominance_percept()
            if ansInt == "c": self.run_BRHorizontalAdjust()
            try:trial["domAns"] = self.ansTypesName[ansInt]
            except:pass

            if no != len(trialList) - 1:
                prime = self.make_prime(trialList[no+1])
                stim = self.make_stimulus(trialList[no+1])
                imageryCircle = self.make_imagery_circle(trialList[no+1])


            no += 1
            csvWriter.writerow(trial.values());file.flush()



def run_experiment():
    BRT = BRT_experiment()

    if BRT.viewMode == "mirrors":

        if BRT.doBRHorizontalAdjust and BRT.viewMode == "mirrors":
            BRT.run_BRHorizontalAdjust()

        if BRT.calibrationBR:
            BRT.run_hfpi_calibrationBR()

        # if BRT.calibrationBR:
        #     BRT.run_adaptation_calibrationBR()

        if BRT.switchRateTest and BRT.viewMode == "mirrors":
            BRT.run_BRT_switch_rate(phase="BRT_switchrate")

        if BRT.intro:
            BRT.run_BRT_img_introduction()

        BRT.run_BRT_img(phase="BRT_img_trials")

    else:
        if BRT.intro:
            BRT.run_BRT_img_introduction()

        if BRT.calibrationBR:
            BRT.run_hfpi_calibrationBR()

        if BRT.switchRateTest:
            BRT.run_BRT_switch_rate(phase="BRT_switchrate")



        BRT.run_BRT_img(phase="BRT_img_trials")


# ----------------- Actual Run Experiment ------------------------#
if __name__ == "__main__":
    run_experiment()
    print("Done - running core.quit()")
    core.quit()
