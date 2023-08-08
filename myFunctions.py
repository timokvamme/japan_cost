# -*- coding: utf-8 -*-
"""
Project:  userfunctions - 
Script: " MyFunctions"
Created on 23 February 14:43 2022 

@author: 'Timo Kvamme'
"""
# -------------- IMPORTS -----------------------------#
import os,sys,platform, random, csv, time, math, csv, datetime, shutil,itertools, re, win32api,\
    inspect, subprocess,pathlib, psychopy, psychopy.core, psychopy.event, psychopy.gui, \
    psychopy.visual, copy, tqdm

import numpy as np
import pandas as pd
from scipy.spatial.distance import cdist

def set_mouse_at_pos(pos):
    try:
        win32api.SetCursorPos(pos)
    except Exception as e:
        print("could not set win32api.SetCursorPos(%s)"% str(pos))
        print("failed with exception: %s"% str(e))

def os_make_dir(dir,silent=False):


    if not os.path.isdir(dir):
        os.makedirs(dir)
        if silent == False:
            print("making directory: %s " % dir )

    else:
        if silent == False:
            print("directory: %s already exisits" % dir )


def make_os_print(folder):
    if not os.path.isdir(folder):
        os.makedirs(folder)
        print("creating: %s" % folder)
    else: print("folder %s exists" % folder)



def get_key_from_dict(my_dict,val):
    for key, value in my_dict.items():
        if val == value:
            return key

    return "key doesn't exist"

def get_folder_from_path(path):
    folder = path.replace(path.split("\\")[-1],"")
    return folder

def get_parent_folder_from_path(path):
    path = pathlib.Path(path)
    return path.parent.absolute()


def panic_print(msg="panicPrint"):
    print("------------------------------------------------")
    print("------------------- Panic! ---------------------")
    print("------------------------------------------------")
    print(msg)
    print("------------------------------------------------")
    print("------------------------------------------------")
    print("------------------------------------------------")



def dash_print(msg="dashPrint"):
    print("------------------------------------------------")
    print(msg)
    print("------------------------------------------------")

def length(x):
    return len(x)

def listdir_fullpath(d):
    return [os.path.join(d, f) for f in os.listdir(d)]

def get_basename_of_path(path):
    from pathlib import Path
    return Path(path)

def pathjoin(*args):
    return(os.path.join(*args))

