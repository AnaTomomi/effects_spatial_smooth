#Script for making list of subjects quickly and painlessly.
#run it as: python make_subject_list.py site smoothing-folder
#the first argument is the site you would like to list
#the second argument is the folder (related to the level of smoothing)


from os import listdir
from os.path import isdir, join
import sys

site=sys.argv[1]
smooth=sys.argv[2]
string='\''

#input_path= "/m/cs/scratch/networks/data/ABIDE_II/Original_data/"+site+'/'
input_path= "/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/"+site+'/'
output_path= "/m/cs/scratch/networks/data/ABIDE_II/Forward/"+smooth+'/'+site+'/'

tx = open('input_subjects.txt','w') #input_subjects
onlyfolder = [f for f in listdir(input_path) if isdir(join(input_path, f))]
#subjects = [tx.write('\n'+f) for f in onlyfolder] #use this one if you only want to list the subject number
subjects = [tx.write('\n'+string+input_path+f+string) for f in onlyfolder]
print subjects
tx.close()


tx = open('output_subjects.txt','w')
onlyfolder = [f for f in listdir(output_path) if isdir(join(output_path, f))]
subjects = [tx.write('\n'+string+output_path+f+string) for f in onlyfolder]
print subjects
tx.close()
