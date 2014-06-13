%% TSCU test suite: 11
%
% * Author : Huseyin Kaya
% * Website: <http://timewarping.org>
% * Sources: <https://github.com/hkayabilisim/TSCU>

%% Initialization
% As always, I begin with clearing everything to stay out of any nonsense.
clear all
close all
clc

%% Prepating MEX files
% I should first compile MEX files.
%mex tscu_dtw.c
%mex tscu_saga_register.c tscu_saga_util.c
%% Dataset definitions
datasets = { ...
    6,'synthetic_control'           ,8,50,... % 1
    3,'Trace'                       ,2,20,...
    0,'SonyAIBORobotSurfaceII'      ,2,40,...
    0,'SonyAIBORobotSurface'        ,2,20,...
    8,'Symbols'                     ,2,20,... % 5
    5,'TwoLeadECG'                  ,4,30,...
    1,'OliveOil'                    ,2,20,...
    1,'MoteStrain'                  ,4,20,...
    5,'Lighting7'                   ,4,20,...
    6,'Lighting2'                   ,4,30,... % 10
    0,'ItalyPowerDemand'            ,8,50,...
    0,'Gun_Point'                   ,2,40,... % 12
    2,'FaceFour'                    ,4,40,...
    0,'ECGFiveDays'                 ,2,20,...
    0,'ECG200'                      ,2,20,... % 15
    0,'DiatomSizeReduction'         ,2,20,...
    3,'Coffee'                      ,16,30,...
    11,'CBF'                         ,4,50,...
    0,'Beef'                        ,2,20,...
    4,'FISH'                        ,16,30,... % 20
    7,'OSULeaf'                     ,8,50,...
    8,'WordsSynonyms'               ,16,40,...
    7,'Cricket_Z'                   ,4,40,...
    3,'Adiac'                       ,4,40,...
    20,'MedicalImages'               ,8,40,... % 25
    2,'SwedishLeaf'                 ,4,40,...
    7,'Cricket_X'                   ,8,40,...
    17,'Cricket_Y'                   ,4,30,...
    2,'Haptics'                     ,8,50,...
    12,'FacesUCR'                    ,16,20,... % 30
    6,'50words'                     ,8,50,...
    1,'CinC_ECG_torso'              ,8,50,...
    14,'InlineSkate'                 ,4,30,...
    3,'FaceAll'                     ,4,50,...
    0,'MALLAT'                      ,2,20,... % 35
    0,'ChlorineConcentration'       ,2,20,...
    2,'yoga'                        ,8,20,...
    4,'Two_Patterns'                ,2,20,...
    1,'wafer'                       ,8,20,...
    4,'uWaveGestureLibrary_X'       ,8,20}; % 40
%%
m = 40;
n = 4;
%r=cell(m,n);
load('rmatrix.mat','r'); % load NONE, DTW, CDTW
for i=1:m
    dataname = datasets{4*(i-1)+2};
    trnfile = sprintf('../../UCR/%s/%s_TRAIN',dataname,dataname);
    tstfile = sprintf('../../UCR/%s/%s_TEST',dataname,dataname);
    fprintf('Training file............................: %s\n',trnfile);
    fprintf('Testing  file............................: %s\n',tstfile);
    trn = load(trnfile);
    tst = load(tstfile);
    %r{i,1}=tscu(trn,tst,'Classifier','NN' ,'Alignment','NONE');
    %r{i,2}=tscu(trn,tst,'Classifier','NN' ,'Alignment','DTW');
    %r{i,3}=tscu(trn,tst,'Classifier','NN' ,'Alignment','CDTW','DTWbandwidth',datasets{4*(i-1)+1});
    r{i,4}=tscu(trn,tst,'Classifier','NN' ,'Alignment','SAGA','LogLevel','Info',...
        'SAGABaseLength',4,'SAGAOptimizationMethod','Register');
    
    c = [1 2;1 3;1 4;2 3;2 4;3 4];
    %c=[1 2;1 3;2 3];
    cname = {'NONE','DTW','CDTW','SAGA'};
    fprintf('%2s %4s %4s %6s %6s %5s %5s %8s %3s %8s %3s %5s %5s %5s %5s %4s\n',...
        'id','MET1','MET2','m1%','m2%','cpu1','cpu2','McNemar','Sgn','binom','Sgn','FFn00','TFn10','FTn01','TTn11','win');
    for j=1:size(c,1)
        s = tscu_significance(r{i,c(j,1)}.truelabels,r{i,c(j,1)}.labels,r{i,c(j,2)}.labels);
        if s.w
            winner = cname{c(j,s.w)};
        else
            winner = '----';
        end
        fprintf('%2d %4s %4s %5.4f %5.4f %5.0f %5.0f %8.5f %3d %8.5f %3d %5d %5d %5d %5d %4s\n',...
            i,cname{c(j,1)},cname{c(j,2)},...
            r{i,c(j,1)}.perf.OA, r{i,c(j,2)}.perf.OA,...
            r{i,c(j,1)}.classification_time, r{i,c(j,2)}.classification_time,...
            s.m,s.ms,s.b,s.bs,s.n00,s.n10,s.n01,s.n11,winner);
    end
end