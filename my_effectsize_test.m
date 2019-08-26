clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/MES'));

load('/m/cs/scratch/networks/trianaa1/toolboxes/MES/exampleData.mat')
effect=mes1way(com_post,'g_psi','group',group,'cWeight',[-1 1 0]);