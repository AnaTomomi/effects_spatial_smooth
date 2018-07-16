# -*- coding: utf-8 -*-
"""
T-statistic for all links for all smoothings
"""

from __future__ import print_function
import os
from os import listdir
from os.path import isfile, join
import scipy.io
import numpy as np
from scipy.stats import ttest_ind
import csv
#import matplotlib.pyplot as plt
#from matplotlib import gridspec
#import seaborn as sns
from itertools import izip
from sklearn import linear_model
import pylab
#Polynomial = np.polynomial.Polynomial


def load_adj_matrix_from_mat(fname, var_name='A'): #for threshold 0 use 'A', otherwise, use 'Adj'
    """
    Load a correlation/adjacency matrix using .mat file format

    Parameters
    ----------
    fname : str
        path to the .mat file containing the  matrix
    var_name : str
        the variable name of the matrix
    """
    assert fname[-4:] == ".mat", "Trying to load incorrect file format"
    adjMatrix = load_mat(fname, squeeze_me=False)[var_name]
    adjMatrix = np.triu(adjMatrix, 1)
    return adjMatrix
    
def load_mat(fname, squeeze_me=False):
    """
    Loads an arbitrary .mat file.

    Parameters
    ----------
    fname : str
        path to the .mat file
    squeeze_me : bool
        whether or not to squeeze additional
        matrix dimensions used by matlab.

    Returns
    -------
    data_dict : dict
        a dictionary with the 'mat' variable names as keys,
        and the actual matlab matrices/structs etc. as values

    Limited support is also available for HDF-matlab files.
    """
    try:
        data_dict = scipy.io.loadmat(fname, squeeze_me=squeeze_me)
    except NotImplementedError as e:
        if e.message == "Please use HDF reader for matlab v7.3 files":
            import h5py
            data = h5py.File(fname, "r")
            data_dict = {}
            for key in data.keys():
                if squeeze_me:
                    try:
                        data_dict[key] = np.squeeze(data[key])
                    except:
                        data_dict[key] = data[key]
                else:
                    data_dict[key] = data[key]
        else:
            raise e
    return data_dict

def read_all_subjects(Smoothing, Threshold, folder_g1):
    """
    Organizes adjacency matrices in a folder as part of a group.  

    Parameters
    ----------
    Smoothing : list 
        of Smoothing levels, usually the same folder names used to store the smoothing levels
    Threshold : str
        Threshold level used for the matrix, usually the same str as the folder name
    folder_g1 : str
        folder path where the adjacency matrices are

    Returns
    -------
    smooth : dict
        a dictionary of dictionaries with the Smoothing level as keys, 
        and subject as sencond keys. The actual matlab matrices/structs etc. as values

    """
    #Verified process :)
    #Organize the adjacency matrices in dictionaries for group (ASD or TC), for all smoothing levels
    smooth1=dict()
    for idx,smooth in enumerate(Smoothing):
        folder=folder_g1+Smoothing[idx]+Threshold
        files = [f for f in listdir(folder) if isfile(join(folder, f))]
        group=dict()
        for file in files:
            fname=file
            adjMat=load_adj_matrix_from_mat(folder+fname) #this is a numpy object, so call adjMat[0,0]. 
            #Now the matrices use the python indexing
            group[fname[:-26]]=np.arctanh(adjMat) #Fisher transform #change to -17 when working with thresholded matrices!!!!
            #Change to -26 for Nonthresholded 
        smooth1[smooth]=group
    return smooth1

def get_all_links(Smoothing,smooth1):
    """
    Organizes adjacency matrices in lists by links (distributions of links for the group)

    Parameters
    ----------
    Smoothing : list 
        of Smoothing levels, usually the same folder names used to store the smoothing levels
    smooth : dict
        a dictionary of dictionaries with the Smoothing level as keys, 
        and subject as sencond keys. The actual matlab matrices/structs etc. as values

    Returns
    -------
    linkSmooth1 : dict
        a dictionary of dictionaries with the Smoothing level as keys, 
        and subject as sencond keys. The actual matlab matrices/structs etc. as values
    subKeys1 : list
        list of subjects in the order of how the links are stored in the list

    """
    #Verified process :)
    links=[]
    linkSmooth1=dict()
    linkSmooth1['Non_Smoothed-HarvardOxford/']={}
    linkSmooth1['Smoothed-6mm-HarvardOxford/']={}
    linkSmooth1['Smoothed-8mm-HarvardOxford/']={}
    linkSmooth1['Smoothed-12mm-HarvardOxford/']={}
    x=range(138)
    y=range(138)
    for idx,smooth in enumerate(Smoothing):
        subKeys1=smooth1[smooth].keys()
        for i in x:
            for j in y:
                for subject in subKeys1:
                    links.append(smooth1[smooth][subject][i][j])
                linkSmooth1[smooth]['link_%s_%s' %(i,j)]=links
                links=[]
    return linkSmooth1,subKeys1

