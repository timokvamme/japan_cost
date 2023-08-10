# -*- coding: utf-8 -*-
"""
Project:  Japan_cost -
Script: "BRT_settings"
Created on 26 July 11.07 2023

@author: 'Timo Kvamme
"""
# ---------------------------------------------------------------#
# ------------------------- IMPORTS -----------------------------#
# ---------------------------------------------------------------#

from __future__ import division

import pandas as pd

from myFunctions import *


"""  # for testing in console

class BRT_settings():
    def __init__(self):
        print('creating %s' % __class__.__name__)
        
self = BRT_settings() 

"""

class BRT_settings():
    def __init__(self):
        print('creating %s' % __class__.__name__)

    def display_settings(self):
        # ---------------------------------------------------------------#
        #---------------------- Display Settings ------------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])

        self.displayResolution = [1920,1080]
        #self.displayResolution = [1920,800]
        self.centerScreen =self.displayResolution[0] / 2, self.displayResolution[1] / 2
        self.displayResolutionCalibration = 500, 500
        self.fullscreen = False
        self.monWidth = 38.5
        self.monDistance = 60  # in cm
        self.monHeight = 29.7
        self.units = "deg"
        #http://osdoc.cogsci.nl/miscellaneous/visual-angle/#convert-pixels-to-visual-degrees

        # Calculate the number of degrees that correspond to a single pixel. This will
        # generally be a very small value, something like 0.03.
        self.degPerPx = math.degrees(math.atan2(.5 * self.monHeight, self.monDistance)) / (.5 * (self.displayResolution[1]))
        print('%s degrees correspond to a single pixel' % self.degPerPx)


        #pictureSize *= 1.00  # may change

        self.recalibrationRectSize = 15,15


    def directory_settings(self):
        # ---------------------------------------------------------------#
        # ------------Directory Settings / Folder Settings --------------#
        # ---------------------------------------------------------------#
        # folders, directorys and files, extensions
        dash_print('creating %s' % inspect.stack()[0][3])

        self.cwd = os.getcwd()
        self.pwd = get_parent_folder_from_path(self.cwd)
        self.saveFolder = pathjoin(self.cwd,'data')
        self.stimuliFolder = pathjoin(self.cwd,"stimuli")
        make_os_print(self.saveFolder)

        self.salientFilesN = 18  # this should be the same you end up with from the VAS_ALC_ET.py


    def stimuli_settings(self):
        # ---------------------------------------------------------------#
        #-------------------- Stimuli Settings & Stimulus Settings ------#
        # ---------------------------------------------------------------#
        # stimuli names, amount of stimuliations, text, colors, degrees
        dash_print('creating %s' % inspect.stack()[0][3])

        self.stim1 = "Red"
        self.stim2 = "Blue"

        self.ansTypesName = [x.lower() for x in [self.stim1,'mix',self.stim2]]

        # ---------- color settings --------------
        self.backgroundColor = "black"
        self.foregroundColor = "white"
        self.scaleMarkerColor = "green"

        self.chosenColor1 = self.ansTypesName[0]
        self.chosenColorMix = "green"
        self.chosenColor2 = self.ansTypesName[2]

        # ---------------------- text settings ----------------------

        self.fixHeight = 60 * self.degPerPx
        self.wrapWidth = 2000
        self.textHeightSmall = 0.15
        self.textHeightBig = 1.0
        self.textHeight = 0.7
        self.textHeightSmall = 0.7
        self.font = 'MS Gothic'
        self.font = "Courier"
        self.opacityCircle = 1
        self.fixCircleradius= 0.1 / self.degPerPx
        self.imgCircleradius = 0.2 / self.degPerPx


        # ---------------------- stimulus size settings ----------------------

        self.sizeGabor =  (5, 5)
        self.pictureSizeOrginial = np.array([450,600])
        self.pictureSizeOrginial = self.pictureSizeOrginial *  self.degPerPx
        self.pictureSizeOrginial = np.asarray(self.pictureSizeOrginial)
        self.pictureSizeScaleFactor = 0.7

        self.pictureSize = self.pictureSizeOrginial * self.pictureSizeScaleFactor
        self.pictureSizeOrginial = self.pictureSize
        self.NSpaceBetweenPrimes = 10

        self.pictureSizeInstruct = np.array([0,0])

        self.backgroundPictureSizeOrginial = self.pictureSizeOrginial * 1.3

        self.calibrationSCHistory = []

        # ---------------------- stimulus contrast settings ----------------------
        self.full_gabor_opacity = 1.0
        self.gabor_high_opacity = 1.0
        self.gabor_low_opacity = 0.8
        self.calibrationStep = 0.05
        self.calibrationStepSmall = 0.01
        self.removeMixTrialsCalibrationResult = True # should mix trials be counted in calibration average?


    def position_settings(self):
        # ---------------------------------------------------------------#
        # ------------------ Postion Settings -------------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])

        deg_per_px = self.degPerPx

        self.leftPos = (-6.0  , 0.0) # set in helper functions aswell
        self.lP = self.leftPos
        self.rightPos = (6.0 , 0.0)
        self.rP = self.rightPos
        self.leftPosCalc = self.lP
        self.rightPosCalc = self.rP

        self.posFix = (0.0, 0.0)
        self.textPos = (0.0,0.0)
        self.posCenter = (0, 0)
        self.ratingScalePos = 0,-3
        self.arrowPos = -10.0
        self.mouseIndicatorPos = self.posCenter
        self.keyboardIndicatorPos = (8.0 , -7.0)

        self.shift_right = -2
        self.posCloseAbove = (0.0,1.0)
        self.posCloseBelow = (0.0, -1.0)
        self.posAbove = (0, 3.5)
        self.posFarAbove = (0, 6.0)
        self.posFarFarAbove = (0, 9.0)
        self.posFarFarFarAbove = (0, 11.0)
        self.posBelow = (0, -3.0)
        self.posFarBelow = (0, -6)
        self.posFarAboveLeft = (-7.0, 7.0 )
        self.posFarAboveRight = (7.0, 7.0)
        self.posFarFarAboveLeft = (-9.0, 9.0 )
        self.posFarFarAboveRight = (9.0, 9.0)
        self.posAboveLeft = (self.leftPos[0], self.posAbove[1])
        self.posAboveRight = (self.rightPos[0], self.posAbove[1])
        self.posBelowLeft = (self.leftPos[0], self.posBelow[1])
        self.posBelowRight = (self.rightPos[0], self.posBelow[1])
        self.posFarFarBelow = (0, -9)


        self.textPosFarFarBelow = (0, -9. )
        self.MouseOutOfScreenPos = 1920, 540 # right  middle  (traditional cords, non psychoipy)
        self.mouseAboveCenterScreenPos = 960, 430 # basicly set it in the middle of the screen (used for cuereact)


        self.calibrationWindowPos = (1300, 200)
        self.recalibrationTextPos = (4.0 , 1.0 )
        self.recalPosTL = [796, 162];self.recalPosTR = [809, 149];self.recalPosBR = [809, 137];self.recalPosBL = [796136]
        self.horizontalStepRate = 0.5
        self.horizontalStepRateChange = 0.10
        self.gabor_min_offset =  -1

        # load bar
        self.loadBarWidth = 2
        self.loadbarHeight = 0.5
        self.loadbarYpos = -4
        self.loadbarLowYpos = -7

        # mouse
        self.minDistanceToAns = 3


    def eyetracking_settings(self):
        # ---------------------------------------------------------------#
        # ------------------ Eyetracking Settings -----------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])

        self.DISPTYPE = 'psychopy'
        self.DISPSIZE = self.displayResolution
        self.TRACKERTYPE = 'opengaze'
        print("tracker type: {0}, recording display {1},tracker display size {2}".format(self.TRACKERTYPE,self.DISPTYPE,self.DISPSIZE))
        #Calculation of Feedback text - based on hz, n packets
        self.eyetrackerHz = 60
        self.refreshRate = (1000 / self.eyetrackerHz)
        self.degreesPerSecondThreshold = 40 # this is the speed imit in degree
        self.pixelPerSampleThreshold = self.degreesPerSecondThreshold / self.eyetrackerHz
        self.bE = self.pxBorderExtent =  30
        # Criterion on fixation on Cross
        self.pxFixCriterion = 1.5


    def keyboard_settings(self):
        # ---------------------------------------------------------------#
        # ------------------ Keyboard Settings --------------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])

        self.backKeys = ['f']
        self.escapeKeys = self.quitKeys = ['escape', 'esc']
        self.scaleAcceptKeys = [' ','space', 'enter','RETURN','return']
        self.ansKeys = ['1', '2','3']
        self.recalibrationKey = ["c"]
        self.continueKey = ["f"]
        self.rateVividKeys = ['left','right']
        self.calibrate_hfpi_keys = ['left','right']
        self.waitRelease = False
        self.ansKeysName = ['Z', 'M']
        self.continueKeys = [' ','space', 'enter','RETURN','return']
        self.continueKeyName = ['space']
        self.rateKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
        self.anyKey = [self.backKeys,self.quitKeys,self.ansKeys,self.continueKeys,
                       self.rateKeys]


    def timing_settings(self):
        # ---------------------------------------------------------------#
        # ------------------ Timing Settings ----------------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])


        self.hz = 100
        # in seconds  #Inter Stimulus Interval
        self.iti = 0.250 # time after response until the trial starts
        self.cueTime = 0.750
        self.cueTimeLong = 2.000
        self.imagineTime = 5.000
        self.stimTime = 0.750
        self.confirmRespTime = 0.250
        self.domPerceptAdaptTimePresent = 4.000

        self.loadingBarTime = 2.0
        self.loadingBarTimeLong = 4.0


    def execution_settings(self):
        # ---------------------------------------------------------------#
        # ------------------ Execution Settings -------------------------#
        # ---------------------------------------------------------------#
        # defaults, number of trials, parameters stimulus types, instructionText
        # paradigm specific options, default language, instruct trials, test modes
        dash_print('creating %s' % inspect.stack()[0][3])


        self.giveFeedback = True
        self.intro = True
        self.instruct = True
        self.testMode = False
        self.ET = False
        self.primeText = "full"
        self.defaultLanguages = ["English"]
        self.language = self.defaultLanguages[0]
        self.input = ["mouse"]
        self.viewModes = [ "googles","mirror"]
        self.viewMode = self.viewModes[0]
        self.rateVivid = True
        self.sessionChoices = [1, 2]
        self.session = self.sessionChoices[0]
        self.subjectID = "0001"
        self.eyeDom = "left"
        self.eyeDomChoices = ["left","right"]
        self.doBRHorizontalAdjust = True
        self.calibrationBR = True
        self.switchRateTest = False
        self.nextSubjectCalc = False
        self.doDlg = False # used during testing



        self.subjectSaveFolder = pathjoin(self.saveFolder,paste('subject_',self.subjectID))
        self.eyeDomFile = pathjoin(self.subjectSaveFolder,paste('subject_',self.subjectID,"_eyeDom.csv"))
        make_os_print(self.subjectSaveFolder)
        write_setting_to_file(self.eyeDomFile)

    def dlg_activated_settings(self):

        # ---------------------------------------------------------------#
        # ------------------ Dlg Activated Settings ---------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])

        # ---------------------- stimulus contrast settings ----------------------

        # if the ppt is left eye dominant then set the blue (left) stimulus as less contrast/opacity
        # calibration should run faster this way since domiance will will change percept
        if self.eyeDom == "left":
            self.gabor_blue_opacity = self.gabor_low_opacity
            self.gabor_red_opacity = self.gabor_high_opacity

        else:
            self.gabor_blue_opacity = self.gabor_high_opacity
            self.gabor_red_opacity = self.gabor_low_opacity

        if self.calibrationBR == False:
            try:
                df = pd.read_csv(get_newest_file_with_keyword(self.subjectSaveFolder,keyword="calibration"))
                self.gabor_blue_opacity = df["contrast_blue"][len(df)-1]
                self.gabor_red_opacity = df["contrast_red"][len(df)-1]

            except:
                print("could not find calibration file for subject %s in %s" % (self.subjectID,self.subjectSaveFolder) )
                self.calibrationBR = True
                self.gabor_blue_opacity = 1.0
                self.gabor_red_opacity = 1.0

        try:
            df = pd.read_csv(
                self.subjectSaveFolder + '\\' + 'subject_' + str(str(self.subjectID)) + "_calibrationBR" + '.csv')
            self.leftPosCalc = (df["gabor_blue_pos"][len(df) - 1],self.lP[1])
            self.rightPosCalc = (df["gabor_red_pos"][len(df) - 1],self.rP[1])
        except:
            print("could not find horizontal calibration file for subject %s in %s" % (
            self.subjectID, self.subjectSaveFolder))
            self.doBRHorizontalAdjust = True


        if self.viewMode == "googles":
            self.imgCircleradius = 0.1 / self.degPerPx
            self.leftPosCalc = self.posCenter
            self.rightPosCalc = self.posCenter
        else:
            self.imgCircleradius = 0.1 / self.degPerPx


    def language_settings(self):

        # ---------------------------------------------------------------#
        # ------------------ Language Settings --------------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])

        # its prolly just plain ol english

        self.introText = "In this task you will see some red and blue grating stimuli\n\nplease put on the blue/red googles\n\npress space to continue" if self.viewMode == "googles" else  "In this\n" \
                                                                                                      "task you\n" \
                                                                                                      "will see\n" \
                                                                                                      "some red\n" \
                                                                                                              "and blue\n" \
                                                                                                              "grating stimuli\n\n" \
                                                                                                                                                    "" \
                                                                                                                                                    "press space\n" \
                                                                                                                                                    "to continue" \


        self.calibrationTextIntro = "rate whether you saw a red, blue or mixed stimulus" if self.viewMode == "googles" else "rate\n" \
                                                                                                                            "whether\n" \
                                                                                                                            "you saw\n" \
                                                                                                                            "a red,\n" \
                                                                                                                            "blue or\n" \
                                                                                                                            "mixed \n" \
                                                                                                                            "stimulus"


        self.calibrationHFPIText = "press the\n" \
                                   "left and right\n" \
                                   "keys until\n" \
                                   "the stimulus\n" \
                                   "no longer\n" \
                                   "flickers"

        self.switchRateInstructText = "report blue/red\n" \
                                      "percept switches\n" \
                                      "left/right keys"

        self.pressToStartText = u'press to start'
        self.takeABreak = self.textBreak = u'take a break'
        self.practiceText = "try this in the following rounds"
        self.fixationText = u'look at the fixation cross'
        self.horizontalAdjustText = u'use the arrows [left/right] to adjust the gabor patches so they overlap\n' \
                                    u'you can change the step increase/decrease on [up/down] arrows\n' \
                                    u'enter to accept'
        self.tryYourself = u'try yourself'
        self.pressToContinue = u'press space to continue'
        self.pressToAccept = u'press space to accept'
        self.correctText = u'correct!'
        self.wrongText = u'wrong!'
        self.tooLateText = u'too late, answer faster!'
        self.wrongTextTryAgain = u'wrong try again '
        self.waitText = u'wait'
        self.clickLineText = u"click on the line"
        self.breaksLeftText = "breaks left"
        self.vividnessJudgementText = " rate how vivid you imagined the stimuli" if self.viewMode == "googles" else "rate how\n" \
                                                                                                                    "vivid you\n" \
                                                                                                                    "imagined the\n" \
                                                                                                                    "stimulus"
        self.ansText = "Which grating did you see ?" if self.viewMode == "googles" else "Which\n" \
                                                                                        "grating\n" \
                                                                                        "did you\n" \
                                                                                        "see?"
        self.ansText0 = "Red = %s" % self.ansKeys[0]
        self.ansText1 = "Mix = %s" % self.ansKeys[1]
        self.ansText2 = "Blue = %s" % self.ansKeys[2]
        self.imageryInstructText = "Here you imagine the stimulus"
        self.RecalibrateGetLeader = "Call on Experimenter"
        self.reCalibrationDoneQuestion = "press here When reCalibration is over"


        if self.language == 'Danish':
            self.introText = "I denne opgave skal du trække og skubbe i et joystick"
            self.pressToStartText =  u'Tryk for at Begynde'
            self.takeABreak = self.textBreak = u'tag en pause'
            self.practiceText = "Prøv dette i de følgende runder"
            self.fixationText = u'Kig på Fixations Krydset'
            self.tryYourself = u'Prøv Selv'
            self.ImageChosenText = u'Dine Billeder er Valgt'
            self.pressToContinue = u'tryk på mellemrumstasten for at fortsætte'
            self.pressToAccept = u'tryk på Mellemrumstasten for at godkende'
            self.correctText = u'Korrekt!'
            self.wrongText = u'Forkert!'
            self.tooLateText = u'For sent, svar hurtigere!'
            self.premPushText = u"du skubbede i joysticket for tidligt"
            self.premPullText = u"du trækkede i joysticket for tidligt"
            self.wrongTextTryAgain = u'Forkert! prøv igen'
            self.waitText = u'vent'
            self.clickLineText = u"klik på linjen for at indikere hvor kraftigt du visualizerede stimulien"
            self.breaksLeftText = "pauser tilbage"

            self.RecalibrateGetLeader = "Kald på forsøgsleder"
            self.reCalibrationDoneQuestion = "press here When reCalibration is over"
            self.joystickBack = "sæt joysticket tilbage til midt positionen"
            self.putJoystickBackTextInstroduction = self.joystickBack + " når du er færdig"
            self.stringInstructPull  = "trække bagud i joysticket" if self.input == "joystick" else "trykke på ned knappen"
            self.stringInstructPush  = "skubbe fremad i joysticket" if self.input == "joystick" else "trykke på op knappen"




    def trials_settings(self):

        # ---------------------------------------------------------------#
        # ---------------------- trials Settings ------------------------#
        # ---------------------------------------------------------------#
        dash_print('creating %s' % inspect.stack()[0][3])

        self.numTrialsBRT_img = 100
        self.numTrialsMinCalibrationBR = 10
        self.numTrialsMaxCalibrationBR = 20
        self.minSwitches = 8 #
        self.switchHistoryWindow = 10
        self.mockTrialsPercent = 1/10
        self.numImgTrials = int((1.0 - self.mockTrialsPercent) * 10)
        self.numMockTrials = int(self.numTrialsBRT_img * self.mockTrialsPercent)

        self.instructImgOnFirstNTrials = 6 # instruct on all trials

        # self.blankPicture = pathjoin(self.stimuliFolder,"blank.png")
        #
        # self.instructTrials = [(self.blankPicture,'landscape', '%s' % self.leftTiltInstruction),
        #                        (self.blankPicture,'portrait', '%s' % self.rightTiltInstruction),
        #                        (self.blankPicture,'landscape', '%s' % self.leftTiltInstruction),
        #                        (self.blankPicture,'landscape','%s' % self.leftTiltInstruction),
        #                        (self.blankPicture,'portrait', '%s' % self.rightTiltInstruction),
        #                        (self.blankPicture,'landscape', '%s' % self.leftTiltInstruction),
        #                        (self.blankPicture,'portrait', '%s' % self.rightTiltInstruction),
        #                        (self.blankPicture,'landscape', '%s' % self.leftTil9tInstruction),
        #                        (self.blankPicture,'landscape', '%s' % self.leftTiltInstruction)]



        #self.trialParamFile = "C:\\code\\projects\\hypnoalc\\BRT\\trialParams.xlsx"


