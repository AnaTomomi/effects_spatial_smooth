'''
This script is a helper file. It organizes the connectivity matrices from subjects in two folders according to their group and renames them according to their group and site. 
1: ASD
2: TC
This is not required for the analysis, but rather speeds up the process of organizing files. 

Parameters:
-----------
folder: path where the preprocessed images/folders are
smoothing: folder according to the smoothing level. E.g. Brainnetome_32mm is the folder for data preprocessed with the Brainnetome Atlas and smoothed with FWHM=32mm
Thr: threshold of the matrices
output_folder: folder to where the preprocess connectivity matrix will be moved.

'''
import csv 
import sys
import shutil

folder='/m/cs/scratch/networks/data/ABIDE_II/Forward/'
smoothing='Brainnetome_28mm/'
matrix='Adj_NoThr_Craddock30.mat'
#matrix='Adjacency_10.mat'
Thr='Thr0/'
output_folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/'

with open('/m/cs/scratch/networks/trianaa1/Paper1/smoothing-group/phenotypic-files/final_subjects/ABIDE_extended_Age-matched-Subjects.csv', 'rb') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')
    databases=[]
    users=[]
    groups=[]
    for row in spamreader:
        #print(row[0])
        database=row[0]
        user=row[1]
        group=row[2]
        databases.append(database)
        users.append(user)
        groups.append(group)
        move_from=folder+smoothing+database+'/'+user+'/'+matrix
        if group=='1':
            group_name='group1/'
        else:
            group_name='group2/'
        move_to=output_folder+group_name+smoothing+database+'-'+user+'-'+matrix
        shutil.move(move_from,move_to)
        print move_from
        print move_to
print smoothing
#print users 