def find_nearest(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return array[idx]

def timestamp(timestamp_format='%Y_%m_%d_%H_%M_%S'):
    import time
    return time.strftime(timestamp_format,time.localtime())

# for elsewhere
#  time.strftime('%Y_%m_%d_%H_%M_%S',time.localtime())


def insert_pre_post_fix_timestamp_before_extension_in_file(filename,pre_fix="",post_fix="",timestamp=True):
    import time
    ts = time.strftime('_%Y_%m_%d_%H_%M_%S',time.localtime()) if timestamp else ""

    post_fix = '_' + post_fix if post_fix != "" else ""
    pre_fix = pre_fix + "_" if pre_fix != "" else ""

    parts = filename.split('.')
    return pre_fix + "".join(parts[:-1]) + post_fix + ts  + '.' + parts[-1]

def get_all_paths_in_directory_and_subdirectory(dir):
    import os
    return [os.path.join(path, name) for path, subdirs, files in os.walk(dir) for name in files]


def get_all_paths_in_folder_and_subfolder(folder):
    import os
    return [os.path.join(path, name) for path, subdirs, files in os.walk(folder) for name in files]


def get_file_name_from_path(path,extension=True):
    import os
    from pathlib import Path
    toReturn = os.path.basename(path) if extension else Path(path).stem
    return toReturn

def get_parrent_dir_of_file(file):
    from pathlib import Path
    path = Path(file)
    return path.parent.absolute()

def xrange(*ll):
    return list(range(*ll))

def listrange(*ll):
    return list(range(*ll))


def rename_and_copy_folder_content(folder,dest_folder,add_postfix="v",add_timestamp=True,delete_ori=False,ignore_files=[""]):
    """
    takes an argument folder
    goes through folder content
    then renames each file by inserting before the extention with a postfix and a timestamp
    ize before the original file is removed.

    :param folder: a folder to copy
    :param dest_folder: destiation folder (str) where the file are to be copied to
    :param add_postfix: str. a text to be added before a timestamp
    :param add_timestamp: Bool, True or False, whether to add a timestamp
    :param delete_ori: bool, True or False, whether to delete the source file after checking
    :return: dict_ list of src, dst

    """

    ll = dict()
    files = get_all_paths_in_directory_and_subdirectory(folder)

    for file in tqdm.tqdm(files):
        if file not in ignore_files:
            sub_folder = get_parrent_dir_of_file(file,fullpath=False)
            if not os.path.exists(os.path.join(dest_folder,sub_folder)):os.mkdir(os.path.join(dest_folder,sub_folder))

            new_file = insert_pre_post_fix_timestamp_before_extension_in_file(filename=get_file_name_from_path(file),post_fix=add_postfix,timestamp=add_timestamp)
            dst = os.path.join(dest_folder,sub_folder,new_file)
            src = file

            #print("src_ %s dst %s" % (src,dst))
            print("found file: %s renamed to %s " % (file,new_file) )
            print("moved to %s" % dst)
            copyfile(src,dst)
            ll.update({src:dst})
            if os.path.exists(dst) and delete_ori:
                print("removing source")
                os.remove(src)

        else:
            print("file %s was in ignore_files... skipping" % file)

    return ll


def copy_sub_folder_content_of_folders(folders,dest_folder,delete_ori=True,ignore_files=[""]):
    """
    takes an argument folders a list (can be 1)
    goes through folders
    and looks into subfolders and creates that subfolder on a dest_folder

    then compares if files in original subfolders, are on the subfolders on the dest_folder.

    if they are not there, they are copied and they are compared in size before the original file is removed.

    :param folders: list of string paths (can be 1)
    :param dest_folder: destiation folder (str) where the file are to be copied to
    :param delete_ori: bool, True or False, whether to delete the source file after checking
    :return: dict_ list of src, dst

    """

    ll = dict()

    for folder in tqdm.tqdm(folders):

        files = get_all_paths_in_directory_and_subdirectory(folder)

        for file in tqdm.tqdm(files):
            sub_folder = get_parrent_dir_of_file(file,fullpath=False)

            if file not in ignore_files:
                # if the sub_folder does not exist.  Raw or SubjectDir
                if not os.path.exists(os.path.join(dest_folder,sub_folder)):os.mkdir(os.path.join(dest_folder,sub_folder))
                dst = os.path.join(dest_folder,sub_folder,get_file_name_from_path(file))
                src = file
                size_ori =  os.stat(src).st_size

                # if the destination file does not exist?

                if os.path.exists(dst) and os.stat(dst).st_size == size_ori:
                    print("this file already exists??? (and is same size).. skipping - %s " % dst)

                else:
                    if os.path.exists(dst) and os.stat(dst).st_size != size_ori:
                        print("dst file %s exists, but is not the correct size" % dst)

                    #print("src_ %s dst %s" % (src,dst))
                    print("found file: %s" % file)
                    copyfile(src,dst)
                    ll.update({src:dst})
                    if os.path.exists(dst):
                        print("moved to server: %s" % dst)
                        if os.stat(dst).st_size == size_ori:
                            print("file source file is now on on server, and is the correct size")
                            if delete_ori:
                                print("removing source")
                                os.remove(src)

            else:
                print("file %s was in ignore_files... skipping" % file)


    return ll



def subset(df, query="Col_A > Col_B & Col_C != 90 or Col_D == 'Active' ", select=[""], unselect=[""], asindex=False,returnFullDFIFError=True):


    df_original = df
    query_ori = query
    query_ex = 'Col_A>Col_B&Col_C!=90|Col_D=="Active"'  # example text

    # import pandas as pd
    # import re
    # data = {'Name': ['Tom', 'nick', 'krish', 'jack'], 'Age': [20, 21, 19, 18],"Age2":[10,21,22,30]}
    # df = pd.DataFrame(data)
    # asindex = False
    # select = ("")
    #
    # #query = "Name == 'Tom' and Name != krish or Age == 18 and Age > 19 | Age == 20"

    # list_con = ["Tom", "nick"]
    # query = "Name %in% list_con or Age == 18 and Age > 19 | Age == 20"

    #-----------
    # select, unselect should be lists

    if type(select) == tuple: select = list(select)
    if type(unselect) == tuple: unselect = list(unselect)


    query = str(query)
    query = query.replace("|", "%")
    query = query.replace("&", "~")
    query = query.replace(" or ", "%")
    query = query.replace(" and ", "~")
    query = query.replace(" in ", "%in%")
    query = query.replace(" not in", "%!in%")
    query = query.replace(" ! in", "%!in%")
    query = query.replace(" !in", "%!in%")

    query = query.replace(" ", "")
    query = query.replace("'", "")

    ors = []
    for m in re.finditer("%", query):
        ors.append(m.start())
    ands = []
    for m in re.finditer("~", query):
        ands.append(m.start())

    queries = re.split('%|~', query)

    ors = np.array(ors)
    ands = np.array(ands)

    in_operator = ["%in%", "%!in%"]
    finds = ["==", "!="] + in_operator

    new_qs = []
    for q in queries:
        for find in finds:
            for m in re.finditer(find, q):


                m.end()

                try:
                    int(q[m.end():len(q)])
                except:  # print(q)
                    if find == in_operator[0]:
                        q = q.replace(in_operator[0], " in @")

                        q[0:m.start()] + ".isin(@" + q[m.end():] + ")"


                    elif find == in_operator[1]:
                        q = q[0:m.end()] + q[m.end():len(q)]
                        q = q.replace(in_operator[1], " not in @")


                    else:

                        q = q[0:m.end()] + '"' + q[m.end():len(q)] + '"'

        new_qs.append(q)

        if len(ors) == 0 and len(ands) == 0:
            pass

        elif len(ors) == 0:
            new_qs.append("~");
            ands = np.delete(ands, 0)
        elif len(ands) == 0:
            new_qs.append("%");
            ors = np.delete(ors, 0)

        elif ands[0] > ors[0]:
            new_qs.append("%");
            ors = np.delete(ors, 0)
        elif ands[0] < ors[0]:
            new_qs.append("~");
            ands = np.delete(ands, 0)

        else:
            pass

    query = ''.join(new_qs)

    # perhaps subsitute all the True and False to something liek % and then convert it back to it again after the conversion.
    query = query.replace("%", "|")
    query = query.replace("~", "&")

    # query = query.replace("'", "")
    # print(query)
    # if none given:
    if select == ("") and unselect == (""):
        select = df.columns
    elif len(unselect) > 1 and len(select) > 1:
        print("cant use select while using unselect")
    elif len(unselect) > 1:
        select = df.columns
        select = [x for x in select if x not in unselect]

    if query != query_ex and asindex == False:

        df = pd.DataFrame(df.query(query)[select])  # perform query and return selected - normal thing

    elif query == query_ex and asindex == False:

        df = pd.DataFrame(df[select])

    elif query != query_ex and asindex:

        df = df.query(query).index

    elif query == query_ex and asindex:
        df = df.index



    else:
        df = pd.DataFrame(df.query(query)[select])

    if len(df) == 0:
        print("DataFrame now has 0 rows, something went wrong?\n"
              " in query:  " + str(query_ori) + " \nreverting to original df")
        if returnFullDFIFError:
            df = df_original
        else:
            df = None


    return df





def pd_add_row(df=pd.DataFrame(), row=None, col=None,dict=None):

    if all(v is not None for v in [row, col]):
        cur_df = pd.DataFrame([row], columns=col)
        if df.shape[1] == 0:
            df = cur_df
        else:
            df = df.append(cur_df)

    else:
        cur_df =  pd.DataFrame.from_dict(dict, orient='index')
        cur_df = cur_df.transpose()
        if df.shape[1] == 0:
            df = cur_df
        else:
            df = pd.concat([df,cur_df])


    return df



def c(*args): # R in Python
    return([arg for arg in args])



def paste(*args,sep=""):
    c = ""
    for no, arg in enumerate(args):
        sep_to_use = sep if no != len(args) -1 else ""
        c = c +str(arg) + sep_to_use
    return c

def multiply_list(myList) :

    # Multiply elements one by one
    result = 1
    for x in myList:
        result = result * x
    return result



def make_os_print(folder):
    if not os.path.isdir(folder):
        os.makedirs(folder)
        print("creating: %s" % folder)
    else:
        print("tried to make %s, but it already exists" % folder)


def find_substring_between_substrings(string,start,stop):
    s = '%s(.*)%s' % (start,stop)
    result = re.search(s, string)
    result = result.group(1)
    return result


def copy_file(src,dst,verbose=True):
    try:
        shutil.copy(src,dst)
        if verbose:
            print("copied: %s to %s"%(src,dst))
    except Exception as e:
        print("Error could not copy: %s to %s\nexception below:"%(src,dst))
        print(e)


def trig_diff(trig1,trig2,add_pos=10):

    trig1 = float(str(trig1)[:add_pos] + '.' + str(trig1)[add_pos:])
    trig2 = float(str(trig2)[:add_pos] + '.' + str(trig2)[add_pos:])

    diff = trig2 - trig1
    return diff

def closest_node(node, nodes):
    return nodes[cdist([node], nodes).argmin()]

def find_closest_point_to_points(point, points):
    return points[cdist([point], points).argmin()]

def ranks(sample):
    """
    Return the ranks of each element in an integer sample.
    """
    indices = sorted(range(len(sample)), key=lambda i: sample[i])
    return sorted(indices, key=lambda i: indices[i])

def sample_with_minimum_distance(n=40, k=4, d=10):
    """
    Sample of k elements from range(n), with a minimum distance d.
    """
    sample = random.sample(range(n-(k-1)*(d-1)), k)
    return [s + (d-1)*r for s, r in zip(sample, ranks(sample))]

def find_digit_in_string(haystack):
    needles = re.findall('[0-9]+', haystack)
    if len(needles) == 0:
        needle="found no digits in string"
        print(needle)
    elif len(needles) == 1:
        needle = needles[0]
    else:
        needle = needles[0]
        print("found more than 1 digit in string %s took the firt one: %s" %(needles,needle))
    return needle


def find_number_in_string(haystack):
    needles = re.findall('[0-9]+', haystack)
    if len(needles) == 0:
        needle="found no number in string"
        print(needle)
    elif len(needles) == 1:
        needle = needles[0]
    else:
        needle = needles[0]
        print("found more than 1 digit in string %s took the firt one: %s" %(needles,needle))
    return needle

def get_newest_file_with_keyword(folder= "", keyword="calibration"):

    list_of_files = [pathjoin(folder,f) for f in os.listdir(folder) if keyword in f ]
    latest_file = max(list_of_files, key=os.path.getctime)

    return  latest_file


def calculate_next_subject(saveFolder):
    """based on a savefolder finds the next subject id
    assumes the standard way of saving subject in folders:

    subject_0001
    subject_0002
    ect"""
    try:
        os_make_dir(saveFolder)
        subjects_in_data_folder = os.listdir(saveFolder)

        if len(subjects_in_data_folder) == 0:
            nextid = "%04d" % int(1)

        else:
            ll = []#list of subject ids
            for folder in subjects_in_data_folder:
                ll.append(int(find_digit_in_string(folder)))
            nextid = "%04d" % int(max(ll) + 1)
    except Exception as e:
        print("couldnt run calculatenextsubject based on savefolder: %s\nsetting 0001 as nextID" % saveFolder)
        print("exception is : %s" % e)
        nextid = "0001"

    return nextid



def num_trials_calculator_iterate_parameters_sequence_control_make_all_parameters(file="C:\\code\\projects\\hypnoalc\\AAT\\trialParams.xlsx",initSeed = 0):
    """
    have a look at hypnoalc\AAT\trialParams, this probably only works with 2 params with two levels


    numTrialsCalculatorIterate
    gets an input in NumTrials
    then it

    xTrials

    :param numTrials: the "proposed" numtrials, you want to figure out if can be performed
    :param parametersToIterate: the parameters to iterate over and add, this is specific for the AAT task
        here i only use the PicNum



    :return: returns the numTrials used as input is divisable, else it returns the advisable/recommended amount
    """
    sequences = pd.read_excel(file)

    # test
    row = sequences.loc[1]
    init = True

    trialTypes = {}
    for index, row in sequences.iterrows():
        if not isinstance(row["col1"],int):
            trialSequenceType += [list(row.values)]
            if len(sequences) -1 == index:
                trialTypes.update({sequenceInt:trialSequenceType})

        else:
            if init == False:
                trialTypes.update({sequenceInt:trialSequenceType})

            sequenceInt = int(row["col1"])
            trialSequenceType = []
            init=False

    # lenght of sequence and amount of replications
    replication = {3:1,2:3,1:12}
    totalSampleSpace = []

    for l in trialTypes:
        for r in xrange(1,replication[len(trialTypes[l])]+1):
            totalSampleSpace.append(l)

    totalSampleSpaceBk = copy.copy(totalSampleSpace)

    seed = initSeed
    success=False
    while success == False:
        trialList = []
        totalSampleSpace = copy.copy(totalSampleSpaceBk)
        # initital Trial
        np.random.seed(seed)
        np.random.shuffle(totalSampleSpace)
        trialType = totalSampleSpace.pop(0)
        for t in trialTypes[trialType]:
            trialList.append(t)

        error = False

        while len(totalSampleSpace) != 0 and not error:
            print("attempting to distribute totalSampleSpace len = %s" % len(totalSampleSpace) )

            if trialType in [1,3,9,13,6,8,12]: # last 3 switches
                restrictedSampleSpaceTypes = [16,18,20,22,24,26,28]

            elif trialType in [2,4,10,14,5,7,11]: # last 3 switches
                restrictedSampleSpaceTypes = [15,17,19,21,23,25,27]

            elif trialType in [15,17,23,27,20,22,26]: # last 3 switches
                restrictedSampleSpaceTypes = [2,4,6,8,10,12,14]

            elif trialType in [16,18,24,28,19,21,25]: # last 3 switches
                restrictedSampleSpaceTypes = [1,3,5,7,9,11,13]

            # current sample is the total sampleSpace if its in the types of the restricted sample
            currentSampleSpace = [s for s in totalSampleSpace if s in restrictedSampleSpaceTypes]
            np.random.shuffle(currentSampleSpace)

            try:
                trialType = currentSampleSpace.pop(0)
                totalSampleSpace.pop(totalSampleSpace.index(trialType)) # pop that from the total sample space
            except Exception as e:
                print("exeception: %s" % e)
                error = True

            for t in trialTypes[trialType]:
                trialList.append(t)



        if len(totalSampleSpace) > 0 :
            print("an error occured")
            print("try new seed")
            seed  += 1

        else:
            print("totalSampleSpace was distributed")
            success = True

    return seed, trialList


def attachPicNumToTrialList(trialList,picNum,equalAcross = ["alcohol_landscape","alcohol_portrait","neutral_landscape","neutral_portrait"]):
    """the equalacross underscores "_" maps onto the parameters in trialList  """

    newTrialList = []
    lenTrialList = len(trialList)
    picPresent = int(lenTrialList / max(picNum))

    picInEqualAcross = picPresent / len(equalAcross)
    ll = {}
    if picInEqualAcross.is_integer():
        for ea in equalAcross:
            ll.update({ea:picNum * int(picInEqualAcross)})

        for u, trial in enumerate(trialList):

            ea = "".join(str(i) + "_" if no != len(trial) -1 else str(i)  for no, i in enumerate(trial))

            np.random.shuffle(ll[ea])
            pop = ll[ea].pop(0)
            newTrialList.append(trial + [pop])

        toReturn = newTrialList

    else:
        print("attachPicNumToTrialList did not work")
        toReturn = None



    return toReturn



def get_seeds_from_num_trials_calculator_iterate_parameters_sequence_control_make_all_parameters(numTrials,file="C:\\code\\projects\\hypnoalc\\AAT\\trialParams.xlsx",
                                                                                                 initSeed = 0,nSeedsToGet=100):

    seedList = []
    tls = []

    while len(seedList) < nSeedsToGet:

        seed, tl = num_trials_calculator_iterate_parameters_sequence_control_make_all_parameters(numTrials,file=file
                                                                                      ,initSeed = initSeed)
        idn = False
        for test_tl in tls:
            if test_tl == tl:
                idn=True

        if seed in seedList or idn:
            initSeed += 1

        else:
            tls.append(tl)
            seedList.append(seed)

    return seedList


def write_setting_to_file(file,setting="eyeDom",value="left"):

    fileName = open(file, "w")
    print('Writing to record_file {0}'.format(file))
    csvWriter = csv.writer(fileName, delimiter=',', lineterminator="\n")
    csvWriter.writerow({setting:value})
    fileName.flush()


def read_file_find_settting(file,setting="eyeDom"):
    x = 1



def num_trials_calculator_iterate_parameters_make_all_parameters(numTrials,*parametersToIterate,roundUpOrDown="Up"):
    """
    numTrialsCalculatorIterate
    gets an input in NumTrials
    then it

    xTrials

    :param numTrials: the "proposed" numtrials, you want to figure out if can be performed
    :param parametersToIterate: the parameters to iterate over, like stimType or Postion on the screen
    :param roundUpOrDown: "up" if you want more trials when its undivisable by the prosposed numtirals, or "down"
        if you want less trials.

        # todo implement roundUpOrDown="dont" which should take the parameter with the largest amount of levels
        # ie see AAT_settings with 24 different pictures, here it should just use the a random amount of pictures


    :return: returns the numTrials used as input is divisable, else it returns the advisable/recommended amount
    """
    # test
    # numTrials = 80
    # parametersToIterate = [stimType,tiltType,picNum]

    # --

    numTrialsOri = xTrials =  numTrials


    # ---
    args = parametersToIterate
    args_string = "%s parameters with " % len(args)
    for no, arg in enumerate(args):
        args_string = paste(args_string," and " if no == len(args) -1 else "", str(len(arg)), "," if no != len(args) -1 else "" ,sep="")

    args_string = args_string + " levels"

    for arg in args:
        xTrials =  xTrials/ len(arg)

    if int(xTrials) == 0:
        dash_print("numTrials: %s is not dividable by parameters with %s which results in xTrials of: %s" % (
        numTrialsOri, args_string, xTrials))

        args_mult = [len(arg) for arg in args]
        advisablenumTrials = multiply_list(args_mult)
        dash_print("the minimum advisable numTrials is %s " % advisablenumTrials)

        dash_print("numTrials: %s is dividable by parameters with %s which results in xTrials of: %s" % (
        advisablenumTrials, args_string, xTrials))

        numTrials = xTrials = advisablenumTrials

        for arg in args:
            xTrials =  xTrials/ len(arg)
        print("setting xTrials to %s" % xTrials)

        if roundUpOrDown == False:
            print("since roundUpOrDown == False then")
            print("advisablenumTrials %s and xtrials %s is used to make allParameters "
                  "but making cutoff using original numTrials and returning original" % (advisablenumTrials,xTrials))
        else:
            print("returning Numtrials as to the advisable numTrials %s" % advisablenumTrials)


    elif not xTrials.is_integer():
        dash_print("numTrials: %s is not dividable by parameters with %s which results in xTrials of: %s" % (
        numTrialsOri, args_string, xTrials))

        if roundUpOrDown=="Up" or roundUpOrDown == False:
            xTrials = math.ceil(xTrials)

        else:
            xTrials = math.floor(xTrials)

        args_mult = [len(arg) for arg in args] + [xTrials]
        numTrials = multiply_list(args_mult)

        dash_print(
            "with roundUpOrDown==%s, which the function was run with, it results in numTrials: %s which is disiable by "
            "parameters with %s which results in xTrials of: %s" % (roundUpOrDown, numTrials, args_string, xTrials))

        if roundUpOrDown == False:
            print("this will be cutoff using the original numtrials since roundUpOrDown == False")

    else:
        dash_print("numTrials: %s is  dividable by parameters with %s which results in xTrials of: %s" % (
        numTrialsOri, args_string, xTrials))
        print("returning Numtrials as original")

        xTrials = numTrials
        for arg in args:
            xTrials =  xTrials / len(arg)

    allParameters = np.array(list(itertools.product(*args,xrange(int(xTrials)))))
    if roundUpOrDown == False:
        allParameters = allParameters[0:numTrialsOri]
        numTrials = numTrialsOri

    print("len(allParameters) is %s" % str(len(allParameters)))

    return numTrials,allParameters


def shuffle_restrict_similarity_all_parameters_find_parameters(allParameters,
                                                               parameterMaxSimilarity = [3,3,False,False],
                                                               initSeed=0,seedsToFind=20,maxTime=10):
    """
    take Cousijn 2011 Addiction, on the AAT task. cannabis and neutral image categories were displayed in two tilted rotations
    but critically: "The resulting 160 trials were presented in semi-random order (at most three similar rotations and image categories in a row)"

    this function  "shuffle_restrict_similarity_all_parameters"
    takes output from "num_trials_calculator_iterate_parameters_make_all_parameters"
    allParameters

    like:  [category, tilt, imagenum, iterate parameter]
        alcohol,left,1,0 <- 0 here is the iterate parameter, and unimportant for the suffle, see parameterMaxSimilarity
        alcohol,left,2,0
        alcohol,left,3,0
        alcohol,left,4,0
        alcohol,left,5,0
        alcohol,left,6,0
        neutral,right,1,0
        neutral,right,2,0
        neutral,right,3,0
        neutral,right,4,0
        neutral,right,5,0
        neutral,right,6,0

    and make sure that alcohol, at makes appears 3 times in a row, and a tilt, left/right only appears 3 times in a row
    but setting the corresponding parameterMaxSimilarity = [category max similary, tilt max similarity] to 3,
    i.e parameterMaxSimilarity = [3,3 <-
    if the parameterMaxSimilarity for a given parameter is set to 1, then that cant repeat
    then if parameterMaxSimilarity is set to false for that parameter, it is ignored.

    """
    # something to collect the seed?
    # def need some prints about which seeds worked, and all the inner works
    # some prints in general, and some documentation
    #
    # or try more than one seed (maybe)
    allParametersBK = copy.copy(allParameters)
    seed = initSeed
    myClock = psychopy.core.Clock()
    startTime = myClock.getTime()
    seeds = []

    while (len(seeds) < seedsToFind) and (myClock.getTime()  < (startTime + (60 * maxTime))):
        conditionSatisfied=False

        while conditionSatisfied == False:
            np.random.seed(seed)
            allParameters = copy.copy(allParametersBK)
            np.random.shuffle(allParameters)
            seed += 1

            conSatBools = []

            for no, paramMaxSim in enumerate(parameterMaxSimilarity):

                if paramMaxSim != False: # skip it, its not important, like ther iterapram (see example)
                    ll = allParameters[:,no]
                    max_count = {}
                    for val, grp in itertools.groupby(ll):
                        count = sum(1 for _ in grp)
                        if count > max_count.get(val, 0):
                            max_count[val] = count

                    for i in max_count.keys():
                        print("testing %s it has max_count of repeats of %s" % (i,max_count[i]))
                        if max_count[i] > paramMaxSim:
                            conSatBools.append(False) # if it's larger than max_count
                        else:
                            conSatBools.append(True) # if it's smaller than max_count

            conditionSatisfied = False not in conSatBools

        print("found seed: %s which satisfies conditions" % seed)
        seeds.append(seed)

    if len(seeds) > seedsToFind:
        print("found all sends %s" % len(seeds))
    else:
        print("time ran out: time: %s" % maxTime)

    return seed, allParameters



def wait_for_keyboard_psychopy_response(keyList=[' ','space', 'enter','RETURN','return'],quitKeys=['escape', 'esc'],
                      quitAutomatically=True):

    print("wait_for_psychopy_response")
    response = psychopy.event.waitKeys(keyList=keyList + quitKeys)
    if quitAutomatically:
        if response in quitKeys: psychopy.core.quit()
        else:
            pass



    return keyList.index(response[0])


def wait_for_psychopy_kb_mouse_response(win,keyList=[' ','space', 'enter','RETURN','return'],
                                        mousePoints=[0.0],mouseInit=False,
                                        mouseMinDistance=3,
                                        quitKeys=['escape', 'esc'],
                      quitAutomatically=True):

    response = False

    m = psychopy.event.Mouse(win=win)
    try:m.setPos(mouseInit)
    except:print("could not change mouse position")

    psychopy.event.clearEvents()
    resp = buttons = []
    while response == False:
        resp = psychopy.event.getKeys(keyList=keyList + quitKeys)
        buttons, times = m.getPressed(getTime=True)
        button_pos = m.getPos()
        #print(buttons)
        try:
            if buttons[0] == 1:
                ix = mousePoints.index(find_closest_point_to_points(button_pos,mousePoints))
                if math.dist(mousePoints[ix],button_pos) < mouseMinDistance:
                    response = True
                    buttons = {"mouse":ix}

            if len(resp) > 0:
                if resp[0] in keyList + quitKeys:
                    response = True
                    respori =  resp[0]

                    if respori in keyList:
                        respori = respori

                    resp = {"keyboard":respori}

        except:
            pass

    r = []
    r.append(resp)
    r.append(buttons)
    response = [ri for ri in r if len(ri) > 0]

    if quitAutomatically:
        try:
            if respori in quitKeys: psychopy.core.quit()
        except:pass
    return response[0]