def get_regressionMat(filepath,subKeys):
    """
    Read the regression matrices (.csv format) and order the subjects according 
    to the keys order used to order the links in python (get_all_links)

    Parameters
    ----------
    filepath : list 
        path of the csv file
    subKeys : list
        list of subjects in the order of how the links are stored in the list (get_all_links)

    Returns
    -------
    orgReg : array
        array of the matrix according to subKeys
    """
    #Verified process :)
    #Read the regression matrices
    regress=[]  
    site1=[]
    site2=[]
    site3=[]
    site4=[]
    fd=[]  
    with open(filepath, 'rb') as csv_file:
        reader = csv.reader(csv_file)
        for row in reader:
            regress.append(row[0])
            site1.append(float(row[1]))
            site2.append(float(row[2]))
            site3.append(float(row[3]))
            site4.append(float(row[4]))
            fd.append(float(row[5]))
    regress2=[site1,site2,site3,site4,fd]
    regress2=np.transpose(np.asarray(regress2)) 
    
    #Organize according to keys
    orgReg=[]
    for subject in subKeys:
        Idx=regress.index(subject)
        orgReg.append(regress2[Idx])
    orgReg=np.asarray(orgReg)
    
    return orgReg

def regress_link(Smoothing,linkSmooth1,linkSmooth2,regMat1,regMat2):
    """
    Read the regression matrices (.csv format) and order the subjects according 
    to the keys order used to order the links in python (get_all_links)

    Parameters
    ----------
    Smoothing : list 
        of Smoothing levels, usually the same folder names used to store the smoothing levels    
    linkSmooth1, linkSmooth2 : dict
        a dictionary of dictionaries with the Smoothing level as keys, 
        and links as sencond keys. The list of links as values

    Returns
    -------
    link_dist1,link_dist2 : dict
        a dictionary of dictionaries with the Smoothing level as keys, 
        and links as sencond keys. The regressed links lists as values 
    """
    regressed_links=dict()
    link_dist1=dict()
    link_dist2=dict() 
    regressed_links['Non_Smoothed-HarvardOxford/']={}
    regressed_links['Smoothed-6mm-HarvardOxford/']={}
    regressed_links['Smoothed-8mm-HarvardOxford/']={}
    regressed_links['Smoothed-12mm-HarvardOxford/']={}
    link_dist1['Non_Smoothed-HarvardOxford/']={}
    link_dist1['Smoothed-6mm-HarvardOxford/']={}
    link_dist1['Smoothed-8mm-HarvardOxford/']={}
    link_dist1['Smoothed-12mm-HarvardOxford/']={}
    link_dist2['Non_Smoothed-HarvardOxford/']={}
    link_dist2['Smoothed-6mm-HarvardOxford/']={}
    link_dist2['Smoothed-8mm-HarvardOxford/']={}
    link_dist2['Smoothed-12mm-HarvardOxford/']={}
    
    for idx,smooth in enumerate(Smoothing):
        gKeys=linkSmooth1[smooth].keys() 
        for key in gKeys:
            y=linkSmooth1[smooth][key]+linkSmooth2[smooth][key]
            x=np.concatenate((regMat1,regMat2),axis=0)
            clf = linear_model.LinearRegression(fit_intercept=True)
            clf.fit(x,y)
            betas=clf.coef_
            regressed_links[smooth][key]=y-np.dot(x,betas)-np.ones(len(y))*clf.intercept_
            
    for idx,smooth in enumerate(Smoothing):
        gKeys=regressed_links[smooth].keys()
        for key in gKeys:
            link_dist1[smooth][key]=regressed_links[smooth][key][0:33]
            link_dist2[smooth][key]=regressed_links[smooth][key][33:66]
        
    return link_dist1,link_dist2

