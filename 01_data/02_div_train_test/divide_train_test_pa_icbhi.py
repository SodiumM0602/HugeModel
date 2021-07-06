import sys
import os
import re
import numpy as np
import shutil
import csv

data_info = "./../../01_data_trip_loss/data_info/icbhe_challenge_spit.txt"
data_dir  =  "./../11_gam_10s_4000/"
save_dir  =  "./../12_split_gam_pa_icb/"

#data_dir  =  "./../11_2spec/"
#save_dir  =  "./../12_split_2spec_pa/"

save_train_dir = save_dir + 'data_train'
save_test_dir  = save_dir + 'data_test'

if not os.path.exists(save_dir):
    os.makedirs(save_dir)

if not os.path.exists(save_train_dir):
    os.makedirs(save_train_dir)

if not os.path.exists(save_test_dir):
    os.makedirs(save_test_dir)

#done

dict_list = {}
with open(data_info, 'r') as pat_list:
    pat_info = csv.reader(pat_list)
    for line in pat_info:
        dict_list[line[0]] = line[1]

org_folder_name_list = os.listdir(data_dir)
folder_name_list = []  #remove .folder
for i in range(0,len(org_folder_name_list)):
   isHidden=re.match("\.",org_folder_name_list[i])
   if (isHidden is None):
      folder_name_list.append(org_folder_name_list[i])
folder_name_list = sorted(folder_name_list)
folder_name_num  = len(folder_name_list)

#done

# For every file in class
for nFolder in range(0, folder_name_num):
    folder_name  = folder_name_list[nFolder]
    folder_dir   = data_dir + folder_name

    save_folder_train_dir = save_train_dir + '/' + folder_name
    if not os.path.exists(save_folder_train_dir):
        os.makedirs(save_folder_train_dir)


    org_file_name_list = os.listdir(folder_dir)
    file_name_list = []  #remove .file
    for i in range(0,len(org_file_name_list)):
       isHidden=re.match("\.",org_file_name_list[i])
       if (isHidden is None):
          file_name_list.append(org_file_name_list[i])
    file_name_list = sorted(file_name_list)
    file_name_num  = len(file_name_list)
    


    for nFile in range(file_name_num):
        file_name = os.path.splitext(file_name_list[nFile])[0]
        #them
        print(file_name)
        print(type(file_name))
        a_a=file_name[-1:-3:-1]
        
        try:
            a_a=int(a_a)
            a=file_name[-1:-6:-1]
        except:
            a=file_name[-1:-5:-1]
        a=a[::-1]
        print(a)
        #print(file_name-a)
        b=file_name.rsplit(a)[0]
        print(b)
        print(type(b))
        file_name=b
        #het them
        if dict_list[file_name] == 'test' :
            file_save_dir = save_test_dir +  '/' + folder_name + '_' + file_name_list[nFile]
        elif dict_list[file_name] == 'train' :     
            file_save_dir = save_folder_train_dir + '/' + folder_name + '_' + file_name_list[nFile]
        else:
            print('ERROR: NO TEST/TRAIN IN LIST')
            exit()

        file_cp = folder_dir + '/' + file_name_list[nFile]
        
        shutil.copy(file_cp, file_save_dir)
        #print(file_cp)
        #print(file_save_dir)
