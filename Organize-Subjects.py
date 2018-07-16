import csv 
import sys
import shutil

folder='/m/cs/scratch/networks/data/ABIDE_II/Forward/'
smoothing='Brainnetome_18mm/'
matrix='Adj_NoThr.mat'
#matrix='Adjacency_10.mat'
Thr='Thr0/'
output_folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/'

with open('/m/cs/scratch/networks/trianaa1/phenotypic-files/final_subjects/Age-matched_Subjects.csv', 'rb') as csvfile:
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
        move_to=output_folder+group_name+'Forward/'+smoothing+database+'-'+user+'-'+matrix
        shutil.move(move_from,move_to)
        #print move_from
        #print move_to
#print users 