def links_to_Mat(Smoothing,link_dist):
    """
    Organize a list of links in Matrix form

    Parameters
    ----------
    Smoothing : list 
        a list of Smoothing levels, usually the same folder names used to store the smoothing levels    
    link_dist1 : dict
        a dictionary of dictionaries with the Smoothing level as keys, 
        and links as sencond keys. The actual values of link weights as values 

    Returns
    -------
    regSmooth : dict
        a dictionary of arrays with the Smoothing level as keys, and the ordered,
        symmetric T-statistics per link as values. 
    """
    #Verified process :)
    regSmooth=dict()
    regSmooth['Non_Smoothed-HarvardOxford/']={}
    regSmooth['Smoothed-6mm-HarvardOxford/']={}
    regSmooth['Smoothed-8mm-HarvardOxford/']={}
    regSmooth['Smoothed-12mm-HarvardOxford/']={}
    for idx,smooth in enumerate(Smoothing):
        linkKeys=link_dist[smooth].keys()
        regSmooth[smooth]=np.zeros([138,138])
        for link in linkKeys:
            i=int(link.split("_")[1])
            j=int(link.split("_")[2])
            regSmooth[smooth][i][j]=link_dist[smooth][link]
        inds = np.triu_indices_from(regSmooth[smooth],k=1)
        regSmooth[smooth][(inds[1], inds[0])] = regSmooth[smooth][inds]
        np.fill_diagonal(regSmooth[smooth], 0)

    return regSmooth
    
if __name__ == "__main__":
    #state all folders needed
    folder_g1='/m/cs/scratch/networks/data/ABIDE_II/Analysis/group1/'#ASD
    folder_g2='/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/'#TC
    Smoothing=['Non_Smoothed-HarvardOxford/','Smoothed-6mm-HarvardOxford/','Smoothed-8mm-HarvardOxford/','Smoothed-12mm-HarvardOxford/']
    Threshold='Thr0/'#'Thr0/'#Thr10 Thr25 Thr50 Thr75
    length=138
    
    smooth1=read_all_subjects(Smoothing, Threshold, folder_g1) #Read all subjetcs for a group:ASD  
    linkSmooth1,subKeys1=get_all_links(Smoothing,smooth1)#Organize info by links
    filepath='/m/cs/scratch/networks/data/ABIDE_II/Analysis/group1/regress.csv' #Filepath for the regression matrix file 
    regMat1=get_regressionMat(filepath,subKeys1)#Order the regression matrix according to how python is reading the files
    
    smooth2=read_all_subjects(Smoothing, Threshold, folder_g2)    
    linkSmooth2,subKeys2=get_all_links(Smoothing,smooth2)  
    filepath='/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/regress.csv'
    regMat2=get_regressionMat(filepath,subKeys2)
    
    #Regress all the links for all the smoothing levels
    link_dist1,link_dist2=regress_link(Smoothing,linkSmooth1,linkSmooth2,regMat1,regMat2)
 
    #Read the ROI names
    ROInames=[]    
    with open('/m/cs/scratch/networks/trianaa1/Atlas/ROI_names.csv', 'rb') as csv_file:
        reader = csv.reader(csv_file)
        for row in reader:
            ROInames.append(row[0])
    #Assign "human readable ROIs"
    nodes1=[]
    nodes2=[]
    element=np.arange(len(keys))
    for i in element:
        separated=keys[i].split('_')
        nodes1.append(int(separated[1]))
        nodes2.append(int(separated[2]))
    
    nodes1_names=[]
    nodes2_names=[]
    for i in element:
        nodes1_names.append(ROInames[nodes1[i]])
        nodes2_names.append(ROInames[nodes2[i]])
    
    #Write the results to csv file
    with open('/m/cs/scratch/networks/trianaa1/ROIs_regressed.csv', 'wb') as f:
        writer = csv.writer(f)
        maxi=len(nodes1)
        mini=maxi-95
        writer.writerows(izip(nodes1[mini:maxi],nodes1_names[mini:maxi],nodes2[mini:maxi],nodes2_names[mini:maxi],values[mini:maxi],p_values[mini:maxi]))
