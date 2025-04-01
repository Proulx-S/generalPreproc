clear all
close all

%%%%%%%%%%%%%%%%%%%%%
%% Set up environment
%%%%%%%%%%%%%%%%%%%%%

% Detect computing environment
os   = char(java.lang.System.getProperty('os.name'));
host = char(java.net.InetAddress.getLocalHost.getHostName);
user = char(java.lang.System.getProperty('user.name'));

% Configure paths accordingly
if strcmp(os,'Linux') && strcmp(host,'takoyaki') && strcmp(user,'sebp')
    storageDir = '/local/users/Proulx-S/';
    scratchDir = '/scratch/users/Proulx-S/';
    toolDir    = fullfile(getenv('HOME'),'tools');
    workScript = mfilename;
    workFile   = [workScript '.mat'];
    workDir    = fullfile(getenv('HOME'),'/work/generalPreproc/',workScript); if ~exist(workDir,'dir'); mkdir(workDir); end
    workFile   = fullfile(fileparts(workDir),workFile);
    envId      = 1;
    setenv('SINGULARITY_BINDPATH',strjoin({storageDir scratchDir toolDir workDir},','));
else
    dbstack; error('not implemented')
end


% Load dependencies
%%% matlab
addpath(genpath(         workDir                                 ))
tool = 'bassReg2';    toolURL = 'https://github.com/Proulx-S/bassReg2.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
tool = 'vasomoTools'; toolURL = 'https://github.com/Proulx-S/vasomoTools.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
tool = 'util';    toolURL = 'https://github.com/Proulx-S/util.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
tool = 'chronux';     toolURL = 'https://github.com/Proulx-S/chronux';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,'chronux/chronux_2_12/modified')))
tool = 'fieldtrip';   toolURL = 'https://github.com/fieldtrip/fieldtrip';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,'fieldtrip/external/freesurfer')))
%%% neurodesk
switch envId
    case 1
        global src
        %%%% afni
        src.afni = 'ml afni/24.3.00';
        system([src.afni '; 3dinfo > /dev/null'],'-echo');
        %%%% freesurfer
        src.fs   = 'ml freesurfer/8.0.0';
        system([src.fs   '; mri_convert > /dev/null'],'-echo');
        %%%% fsl for fslview once we figure out how to make it work
    otherwise
        dbstack; error('not implemented')
        % neurodeskModule = {
        % ":/neurodesktop-storage/containers/freesurfer_8.0.0_20250210"
        % ":/neurodesktop-storage/containers/afni_24.3.00_20241003"};
        % for i = 1:length(neurodeskModule)
        %     if contains(getenv("PATH"),neurodeskModule{i}); continue; end
        %     setenv("PATH",getenv("PATH") + neurodeskModule{i});
        % end
end






% clear all
% close all
% [outDir,pipId] = fileparts(mfilename('fullpath'));
% outDir = fullfile(outDir,pipId); if ~exist(outDir,'dir'); mkdir(outDir); end


% %%%%%%%%%%%%%%%%%%
% %% Dependencies %%
% %%%%%%%%%%%%%%%%%%
% % matlab
% addpath(genpath(fullfile(pwd,pipId)))
% addpath(genpath('/usr/local/freesurfer/stable7.4.1/matlab/'))
% addpath(genpath('/space/takoyaki/1/users/proulxs/tools/chronux'))
% addpath(genpath('/space/takoyaki/1/users/proulxs/tools/vasomoTools'))
% addpath(genpath('/space/takoyaki/1/users/proulxs/tools/bassReg2'))
% addpath(genpath('/space/takoyaki/1/users/proulxs/tools/martinosTools'))
% addpath(genpath('/space/takoyaki/1/users/proulxs/tools/util'))

% % bash
% global srcAfni srcFs
% srcFs = 'source /usr/local/freesurfer/fs-stable741-env-autoselect';
% srcAfni = 'export PATH=$PATH:/usr/pubsw/packages/AFNI/23.1.05';
% %%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variables, Paths and stim/acq info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info.dataSetLabel = 'vsmDiamCenSur';

switch info.dataSetLabel
    case 'vsmDiamCenSur'
        % % info.datasetDir = fullfile(storageDir,info.dataSetLabel);
        % info.pipId      = workScript;
        % info.bidsDir    = fullfile(storageDir,'bids');   if ~exist(info.bidsDir,'dir'); mkdir(info.bidsDir); end
        % info.srcDir     = fullfile(storageDir,'source'); if ~exist(info.srcDir ,'dir'); mkdir(info.srcDir ); end
        % info.prcDir     = fullfile(info.datasetDir,'proc');   if ~exist(info.prcDir ,'dir'); mkdir(info.prcDir ); end
        %%% Source data location
        info.dbDir = fullfile(storageDir,'db');

        %%% Preprocessing location
        info.prcDir = fullfile(scratchDir,workScript,info.dataSetLabel); if ~exist(info.prcDir,'dir'); mkdir(info.prcDir); end

        %%% Subject and session info
        sesDbListTmp = {};
        % sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'');
        % sesDbListTmp{end  ,1}{end+1,1} = fullfile(info.dbDir,'');
        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDrivenP1/2024-07-28--bay2--vsmDrivenP1' );
        sesDbListTmp{end  ,1}{end+1,1} = fullfile(info.dbDir,'vsmDrivenP1/2024-08-09--bay2--vsmDrivenP1' );
        sesDbListTmp{end  ,1}{end+1,1} = fullfile(info.dbDir,'vsmDrivenP1/2024-09-05--bay2--vsmDrivenP01');
        sesDbListTmp{end  ,1}{end+1,1} = fullfile(info.dbDir,'vsmRingP1/2024-10-08--bay2--vsmRingP1'     );

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDrivenP2/2024-07-28--bay2--vsmDrivenP2');
        sesDbListTmp{end  ,1}{end+1,1} = fullfile(info.dbDir,'vsmDrivenP2/2024-08-05--bay2--vsmDrivenP2');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDrivenP3/2024-10-08--bay2--vsmDrivenP3');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDrivenP4/2024-10-15--bay2--vsmDrivenP4');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDrivenP5/2024-10-17--bay2--vsmDrivenP5');
        sesDbListTmp{end  ,1}{end+1,1} = fullfile(info.dbDir,'vsmDrivenP5/2024-12-10--bay2--vsmDrivenP5_ses2');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDiamCenSurP1/2024-12-04--bay2--vsmDiamCenSurP1');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDiamCenSurP2/2024-12-13--bay2--vsmDiamCenSurP2');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDiamCenSurP3/2025-01-17--bay2--vsmDiamCenSurP3');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDiamCenSurP4/2025-01-20--bay2--vsmDiamCenSurP4');

        sesDbListTmp{end+1,1}{    1,1} = fullfile(info.dbDir,'vsmDiamCenSurP5/2025-01-23--bay2--vsmDiamCenSurP5');
        

        % sub-5 ses-1: synchronization to physio is done with vfMRI and
        % bold runs, which have different trigger shape (volTr vs rfTr).
        % The alignment is not so bad anyway, but one should fix the issue
        % for robustness (see extractLabChartData3.m, line 750, "% scale physio Fs to MRI tr")

        for sub = 1:length(sesDbListTmp)
            for ses = 1:length(sesDbListTmp{sub})
                if isempty(sesDbListTmp{sub}{ses}); continue; end

                if ~exist('subList','var');         subList = {}; end
                subList{end+1,1}                            = [info.dataSetLabel 'P' num2str(sub)];
                if ~exist('sesList','var');         sesList = {}; end
                sesList{end+1,1}                            = num2str(ses);
                if ~exist('sesDbList','var');     sesDbList = {}; end
                sesDbList{end+1,1}                          = sesDbListTmp{sub}{ses};
                if ~exist('prcDirList','var');   prcDirList = {}; end
                prcDirList{end+1,1}                         = fullfile(info.prcDir ,['sub-' subList{end}],['ses-' sesList{end}]);
                if ~exist('dirs','var');               dirs = {}; end
                if ~exist('dirsOrig','var');       dirsOrig = {}; end
                
                if ~exist('rCond','var');     rCond = {}; end
                rCond{end+1,1}   = {};
                % if ~exist('dummyList','var'); dummyList = {}; end
                % dummyList{end+1,1} = {};

                disp('Copying data from db')
                forceThis = 0;
                [dirs{end+1,1},dirsOrig{end+1,1}] = db2bids(sesDbListTmp{sub}{ses},subList{end},sesList{end},info,forceThis);
                [~,acqDate,~] = fileparts(sesDbList{end}); acqDate = strsplit(acqDate,'--'); acqDate = datetime(acqDate{1},'InputFormat','yyyy-MM-dd');
                

                
                %%% anat
                disp('--anat--')
                dir(fullfile(dirs{end,1}.bids,'anat','*.nii.gz'))
                %%%% avMap
                if ~exist('avMap','var'); avMap = {}; end
                avMap{end+1,1}.fList = dir(fullfile(dirs{end,1}.bids,'anat','*acq-avMap*.nii.gz'));
                %%%% memprage
                if ~exist('memprage','var'); memprage = {}; end
                memprage{end+1,1}.fList = dir(fullfile(dirs{end,1}.bids,'anat','*_T1w.nii.gz'));
                % if ~isempty(memprage{end,1}.fList)
                %     tmp = dir(fullfile(info.dbDir,subList{end},'*','fs',subList{end}));
                %     memprage{end,1}.fsDir = tmp(1).folder; clear tmp
                % else
                %     switch subList{end}
                %         case 'vsmRingP1'
                %             memprage{end,1}.fsDir = '/autofs/space/takoyaki_001/users/proulxs/vasomo/source/expDb/vsmDrivenP1/2024-07-28--bay2--vsmDrivenP1/fs/vsmDrivenP1';
                %         otherwise
                %             warning(['could not find memprage of fsDir for sub-' subList{end} '_ses-' sesList{end} newline 'please specify fsDir'])
                %     end
                % end
                %%%% pcMRA
                if ~exist('pcMRA','var'); pcMRA = {}; end
                pcMRA{end+1,1}.fList = dir(fullfile(dirs{end,1}.bids,'anat','*acq-pcVenc*.nii.gz'));
                %%%% tof
                if ~exist('tof','var'); tof = {}; end
                tof{end+1,1}.fList = dir(fullfile(dirs{end,1}.bids,'anat','*acq-tof*.nii.gz'));


                %%% fmap
                disp('--fmap--')
                dir(fullfile(dirs{end,1}.bids,'fmap','*.nii.gz'))
                %%%% topup
                if ~exist('b0','var'); b0 = {}; end
                b0{end+1,1}.label = 'topup';
                b0{end,1}.fList = dir(fullfile(dirs{end,1}.bids,'fmap','*_epi.nii.gz'));
                %%%% sa2rage
                if ~exist('b1','var'); b1 = {}; end
                b1{end+1,1}.label = 'B1';
                b1{end,1}.fList = dir(fullfile(dirs{end,1}.bids,'fmap','*_TB1SRGE.nii.gz'));


                
                %%% func
                disp('--func--')
                dir(fullfile(dirs{end,1}.bids,'func','*.nii.gz'))
                

                %%%% vfMRI
                dummy = 5;

                %%%%% 50sPrd5sDur -- inflow
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub      = subList{end};
                rCond{end,1}{1,end}.ses      = sesList{end};
                rCond{end,1}{1,end}.acq      = 'vfMRI';
                rCond{end,1}{1,end}.prsc     = 'dflt';
                rCond{end,1}{1,end}.task     = '50sPrd5sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*12;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*6;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                fListTask = dir(fullfile(dirs{end,1}.bids,'func',['*_task-' rCond{end,1}{1,end}.task     '_*.nii.gz']));
                    fListAcq  = dir(fullfile(dirs{end,1}.bids,'func',['*_acq-'  rCond{end,1}{1,end}.acq '*_angio.nii.gz']));
                    fList     = intersect(fullfile({fListAcq.folder },{fListAcq.name })',fullfile({fListTask.folder},{fListTask.name})');
                rCond{end,1}{1,end}.fList = {};
                if ~isempty(fList); rCond{end,1}{1,end}.fList = fList; end
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList));
                rCond{end,1}{1,end}.nDummy = repmat(dummy,size(rCond{end,1}{1,end}.fList));
                
                %%%%% 50sPrd5sDur -- pc
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub      = subList{end};
                rCond{end,1}{1,end}.ses      = sesList{end};
                rCond{end,1}{1,end}.acq      = 'vfMRIpc';
                rCond{end,1}{1,end}.prsc     = 'dflt';
                rCond{end,1}{1,end}.task = '50sPrd5sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*6;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*12;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                fListAcq        = {};
                fListAcq{end+1} = dir(fullfile(dirs{end,1}.bids,'func',['*_acq-pcVenc7z*_angio.nii.gz'])); fListAcq{end} = fullfile({fListAcq{end}.folder },{fListAcq{end}.name })';
                fListAcq{end+1} = dir(fullfile(dirs{end,1}.bids,'func',['*_acq-pcVenc7ap*_angio.nii.gz'])); fListAcq{end} = fullfile({fListAcq{end}.folder },{fListAcq{end}.name })';
                fListAcq        = unique(cat(1,fListAcq{:}));
                fListRec  = dir(fullfile(dirs{end,1}.bids,'func',['*_rec-venc0_*_angio.nii.gz']));
                fListTask = dir(fullfile(dirs{end,1}.bids,'func',['*_task-' rCond{end,1}{1,end}.task     '_*.nii.gz']));
                fList     = intersect(fListAcq,fullfile({fListRec.folder },{fListRec.name })');
                fList     = intersect(fList,fullfile({fListTask.folder},{fListTask.name})');
                rCond{end,1}{1,end}.fList = {};
                if ~isempty(fList)
                    fListDiffMag   = replace(fList       ,'rec-venc0_','rec-venc*_');
                    fListDiffPhase = replace(fListDiffMag,'part-mag'  ,'part-phase');
                    for v = 1:size(fList,1)
                        fListDiffMag{v,1} = dir(fListDiffMag{v,1});
                        fListDiffMag{v,1} = fullfile({fListDiffMag{v,1}.folder},{fListDiffMag{v,1}.name})';
                        fListDiffMag(v,:) = fListDiffMag{v,1}(~ismember(fListDiffMag{v,1},fList))';

                        fListDiffPhase{v,1} = dir(fListDiffPhase{v,1});
                        fListDiffPhase{v,1} = fullfile({fListDiffPhase{v,1}.folder},{fListDiffPhase{v,1}.name})';
                        fListDiffPhase(v,:) = fListDiffPhase{v,1}(~ismember(fListDiffPhase{v,1},fList))';
                    end
                    rCond{end,1}{1,end}.fList = cat(2,fList,fListDiffMag,fListDiffPhase);
                end
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList,1),1);
                rCond{end,1}{1,end}.nDummy = repmat(dummy  ,size(rCond{end,1}{1,end}.fList,1),1);

                %%%%% 50sPrd5sDur -- pc (highVenc)
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub  = subList{end};
                rCond{end,1}{1,end}.ses  = sesList{end};
                rCond{end,1}{1,end}.acq  = 'vfMRIpc';
                rCond{end,1}{1,end}.prsc = 'dflt';
                rCond{end,1}{1,end}.task = '50sPrd5sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*6;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*12;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                fListAcq        = {};
                fListAcq{end+1} = dir(fullfile(dirs{end,1}.bids,'func',['*_acq-pcVenc14z*_angio.nii.gz'])); fListAcq{end} = fullfile({fListAcq{end}.folder },{fListAcq{end}.name })';
                fListAcq{end+1} = dir(fullfile(dirs{end,1}.bids,'func',['*_acq-pcVenc14ap*_angio.nii.gz'])); fListAcq{end} = fullfile({fListAcq{end}.folder },{fListAcq{end}.name })';
                fListAcq        = unique(cat(1,fListAcq{:}));
                fListRec  = dir(fullfile(dirs{end,1}.bids,'func',['*_rec-venc0_*_angio.nii.gz']));
                fListTask = dir(fullfile(dirs{end,1}.bids,'func',['*_task-' rCond{end,1}{1,end}.task     '_*.nii.gz']));
                fList     = intersect(fListAcq,fullfile({fListRec.folder },{fListRec.name })');
                fList     = intersect(fList,fullfile({fListTask.folder},{fListTask.name})');
                rCond{end,1}{1,end}.fList = {};
                if ~isempty(fList)
                    fListDiffMag   = replace(fList       ,'rec-venc0_','rec-venc*_');
                    fListDiffPhase = replace(fListDiffMag,'part-mag'  ,'part-phase');
                    for v = 1:size(fList,1)
                        fListDiffMag{v,1} = dir(fListDiffMag{v,1});
                        fListDiffMag{v,1} = fullfile({fListDiffMag{v,1}.folder},{fListDiffMag{v,1}.name})';
                        fListDiffMag(v,:) = fListDiffMag{v,1}(~ismember(fListDiffMag{v,1},fList))';

                        fListDiffPhase{v,1} = dir(fListDiffPhase{v,1});
                        fListDiffPhase{v,1} = fullfile({fListDiffPhase{v,1}.folder},{fListDiffPhase{v,1}.name})';
                        fListDiffPhase(v,:) = fListDiffPhase{v,1}(~ismember(fListDiffPhase{v,1},fList))';
                    end
                    rCond{end,1}{1,end}.fList = cat(2,fList,fListDiffMag,fListDiffPhase);
                end
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList,1),1);
                rCond{end,1}{1,end}.nDummy = repmat(dummy  ,size(rCond{end,1}{1,end}.fList,1),1);

                %%%%% 50sPrd10sDur -- inflow
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub  = subList{end};
                rCond{end,1}{1,end}.ses  = sesList{end};
                rCond{end,1}{1,end}.acq  = 'vfMRI';
                rCond{end,1}{1,end}.prsc = 'dflt';
                rCond{end,1}{1,end}.task = '50sPrd10sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*12;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*12;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                fListAcq  = dir(fullfile(dirs{end,1}.bids,'func',['*_acq-'  rCond{end,1}{1,end}.acq '*_angio.nii.gz']));
                fListTask = dir(fullfile(dirs{end,1}.bids,'func',['*_task-' rCond{end,1}{1,end}.task     '_*.nii.gz']));
                fList     = intersect(fullfile({fListAcq.folder },{fListAcq.name })',fullfile({fListTask.folder},{fListTask.name})');
                rCond{end,1}{1,end}.fList = {};
                if ~isempty(fList); rCond{end,1}{1,end}.fList = fList; end
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList));
                rCond{end,1}{1,end}.nDummy = repmat(dummy,size(rCond{end,1}{1,end}.fList));

                %%%%% 50sPrd10sDur -- pc
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub  = subList{end};
                rCond{end,1}{1,end}.ses  = sesList{end};
                rCond{end,1}{1,end}.acq  = 'vfMRIpc';
                rCond{end,1}{1,end}.prsc = 'dflt';
                rCond{end,1}{1,end}.task = '50sPrd10sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*12;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*12;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                fListAcq  = dir(fullfile(dirs{end,1}.bids,'func',['*_acq-pcVenc7z*_angio.nii.gz']));
                fListRec  = dir(fullfile(dirs{end,1}.bids,'func',['*_rec-venc0_*_angio.nii.gz']));
                fListTask = dir(fullfile(dirs{end,1}.bids,'func',['*_task-' rCond{end,1}{1,end}.task     '_*.nii.gz']));
                fList     = intersect(fullfile({fListAcq.folder },{fListAcq.name })',fullfile({fListRec.folder },{fListRec.name })');
                fList     = intersect(fList,fullfile({fListTask.folder},{fListTask.name})');
                rCond{end,1}{1,end}.fList = {};
                if ~isempty(fList)
                    fListDiffMag   = replace(fList       ,'rec-venc0_','rec-venc*_');
                    fListDiffPhase = replace(fListDiffMag,'part-mag'  ,'part-phase');
                    for v = 1:size(fList,1)
                        fListDiffMag{v,1} = dir(fListDiffMag{v,1});
                        fListDiffMag{v,1} = fullfile({fListDiffMag{v,1}.folder},{fListDiffMag{v,1}.name})';
                        fListDiffMag(v,:) = fListDiffMag{v,1}(~ismember(fListDiffMag{v,1},fList))';

                        fListDiffPhase{v,1} = dir(fListDiffPhase{v,1});
                        fListDiffPhase{v,1} = fullfile({fListDiffPhase{v,1}.folder},{fListDiffPhase{v,1}.name})';
                        fListDiffPhase(v,:) = fListDiffPhase{v,1}(~ismember(fListDiffPhase{v,1},fList))';
                    end
                    rCond{end,1}{1,end}.fList = cat(2,fList,fListDiffMag,fListDiffPhase);
                end
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList,1),1);
                rCond{end,1}{1,end}.nDummy = repmat(dummy  ,size(rCond{end,1}{1,end}.fList,1),1);
                

                %%%% bold
                dummy = 5;
                dir(fullfile(dirs{end,1}.bids,'func','*.nii.gz'))

                %%%%% 50sPrd5sDur
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub  = subList{end};
                rCond{end,1}{1,end}.ses  = sesList{end};
                rCond{end,1}{1,end}.acq  = 'bold';
                rCond{end,1}{1,end}.prsc = 'dflt';
                rCond{end,1}{1,end}.task = '50sPrd5sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*12;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*6;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                rCond{end,1}{1,end}.fList = dir(fullfile(dirs{end,1}.bids,'func',['*task-' rCond{end,1}{1,end}.task '*_bold.nii.gz']));
                rCond{end,1}{1,end}.fList = fullfile({rCond{end,1}{1,end}.fList.folder},{rCond{end,1}{1,end}.fList.name})';
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList));
                rCond{end,1}{1,end}.nDummy = repmat(dummy,size(rCond{end,1}{1,end}.fList));

                %%%%% 50sPrd10sDur
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub  = subList{end};
                rCond{end,1}{1,end}.ses  = sesList{end};
                rCond{end,1}{1,end}.acq  = 'bold';
                rCond{end,1}{1,end}.prsc = 'dflt';
                rCond{end,1}{1,end}.task = '50sPrd10sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*12;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*12;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                fListAcq  = dir(fullfile(dirs{end,1}.bids,'func','*_bold.nii.gz'));
                fListTask = dir(fullfile(dirs{end,1}.bids,'func',['*_task-' rCond{end,1}{1,end}.task     '_*.nii.gz']));
                fList     = intersect(fullfile({fListAcq.folder },{fListAcq.name })',fullfile({fListTask.folder},{fListTask.name})');
                rCond{end,1}{1,end}.fList = {};
                if ~isempty(fList); rCond{end,1}{1,end}.fList = fList; end
                % rCond{end,1}{1,end}.fList = dir(fullfile(dirs{end,1}.bids,'func',['*task-' rCond{end,1}{1,end}.task '*_angio.nii.gz']));
                % rCond{end,1}{1,end}.fList = fullfile({rCond{end,1}{1,end}.fList.folder},{rCond{end,1}{1,end}.fList.name})';
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList));
                rCond{end,1}{1,end}.nDummy = repmat(dummy,size(rCond{end,1}{1,end}.fList));

                %%%%% 50sPrd1sDur
                rCond{end,1}{1,end+1} = runCond;
                rCond{end,1}{1,end}.dirs     = dirs{end,1};
                rCond{end,1}{1,end}.dirsOrig = dirsOrig{end,1};
                rCond{end,1}{1,end}.sub  = subList{end};
                rCond{end,1}{1,end}.ses  = sesList{end};
                rCond{end,1}{1,end}.acq  = 'bold';
                rCond{end,1}{1,end}.prsc = 'dflt';
                rCond{end,1}{1,end}.task = '50sPrd1sDur';
                dsgn = runDsgn;
                dsgn.task = rCond{end,1}{1,end}.task;
                dsgn.dt   = 0.840;
                initRest   = dsgn.dt*12;
                stimPeriod = dsgn.dt*57;
                stimDur    = dsgn.dt*1;
                runDur     = dsgn.dt*354;
                dsgn.onsetList = initRest:stimPeriod:(runDur-stimPeriod);
                dsgn.ondurList = ones(size(dsgn.onsetList)).*(stimDur);
                dsgn.cond      = ones(size(dsgn.onsetList));
                dsgn.condLabel = {'stim'};
                rCond{end,1}{1,end}.dsgn  = dsgn;
                rCond{end,1}{1,end}.fList = dir(fullfile(dirs{end,1}.bids,'func',['*task-' rCond{end,1}{1,end}.task '*_bold.nii.gz']));
                rCond{end,1}{1,end}.fList = fullfile({rCond{end,1}{1,end}.fList.folder},{rCond{end,1}{1,end}.fList.name})';
                rCond{end,1}{1,end}.date  = repmat(acqDate,size(rCond{end,1}{1,end}.fList));
                rCond{end,1}{1,end}.nDummy = repmat(dummy,size(rCond{end,1}{1,end}.fList));


                %%% Assert we are not missing any funcitonal files
                fList1 = dir(fullfile(dirs{end,1}.bids,'func','*.nii.gz')); fList1 = fullfile({fList1.folder},{fList1.name})';
                fList2 = [rCond{end}{:}]; fList2 = {fList2.fList}'; fList2 = fList2(~cellfun('isempty',fList2));
                for r = 1:length(fList2); fList2{r} = fList2{r}(:); end;                
                rcGrp = {}; for i = 1:length(fList2); rcGrp{end+1} = num2str(i.*ones(size(fList2{i}))); end
                fList2 = cat(1,fList2{:}); if ~iscell(fList2); fList2 = {}; end
                rcGrp  = cat(1,rcGrp{:} );% if ~iscell(rcGrp);  rcGrp  = {}; end
                disp('db func files accouted for')
                [~,b] = fileparts(fList2);
                disp(char(strcat(rcGrp,'---',b)))
                disp('db func files NOT accouted for')
                [~,b] = fileparts(fList1(~ismember(fList1,fList2)));
                disp(char(b))
                
                %%% behav
                for rc = 1:length(rCond{end})
                    if isempty(rCond{end}{rc}.fList) || ismember(rCond{end}{rc}.task,{'eyeOpenRest'})
                        rCond{end}{rc}.bhvr = [];
                    else
                        fileTime = rCond{end}{rc}.date + getAcqTime(rCond{end}{rc}.fList(:,1));
                        % fileTime = rCond{end}{rc}.date + (fileTime - datetime(strcat(cellstr(num2str(year(fileTime),'%04d')),'-',cellstr(num2str(month(fileTime),'%02d')),'-',cellstr(num2str(day(fileTime),'%02d')))));
                        rCond{end}{rc}.bhvr = parseBehavior_RetinotopicStimulator(fullfile(dirs{end,1}.bhvr,'vsmDriven.log'),fileTime);
                    end
                end
                assertBehavior_RetinotopicStimulator2(rCond{end})
                


                

                
                %%% physio
                forceThis = 0;
                phsFile = dirs{end,1}.phs; if exist(phsFile,'dir'); phsFile = dir(fullfile(dirs{end,1}.phs,'*.mat')); phsFile(ismember({phsFile.name},{'manId.mat' 'minCurated.mat'})) = []; end
                if ~exist('phs','var'); phs = {}; end
                phs{end+1,1} = [];
                if ~isempty(phsFile)
                    tmp = cat(1,rCond{end}{:});
                    for rc = 1:length(tmp); if ~isempty(tmp(rc).fList); tmp(rc).fList = tmp(rc).fList(:,1); end; end
                    if isempty(cat(1,tmp.fList))
                        disp('no MRI to get physio for')
                    else
                        phs{end,1} = extractLabChartData4(fullfile(phsFile.folder,phsFile.name),rCond{end},char(dirs{end,1}.phs),forceThis);
                    end
                end
                


                % sub
                % ses
                % keyboard

            end
        end
        % subList
        % sesList
        % s = 1;
        % rCond{s}{:}
        % pcMRA{s}.fList.name
        % memprage{s}
        % avMap{s}
        % b0{s}.fList.name
        % b1{s}.fList.name


        

    otherwise
        dbstack; error('code that')
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i = 1:length(rCond)
%     tmp = [rCond{i}{:}];
%     [{tmp.sub}
%     {tmp.ses}]
%     assertBehavior_RetinotopicStimulator2(rCond{i})
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Assert bids structure is well defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for RS = 1:length(rCond)
    [S,str] = assertBids(rCond{RS});

    %%% Correct special cases
    if isempty(S); continue; end
    for s = 1:length(S)
        switch str{s}
            case 'sub-vsmDiamCenSurP2_ses-1_acq-vfMRI_task-50sPrd5sDur'
                % ignore this naming difference
            case 'sub-vsmDiamCenSurP9_ses-1_acq-vfMRI_task-50sPrd5sDur'
                % split the two different slice presciptions
                ind = [2 2 2 1 1];
                if size(rCond{RS}{S(s)}.fList,1)~=length(ind)
                    disp('runSet already split');
                    continue
                end
                rCond{RS}{end+1} = rCond{RS}{S(s)};
                rCond{RS}{S(s)}.fList(ind~=1)  = [];
                rCond{RS}{S(s)}.date(ind~=1)   = [];
                rCond{RS}{S(s)}.bhvr(ind~=1)   = [];
                rCond{RS}{S(s)}.nDummy(ind~=1) = [];
                rCond{RS}{end}.prsc = 'back7';
                rCond{RS}{end}.fList(ind~=2)  = [];
                rCond{RS}{end}.date(ind~=2)   = [];
                rCond{RS}{end}.bhvr(ind~=2)   = [];
                rCond{RS}{end}.nDummy(ind~=2) = [];
            otherwise
                dbstack; error('please specify how to deal with that special case')
        end
    end
end

% whos
% for RS = 1:length(rCond)
%     assertBids(rCond{RS});
% end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%
%% Initalize data
%%%%%%%%%%%%%%%%%
forceThis   = 0;
verboseThis = 1;
skipMask    = 1;

runSet  = cell(size(rCond));
volAnat = cell(size(rCond));

sesIndList = 1:length(subList);
for s = 1:length(subList(sesIndList))
    S = sesIndList(s);

    setList = [rCond{S}{:}];
    acqList  = {setList.acq}';
    prscList = {setList.prsc}'; prscList(cellfun('isempty',prscList)) = {'dflt'};
    [setList,b,c] = unique(strcat('acq-',acqList,'_','prsc-',prscList));
    setList = [strcat('acq-',acqList(b)) strcat('prsc-',prscList(b))];
    

    for rs = 1:size(setList,1)
        runSet{S}{1,end+1}.info = info;
        runSet{S}{end}.sub      = subList{S};
        runSet{S}{end}.ses      = sesList{S};
        runSet{S}{end}.label    = strjoin(setList(rs,:),'_');

        %%% Get labels from runCond
        label = strsplit(runSet{S}{end}.label,'_');
        condLabel = cell(size(label));
        for i = 1:length(label)
            label{i} = strsplit(label{i},'-'); label{i} = label{i}{1};
            condLabel{i} = [rCond{S}{:}]'; condLabel{i} = {condLabel{i}.(label{i})}';
            condLabel{i}(cellfun('isempty',condLabel{i})) = {'dflt'};
            condLabel{i} = strcat(label{i},'-',condLabel{i});
        end
        condLabel = cat(2,condLabel{:});
        for r = 1:size(condLabel,1)
            condLabel{r,1} = strjoin(condLabel(r,:),'_');
        end
        condLabel(:,2) = [];
        
        %%% Extract matching runCond and put in runSet
        tmp = [rCond{S}{ismember(condLabel,runSet{S}{end}.label)}];
        runSet{S}{end}.date   = cat(1,tmp.date);
        runSet{S}{end}.fList  = cat(1,tmp.fList);
        runSet{S}{end}.nDummy = cat(1,tmp.nDummy);
        runSet{S}{end}.dbDir  = sesDbList{S};

        if ~isempty(runSet{S}{end}.fList)
            runSet{S}{end} = initPreproc4(runSet{S}{end},[],[],skipMask,forceThis,verboseThis);
        end
    end
end
%% %%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%
%% Draw all masks
%%%%%%%%%%%%%%%%%
forceThis   = 0;
verboseThis = 1;
sesIndList  = 1:length(subList);

%%% First check database for mask in bids derivative directory
for s = 1:length(subList(sesIndList))
    S = sesIndList(s);
    for rs = 1:length(runSet{S})
        if isempty(runSet{S}{rs}.fList); continue; end

        %%% Get preproc mask filenames
        runSet{S}{rs}.dbDirBidsDeriv = fullfile(runSet{S}{rs}.dbDir,'bids','derivatives');
        fBase = char(runSet{S}{rs}.initFiles.fPlumbSmr.sesCat.runAv.fList(:,1));
        runSet{S}{rs}.fMasks.fMaskInv = replace(fBase,'_volTs.nii.gz','_volBrainMaskInv.nii.gz');
        runSet{S}{rs}.fMasks.fMask = replace(fBase,'_volTs.nii.gz','_volBrainMask.nii.gz');
        
        %%% Get db mask filenames
        fDbMaskInv = strsplit(runSet{S}{rs}.fMasks.fMaskInv,filesep);
        fDbMaskInv = strjoin(fDbMaskInv(end-2:end),filesep);
        fDbMaskInv = fullfile(runSet{S}{rs}.dbDirBidsDeriv,fDbMaskInv);
        % fDbMask = strsplit(runSet{S}{rs}.fMasks.fMask,filesep);
        % fDbMask = strjoin(fDbMask(end-2:end),filesep);
        % fDbMask = fullfile(runSet{S}{rs}.dbDirBidsDeriv,fDbMask);

        %%% Copy from db if exists
        if ~forceThis && exist(fDbMaskInv,'file')% && exist(fDbMask,'file')
            copyfile(fDbMaskInv,runSet{S}{rs}.fMasks.fMaskInv);
            % copyfile(fDbMask,runSet{S}{rs}.fMasks.fMask);
        end
    end
end

%%% To draw masks, copy to neurocloud, use freeview there, then copy back
cmd = {};
cmd{end+1} = src.fs;
for s = 1:length(subList(sesIndList))
    S = sesIndList(s);
    for rs = 1:length(runSet{S})
        if isempty(runSet{S}{rs}.fList); continue; end
        fBase = char(runSet{S}{rs}.initFiles.fPlumbSmr.sesCat.runAv.fList(:,1));
        % fMask = replace(fBase,'_volTs.nii.gz','_volBrainMaskInv.nii.gz');
        % runSet{S}{rs}.fMasks.fMaskInv = fMask;
        if forceThis || ~exist(runSet{S}{rs}.fMasks.fMaskInv,'file')
            mri     = MRIread(fBase,1);
            mri.vol = ones(mri.volsize);
            MRIwrite(mri,runSet{S}{rs}.fMasks.fMaskInv);
            cmd{end+1} = ['scp sebp@takoyaki1:' runSet{S}{rs}.fMasks.fMaskInv ' sebp@takoyaki1:' fBase ' .'];
            cmd{end+1} = 'echo draw EXCLUSION mask for the BRAIN (brain=0, nonBrain=1)';
            cmd{end+1} = 'freeview -v \';
            cmd{end+1} = [replace(fBase,[fileparts(fBase) filesep],'./') ' \'];
            cmd{end+1} = [replace(runSet{S}{rs}.fMasks.fMaskInv,[fileparts(runSet{S}{rs}.fMasks.fMaskInv) filesep],'./') ':colormap=heat:opacity=0.33'];
            cmd{end+1} = ['scp ' replace(runSet{S}{rs}.fMasks.fMaskInv,[fileparts(runSet{S}{rs}.fMasks.fMaskInv) filesep],'./') ' sebp@takoyaki1:' runSet{S}{rs}.fMasks.fMaskInv ''];
        end
    end
end
% clipboard('copy',strjoin(cmd,newline));
% Write commands to a file instead of copying to clipboard
if length(cmd)==1
    disp('all masks found in database bids derivative, no need to draw')
else
    cmdFile = fullfile(info.prcDir, 'prc', 'mask_creation_commands.sh');
    fileID = fopen(cmdFile, 'w');
    fprintf(fileID, '%s\n', cmd{:});
    fclose(fileID);
    disp('++++++++++++++++++++++++++++++++++++++++')
    % disp('Command for mask creation is in clipboard.')
    % disp('Paste in freeview capable remote to transfer data, create masks and transfer back.')
    disp('Commands for mask creation are in file:')
    disp(cmdFile)
    disp('Paste in freeview capable remote to transfer data, create masks and transfer back.')
    %%% Wait for user to confirm mask drawing is done
    done = '';
    while ~strcmpi(done, 'done')
        disp('When done, type "done"')
        done = input('', 's');
    end
    disp('++++++++++++++++++++++++++++++++++++++++')
end


%%% Invert mask
for s = 1:length(subList(sesIndList))
    S = sesIndList(s);
    for rs = 1:length(runSet{S})
        if isempty(runSet{S}{rs}.fList); continue; end
        mri = MRIread(runSet{S}{rs}.fMasks.fMaskInv);
        mri.vol = 1-mri.vol;
        if forceThis || ~exist(runSet{S}{rs}.fMasks.fMask,'file')
            MRIwrite(mri,runSet{S}{rs}.fMasks.fMask);
        end
    end
end

%%% Save mask to bidsDerivDir
forceThis = 0;
for s = 1:length(subList(sesIndList))
    S = sesIndList(s);
    for rs = 1:length(runSet{S})
        if isempty(runSet{S}{rs}.fList); continue; end
        
        runSet{S}{rs}.dbDirBidsDeriv = fullfile(runSet{S}{rs}.dbDir,'bids','derivatives');
        
        [a,b,~] = fileparts(replace(runSet{S}{rs}.fMasks.fMask,'.nii.gz','')); [a1,b1,~] = fileparts(a); [a11,b11,~] = fileparts(a1);
        fMask = fullfile(runSet{S}{rs}.dbDirBidsDeriv,b11,b1,[b '.nii.gz']);
        if ~exist(fileparts(fMask),'dir'); mkdir(fileparts(fMask)); end
        [a,b,~] = fileparts(replace(runSet{S}{rs}.fMasks.fMaskInv,'.nii.gz','')); [a1,b1,~] = fileparts(a); [a11,b11,~] = fileparts(a1);
        fMaskInv = fullfile(runSet{S}{rs}.dbDirBidsDeriv,b11,b1,[b '.nii.gz']);
        if ~exist(fileparts(fMaskInv),'dir'); mkdir(fileparts(fMaskInv)); end

        if forceThis || ~exist(fMask,'file')
            copyfile(runSet{S}{rs}.fMasks.fMask,fMask);
        end
        if forceThis || ~exist(fMaskInv,'file')
            copyfile(runSet{S}{rs}.fMasks.fMaskInv,fMaskInv);
        end
    end
end
%% %%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Within-run motion correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
forceThis   = 0;
verboseThis = 1;
param.baseType = 'first'; % 'first' 'av' 'mcAv'

for s = 1:length(subList(sesIndList))
    S = sesIndList(s);
    for rs = 1:length(runSet{S})
        if isempty(runSet{S}{rs}.fList); continue; end
            acqLabel = strsplit(runSet{S}{rs}.label,'_'); acqLabel = replace(acqLabel(contains(acqLabel,'acq-')),'acq-','');
            if strcmp(acqLabel,'bold')
                param.spSmFac  = []; % smoothing parameter (fraction of voxel size)
            else
                param.spSmFac  = 3; % smoothing parameter (fraction of voxel size)
            end
            fBase = [];
            fMask = runSet{S}{rs}.fMasks.fMaskInv;
            
            try
                runSet{S}{rs}.wrMocoFiles = estimMotionWR2(runSet{S}{rs}.initFiles,param,fBase,fMask,forceThis,verboseThis);
            catch
                tmp = fullfile(workDir,['S-' num2str(S) '_RS-' num2str(S)]);
                save(fullfile(tmp,'motion_correction_error.mat'));
            end

            % % % % % % compute all costs
            % % % % % r = 1;
            % % % % % tmp = [];
            % % % % % tmp.initFiles = runSet{S}{rs}.initFiles;
            % % % % % tmp.initFiles.fList = tmp.initFiles.fList(r,:);
            % % % % % tmp.initFiles.nDummy = tmp.initFiles.nDummy(r,:);
            % % % % % tmp.initFiles.fOrigList = tmp.initFiles.fOrigList(r,:);
            % % % % % tmp.initFiles.acqTime = tmp.initFiles.acqTime(r,:);
            % % % % % tmp.initFiles.bidsList = tmp.initFiles.bidsList(r,:);
            % % % % % tmp.initFiles.nFrame = tmp.initFiles.nFrame(r,:);
            % % % % % tmp.initFiles.vSize = tmp.initFiles.vSize(r,:);
            % % % % % tmp.initFiles.fPlumbList = tmp.initFiles.fPlumbList(r,:);
            % % % % % tmp.initFiles.fEstimList = tmp.initFiles.fEstimList(r,:);
            % % % % % tmp.initFiles.fEstimList = {[tmp.initFiles.fEstimList{1} '[300..$]']};
            % % % % % tmp.wrMocoFiles = estimMotionWR2(tmp.initFiles,param,fBase,fMask,1,2);
            % % % % % param1D = strsplit(tmp.wrMocoFiles.cmd{1}{contains(tmp.wrMocoFiles.cmd{1},'1Dparam_save')},' '); param1D = [param1D{2} '.param.1D'];
            % % % % % % add 6 zeros to each row of param1D
            % % % % % tmp.wrMocoFiles.cmd{1}{end+1} = ['-allcostX1D ' param1D ' ' replace(param1D,'.param.1D','.cost')];
            % % % % % tmp.wrMocoFiles.cmd{1}{end-1} = [tmp.wrMocoFiles.cmd{1}{end-1} ' \'];
            % % % % % % loop over base image to get cross-frame correlation
            % % % % % % matrix the idea is that one may derive to best
            % % % % % % reference by averaging only the frames that correlate
            % % % % % % the best among each other
            
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
return




runSet  = cell(size(rCond));
volAnat = cell(size(rCond));

sesIndList = 1:length(subList);
for s = 1:length(subList(sesIndList))
    S = sesIndList(s);

    info.sub          = subList{S};
    info.ses          = sesList{S};
    info.sesDb        = sesDbList{S};

    do.loadIt = 0;
    do.doIt = 1;
    do.saveIt = 0;

    switch info.dataSetLabel
        case {'vsmDriven' 'vsmDiamCenSur'}
            setList = [rCond{S}{:}]; setList = unique({setList.acq}');

            %%% Initiate data
            forceThis   = 1;
            verboseThis = 1;
            skipMask    = 1;
            for rs = 1:length(setList)
                runSet{S}{1,end+1}.info = info;
                runSet{S}{end}.sub      = subList{S};
                runSet{S}{end}.ses      = sesList{S};
                runSet{S}{end}.label    = setList{rs};
                % runSet{S}{end}.wd       = outDir;
                % runSet{S}{end}.bidsDir  = bidsDirList{S};
                % runSet{S}{end}.bidsDerivDir = fullfile(bidsDirList{S},'derivatives',['set-' runSet{S}{end}.label]);
                ind = [rCond{S}{:}]; ind = {ind.acq}; ind = ismember(ind,runSet{S}{end}.label);
                runSet{S}{end}.fList = [rCond{S}{ind}];
                runSet{S}{end}.date   = cat(1,runSet{S}{end}.fList.date);
                runSet{S}{end}.fList  = cat(1,runSet{S}{end}.fList.fList);
                runSet{S}{end}.nDummy = cat(1,dummyList{S}{ind});

                if ~isempty(runSet{S}{end}.fList)
                    runSet{S}{end} = initPreproc3(runSet{S}{end},[],[],skipMask,forceThis,verboseThis);
                    % runSet{S}{end} = rmfield(runSet{S}{end},'date');
                end
            end



            %%% Draw all masks
            forceThis   = 0;
            verboseThis = 0;
            for rs = 1:length(runSet{S})
                if forceThis || ~isempty(runSet{S}{rs}.fList) && (~isfield(runSet{S}{rs},'fMasks') || isempty(runSet{S}{rs}.fMasks))
                    runSet{S}{rs} = initPreproc3(runSet{S}{rs},[],[],0,forceThis,verboseThis);
                end
            end

            
            %%% Estimate within-run motion
            for rs = 1:length(setList)
                if ~isempty(runSet{S}{rs}.fList)
                    forceThis   = 0;
                    verboseThis = 1;
                    param.baseType = 'first'; % 'first' 'av' 'mcAv'
                    if strcmp(runSet{S}{rs}.label,'bold')
                        param.spSmFac  = []; % fraction of voxel size
                    else
                        param.spSmFac  = 3; % fraction of voxel size
                    end
                    fBase = []; fMask = runSet{S}{rs}.initFiles.fMasks.fMaskInv;
                    runSet{S}{rs}.wrMocoFiles = estimMotionWR2(runSet{S}{rs}.initFiles,param,fBase,fMask,forceThis,verboseThis);

                    % forceThis   = 0;
                    % verboseThis = 1;
                    % info.useSynth = 0;
                    % fMask = volAnatPreproc2(do,info,runSet{S}{rs},forceThis,verboseThis);
                    % fMask = fMask.func.mask.brainInv.mri.fspec;

                    % % % % % % compute all costs
                    % % % % % r = 1;
                    % % % % % tmp = [];
                    % % % % % tmp.initFiles = runSet{S}{rs}.initFiles;
                    % % % % % tmp.initFiles.fList = tmp.initFiles.fList(r,:);
                    % % % % % tmp.initFiles.nDummy = tmp.initFiles.nDummy(r,:);
                    % % % % % tmp.initFiles.fOrigList = tmp.initFiles.fOrigList(r,:);
                    % % % % % tmp.initFiles.acqTime = tmp.initFiles.acqTime(r,:);
                    % % % % % tmp.initFiles.bidsList = tmp.initFiles.bidsList(r,:);
                    % % % % % tmp.initFiles.nFrame = tmp.initFiles.nFrame(r,:);
                    % % % % % tmp.initFiles.vSize = tmp.initFiles.vSize(r,:);
                    % % % % % tmp.initFiles.fPlumbList = tmp.initFiles.fPlumbList(r,:);
                    % % % % % tmp.initFiles.fEstimList = tmp.initFiles.fEstimList(r,:);
                    % % % % % tmp.initFiles.fEstimList = {[tmp.initFiles.fEstimList{1} '[300..$]']};
                    % % % % % tmp.wrMocoFiles = estimMotionWR2(tmp.initFiles,param,fBase,fMask,1,2);
                    % % % % % param1D = strsplit(tmp.wrMocoFiles.cmd{1}{contains(tmp.wrMocoFiles.cmd{1},'1Dparam_save')},' '); param1D = [param1D{2} '.param.1D'];
                    % % % % % % add 6 zeros to each row of param1D
                    % % % % % tmp.wrMocoFiles.cmd{1}{end+1} = ['-allcostX1D ' param1D ' ' replace(param1D,'.param.1D','.cost')];
                    % % % % % tmp.wrMocoFiles.cmd{1}{end-1} = [tmp.wrMocoFiles.cmd{1}{end-1} ' \'];
                    % % % % % % loop over base image to get cross-frame correlation
                    % % % % % % matrix the idea is that one may derive to best
                    % % % % % % reference by averaging only the frames that correlate
                    % % % % % % the best among each other

                end
            end
        otherwise
            dbstack; error('code that');
    end
end








%%%%%%%%%%%%%%%%
%% Preprocessing
%%%%%%%%%%%%%%%%
if 1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Session-by-session loop %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    runSet  = cell(size(rCond));
    volAnat = cell(size(rCond));

    sesIndList = 14%:length(subList);
    for s = 1:length(subList(sesIndList))
        S = sesIndList(s);

        % see doIt_pilotPipeline08c/stepTemplate.m
        %% Housekeeping
        info.sub          = subList{S};
        info.ses          = sesList{S};
        info.sesDb        = sesDbList{S};
        % info.bidsDir      = bidsDirList{S};
        % info.bidsDerivDir = fullfile(info.bidsDir,'derivatives'); if ~exist(info.bidsDerivDir,'dir'); mkdir(info.bidsDerivDir); end


        tic; disp(' '); disp(' '); disp(' ');
        tmp = {['sub-' info.sub '_ses-' info.ses]};
        tmp{end+1} = [num2str(s) '/' num2str(length(sesIndList))];
        tmp{end+1} = ['Nses=' num2str(length(subList))];
        tmp = strjoin(tmp,'; ');
        disp(repmat('+',1,length(tmp))); disp(repmat('+',1,length(tmp))); disp(repmat('+',1,length(tmp))); disp(tmp)







        %% Main analysis steps








        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Within-run preprocessing %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        do.loadIt = 0;
        do.doIt = 1;
        do.saveIt = 0;

        switch info.dataSetLabel
            case {'vsmDriven' 'vsmDiamCenSur'}
                setList = [rCond{S}{:}]; setList = unique({setList.acq}');

                %%% Initiate data
                forceThis   = 1;
                verboseThis = 1;
                skipMask    = 1;
                for rs = 1:length(setList)
                    runSet{S}{1,end+1}.info = info;
                    runSet{S}{end}.sub      = subList{S};
                    runSet{S}{end}.ses      = sesList{S};
                    runSet{S}{end}.label    = setList{rs};
                    % runSet{S}{end}.wd       = outDir;
                    % runSet{S}{end}.bidsDir  = bidsDirList{S};
                    % runSet{S}{end}.bidsDerivDir = fullfile(bidsDirList{S},'derivatives',['set-' runSet{S}{end}.label]);
                    ind = [rCond{S}{:}]; ind = {ind.acq}; ind = ismember(ind,runSet{S}{end}.label);
                    runSet{S}{end}.fList = [rCond{S}{ind}];
                    runSet{S}{end}.date   = cat(1,runSet{S}{end}.fList.date);
                    runSet{S}{end}.fList  = cat(1,runSet{S}{end}.fList.fList);
                    runSet{S}{end}.nDummy = cat(1,dummyList{S}{ind});

                    if ~isempty(runSet{S}{end}.fList)
                        runSet{S}{end} = initPreproc3(runSet{S}{end},[],[],skipMask,forceThis,verboseThis);
                        % runSet{S}{end} = rmfield(runSet{S}{end},'date');
                    end
                end



                %%% Draw all masks
                forceThis   = 0;
                verboseThis = 0;
                for rs = 1:length(runSet{S})
                    if forceThis || ~isempty(runSet{S}{rs}.fList) && (~isfield(runSet{S}{rs},'fMasks') || isempty(runSet{S}{rs}.fMasks))
                        runSet{S}{rs} = initPreproc3(runSet{S}{rs},[],[],0,forceThis,verboseThis);
                    end
                end

                
                %%% Estimate within-run motion
                for rs = 1:length(setList)
                    if ~isempty(runSet{S}{rs}.fList)
                        forceThis   = 0;
                        verboseThis = 1;
                        param.baseType = 'first'; % 'first' 'av' 'mcAv'
                        if strcmp(runSet{S}{rs}.label,'bold')
                            param.spSmFac  = []; % fraction of voxel size
                        else
                            param.spSmFac  = 3; % fraction of voxel size
                        end
                        fBase = []; fMask = runSet{S}{rs}.initFiles.fMasks.fMaskInv;
                        runSet{S}{rs}.wrMocoFiles = estimMotionWR2(runSet{S}{rs}.initFiles,param,fBase,fMask,forceThis,verboseThis);

                        % forceThis   = 0;
                        % verboseThis = 1;
                        % info.useSynth = 0;
                        % fMask = volAnatPreproc2(do,info,runSet{S}{rs},forceThis,verboseThis);
                        % fMask = fMask.func.mask.brainInv.mri.fspec;

                        % % % % % % compute all costs
                        % % % % % r = 1;
                        % % % % % tmp = [];
                        % % % % % tmp.initFiles = runSet{S}{rs}.initFiles;
                        % % % % % tmp.initFiles.fList = tmp.initFiles.fList(r,:);
                        % % % % % tmp.initFiles.nDummy = tmp.initFiles.nDummy(r,:);
                        % % % % % tmp.initFiles.fOrigList = tmp.initFiles.fOrigList(r,:);
                        % % % % % tmp.initFiles.acqTime = tmp.initFiles.acqTime(r,:);
                        % % % % % tmp.initFiles.bidsList = tmp.initFiles.bidsList(r,:);
                        % % % % % tmp.initFiles.nFrame = tmp.initFiles.nFrame(r,:);
                        % % % % % tmp.initFiles.vSize = tmp.initFiles.vSize(r,:);
                        % % % % % tmp.initFiles.fPlumbList = tmp.initFiles.fPlumbList(r,:);
                        % % % % % tmp.initFiles.fEstimList = tmp.initFiles.fEstimList(r,:);
                        % % % % % tmp.initFiles.fEstimList = {[tmp.initFiles.fEstimList{1} '[300..$]']};
                        % % % % % tmp.wrMocoFiles = estimMotionWR2(tmp.initFiles,param,fBase,fMask,1,2);
                        % % % % % param1D = strsplit(tmp.wrMocoFiles.cmd{1}{contains(tmp.wrMocoFiles.cmd{1},'1Dparam_save')},' '); param1D = [param1D{2} '.param.1D'];
                        % % % % % % add 6 zeros to each row of param1D
                        % % % % % tmp.wrMocoFiles.cmd{1}{end+1} = ['-allcostX1D ' param1D ' ' replace(param1D,'.param.1D','.cost')];
                        % % % % % tmp.wrMocoFiles.cmd{1}{end-1} = [tmp.wrMocoFiles.cmd{1}{end-1} ' \'];
                        % % % % % % loop over base image to get cross-frame correlation
                        % % % % % % matrix the idea is that one may derive to best
                        % % % % % % reference by averaging only the frames that correlate
                        % % % % % % the best among each other

                    end
                end
            otherwise
                dbstack; error('code that');
        end
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Between-run preprocessing %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% run or load preprocessing
        do.loadIt = 0;
        do.doIt   = 1;
        do.saveIt = 0;
        forceThis   = 0;
        verboseThis = 1;
                    
        switch info.dataSetLabel
            case {'vsmDriven' 'vsmDiamCenSur'}
                for rs = 1:length(runSet{S})
                    if isempty(runSet{S}{rs}.fList); continue; end
                    param.baseType = 'firstRun_avFrame'; % 'first' 'av' 'mcAv'
                    param.spSmFac  = 1; % fraction of voxel size
                    if strcmp(runSet{S}{rs}.label,'bold')
                        param.spSmFac  = []; % fraction of voxel size
                    end
                    fBase = [];
                    fMask = runSet{S}{rs}.fMasks.fMaskInv;
                    runSet{S}{rs}.brMocoFiles = estimMotionBR(runSet{S}{rs}.wrMocoFiles,fBase,fMask,param,forceThis,verboseThis);
                end
            otherwise
                dbstack; error('code that');
        end
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Between-session preprocessing %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% run or load preprocessing
        do.loadIt = 0;
        do.doIt = 1;
        do.saveIt = 0;
        forceThis   = 0;
        verboseThis = 1;

        % if S==4; keyboard; end

        switch info.dataSetLabel
            case {'vsmDriven' 'vsmDiamCenSur'}
                for rs = 1:length(runSet{S})
                    if isempty(runSet{S}{rs}.fList); continue; end
                    
                    % find reference session (here we loop over all sessions, keep the ones with matching sub and choose the first)
                    if S>1
                        % find all associated sessions
                        runSetRef = {};
                        for SS = 1:S-1
                            for rsrs = 1:length(runSet{SS})
                                if ...
                                        strcmp(runSet{SS}{rsrs}.sub,runSet{S}{rs}.sub) && ... % same sub
                                        str2num(runSet{SS}{rsrs}.ses)<str2num(runSet{S}{rs}.ses) && ... % ref ses before current ses
                                        strcmp(runSet{SS}{rsrs}.label,runSet{S}{rs}.label) && ... % same acquisition scheme
                                        ~isempty(runSet{SS}{rsrs}.fList)

                                    runSetRef{end+1} = runSet{SS}{rsrs};
                                end
                            end
                        end

                        if ~isempty(runSetRef)
                            % keep the first one
                            setRefAcqTime = repmat(datetime,size(runSetRef));
                            for ss = 1:length(runSetRef)
                                setRefAcqTime(ss) = min(runSetRef{ss}.acqTime);
                            end
                            [~,b] = min(setRefAcqTime);
                            runSetRef = runSetRef{b};

                            param.sourceType = 'avRun_avFrame';
                            param.spSmFac  = 1; % fraction of voxel size
                            fBase = runSetRef.brMocoFiles.fMocoSmr.sesAv.runAv.fList{1};
                            % fBase = fullfile(runSetRef.brMocoFiles.wd,'av_cat_mcBR_av_mcWR_setPlumb_volTs.nii.gz');
                            fMask = cellstr(runSetRef.brMocoFiles.fMaskList);
                            if length(unique(fMask))==1
                                fMask = fMask{1}; else; dbstack; error('code that');
                            end
                            runSet{S}{rs}.bsMocoFiles = estimMotionBS2(runSet{S}{rs}.brMocoFiles,fBase,fMask,param,forceThis,verboseThis);
                            runSet{S}{rs}.bsMocoFiles.fGeomSes1 = runSetRef.initFiles.fGeom;
                        end
                    end
                end
            otherwise
                dbstack; error('code that');
        end
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



        % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % % % %% Cross-modal preprocessing %
        % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % % % %%% run or load preprocessing
        % % % % do.loadIt = 0;
        % % % % do.doIt = 1;
        % % % % do.saveIt = 0;
        % % % % forceThis   = 0;
        % % % % verboseThis = 1;



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Finalize preprocessing (one-step interpolation) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        do.loadIt = 0;
        do.doIt = 1;
        do.saveIt = 0;
        switch info.dataSetLabel
            case {'vsmDriven' 'vsmDiamCenSur'}
                for rs = 1:length(runSet{S})
                    if isempty(runSet{S}{rs}.fList); continue; end

                    forceThis   = 0;
                    verboseThis = 1;
                    initFiles    = runSet{S}{rs}.initFiles;
                    preprocFiles = permute({runSet{S}{rs}.wrMocoFiles runSet{S}{rs}.brMocoFiles},[1 3 2]);
                    if isfield(runSet{S}{rs},'bsMocoFiles')
                        preprocFiles = cat(3,preprocFiles,{runSet{S}{rs}.bsMocoFiles});
                    else
                        preprocFiles = cat(3,preprocFiles,{[]});
                    end

                    runSet{S}{rs}.finalFiles = finalizePreproc5(initFiles,preprocFiles,forceThis,verboseThis);
                end


                % fList = replace(runSet{S}.wrMocoFiles.fMocoList,'.nii.gz','.param.1D');
                % for f = 1:length(fList)
                %     cmd = {srcAfni};
                %     cmd{end+1} = '1dplot \';
                %     cmd{end+1} = '-yaxis "-1.5:1.5:1:1" - \';
                %     cmd{end+1} = ['-ynames `head -2 ' fList{f} ' | tail -1 | cut -c 3-` - \'];
                %     cmd{end+1} = fList{f};
                %     [status,cmdout] = system(strjoin(cmd,newline),'-echo'); if status; dbstack; error(cmdout); error('x'); end
                % end
            otherwise
                dbstack; error('code that')
        end
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



        %%%%%%%%%%%%%%%%%%%%%%
        %% QA preprocessing %%
        %%%%%%%%%%%%%%%%%%%%%%
        forceThis = 0;
        for rs = 1:length(runSet{S})
            [runSet{S}{rs}.QA.cmd,runSet{S}{rs}.QA.fig] = qaReg4(runSet(S),[],runSet{S}{rs}.label,[],forceThis);
        end
        % rs = 1; runSet{S}{rs}.label
        % clipboard('copy',runSet{S}{rs}.QA.cmd.allAfter{1})
        % clipboard('copy',runSet{S}{rs}.QA.cmd.allMeansAfter)
        % open(runSet{S}{rs}.QA.fig.fAfter)
        
        %% %%%%%%%%%%%%%%%%%%%



        % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % % % %% For surface registration %
        % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % % % forceThis = 0;
        % % % % 
        % % % % %%% fs
        % % % % volAnat{S}{1,end+1}.sub      = subList{S};
        % % % % volAnat{S}{end}.ses          = sesList{S};
        % % % % volAnat{S}{end}.label        = 'fs';
        % % % % volAnat{S}{end}.dbDir        = sesDbList{S};
        % % % % fsDir = dir(fullfile(volAnat{S}{end}.dbDir,'fs',volAnat{S}{1,end}.sub));
        % % % % if isempty(memprage{S}.fList) || isempty(fsDir)
        % % % %     volAnat{S}{end}.wd           = '';
        % % % %     volAnat{S}{end}.bidsDir      = '';
        % % % %     volAnat{S}{end}.bidsDerivDir = '';
        % % % %     volAnat{S}{end}.fsDir        = '';
        % % % % else
        % % % %     disp('fsDir found in dbDir')
        % % % %     volAnat{S}{end}.wd           = outDir;
        % % % %     volAnat{S}{end}.bidsDir      = bidsDirList{S};
        % % % %     volAnat{S}{end}.bidsDerivDir = fullfile(bidsDirList{S},'derivatives',['set-' volAnat{S}{end}.label]);
        % % % %     volAnat{S}{end}.fsDir        = fullfile(volAnat{S}{end}.bidsDerivDir,'fs');
        % % % % 
        % % % %     % copy to bids derivDir
        % % % %     fsDir = fsDir(1).folder;
        % % % %     if ~isFS(fsDir); dbstack; error('fsDir in dbDir does not seem to contain fs analysis'); end
        % % % %     if forceThis || ~isFS(volAnat{S}{end}.fsDir)
        % % % %         disp('copying fsDir from dbDir to bidsDerivDir')
        % % % %         copyfile(fsDir,volAnat{S}{end}.fsDir)
        % % % %     else
        % % % %         disp('fsDir already in bidsDerivDir')
        % % % %     end
        % % % % end
        % % % % 
        % % % % %%% avMap
        % % % % volAnat{S}{1,end+1}.sub      = subList{S};
        % % % % volAnat{S}{end}.ses          = sesList{S};
        % % % % volAnat{S}{end}.label        = 'avMap';
        % % % % if isempty(avMap{S}.fList)
        % % % %     volAnat{S}{end}.fList        = '';
        % % % %     volAnat{S}{end}.dbDir        = '';
        % % % %     volAnat{S}{end}.wd           = '';
        % % % %     volAnat{S}{end}.bidsDir      = '';
        % % % %     volAnat{S}{end}.bidsDerivDir = '';
        % % % % else
        % % % %     volAnat{S}{end}.fList        = avMap{S}.fList;
        % % % %     volAnat{S}{end}.dbDir        = sesDbList{S};
        % % % %     volAnat{S}{end}.wd           = outDir;
        % % % %     volAnat{S}{end}.bidsDir      = bidsDirList{S};
        % % % %     volAnat{S}{end}.bidsDerivDir = fullfile(bidsDirList{S},'derivatives',['set-' volAnat{S}{end}.label]);
        % % % % end   
        % % % % 
        % % % % 
        % % % % % %% Movies
        % % % % % if S==3
        % % % % %     keyboard
        % % % % %     runSet{1:3}.vfMRI
        % % % % %     for s = 1:3
        % % % % %         runSet{s} = runSet{s}{1};
        % % % % %     end
        % % % % %     fList = {};
        % % % % %     for s = 1:3
        % % % % %         fList = cat(1,fList,runSet{s}.finalFiles.fPreprocList);
        % % % % %     end
        % % % % %     % Run averages
        % % % % %     for r = 1:length(fList)
        % % % % %         mri = MRIread(fList{r});
        % % % % %         if r==1
        % % % % %             frames = mean(mri.vol,4);
        % % % % %         else
        % % % % %             frames(:,:,r) = mean(mri.vol,4);
        % % % % %         end
        % % % % %     end
        % % % % %     % figure('WindowStyle','docked');
        % % % % %     % histogram(frames(:))
        % % % % %     framesUINT16 = frames(59:end,22:362,:);
        % % % % %     framesUINT16 = framesUINT16 - 150;
        % % % % %     framesUINT16 = framesUINT16 ./ 500;
        % % % % %     framesUINT16 = uint16(framesUINT16 .* (2^16-1));
        % % % % %     % figure('WindowStyle','docked');
        % % % % %     % imshow(framesUINT16(:,:,end))
        % % % % %     filename = '/autofs/space/takoyaki_001/users/proulxs/vsmDriven/doIt_vsmDriven4simple/runAv_f';
        % % % % %     for f = 1:size(framesUINT16,3)
        % % % % %         imwrite(framesUINT16(:,:,f),[filename num2str(f,'%02i') '.png'])
        % % % % %     end
        % % % % % 
        % % % % %     % one run
        % % % % %     r = 1;
        % % % % %     mri = MRIread(fList{r});
        % % % % %     frames = squeeze(mri.vol);
        % % % % %     % figure('WindowStyle','docked');
        % % % % %     % histogram(frames(:))
        % % % % %     framesUINT16 = frames(59:end,22:362,:);
        % % % % %     framesUINT16 = framesUINT16 - 150;
        % % % % %     framesUINT16 = framesUINT16 ./ 500;
        % % % % %     framesUINT16 = uint16(framesUINT16 .* (2^16-1));
        % % % % %     figure('WindowStyle','docked');
        % % % % %     imshow(framesUINT16(:,:,end))
        % % % % %     filename = '/autofs/space/takoyaki_001/users/proulxs/vsmDriven/doIt_vsmDriven4simple/run1_f';
        % % % % %     for f = 1:size(framesUINT16,3)
        % % % % %         imwrite(framesUINT16(:,:,f),[filename num2str(f,'%03i') '.png'])
        % % % % %     end
        % % % % % 
        % % % % % 
        % % % % % 
        % % % % % 
        % % % % %     frames = frames - min(frames(:));
        % % % % %     frames = frames./max(frames(:));
        % % % % %     frames = uint16(frames./(2^16-1));
        % % % % %     imshow(frames(:,:,3))
        % % % % % 
        % % % % % 
        % % % % %     figure('WindowStyle','docked');
        % % % % %     J = im2uint16(frames);
        % % % % %     imagesc(frames(:,:,3))
        % % % % % end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%
    %% avMap registration %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    % forceThis = 0;
    % subList2 = unique(subList);
    % avMap = cell(size(subList2));
    % fs    = cell(size(subList2));
    % vfMRI = cell(size(subList2));
    % %%% get relevant data struct for each subject
    % for S = 1:length(subList2)
    %     volAnat2 = volAnat(ismember(subList,subList2{S}));
    %     runSet2  = runSet(ismember(subList,subList2{S}));
    %     for s = 1:length(volAnat2)
    %         for ar = 1:length(volAnat2{s})
    %             %%% get avMap
    %             if strcmp(volAnat2{s}{ar}.label,'avMap') && ~isempty(volAnat2{s}{ar}.fList)
    %                 avMap{S}{end+1} = volAnat2{s}{ar};
    %             end
    %             %%% get fs
    %             if strcmp(volAnat2{s}{ar}.label,'fs') && ~isempty(volAnat2{s}{ar}.fsDir)
    %                 fs{S}{end+1} = volAnat2{s}{ar};
    %             end
    %         end
    %         for ar = 1:length(runSet2{s})
    %             %%% get vfMRI
    %             if strcmp(runSet2{s}{ar}.label,'vfMRI') && isfield(runSet2{s}{ar},'finalFiles') && strcmp(runSet2{s}{ar}.ses,'1')
    %                vfMRI{S}{end+1} = runSet2{s}{ar}.finalFiles;
    %             end
    %         end
    %     end
    %     %%% make sure data struct make sense
    %     if length(fs{S})~=1; dbstack; error(['expecting a single data struct for fs of ' subList2{S}]); end
    %     fs{S} = fs{S}{1};
    %     if length(avMap{S})~=1; dbstack; error(['expecting a single data struct for avMap of ' subList2{S}]); end
    %     avMap{S} = avMap{S}{1};
    %     if length(vfMRI{S})~=1; dbstack; error(['expecting a single data struct for vfMRI of ' subList2{S}]); end
    %     vfMRI{S} = vfMRI{S}{1};
    % end
    % 
    % %%% write avMap into functional space without resampling
    % for S = 1:length(avMap)
    %     fList = fullfile({avMap{S}.fList.folder},{avMap{S}.fList.name})';
    %     ref = fullfile(vfMRI{S}.bidsDerivDir,'sesAvCat_av_cat_av_preproc_volTs.nii.gz');
    %     fAvMap = fullfile(avMap{S}.bidsDerivDir,replace(avMap{S}.fList(1).name,'.nii.gz',''));
    %     fAvMap = replace(fAvMap,'echo-1','echo-cat'); if ~exist(fAvMap,'dir'); mkdir(fAvMap); end
    %     fAvMap = fullfile(fAvMap,'in-vfMRI.nii.gz');
    %     if forceThis || ~exist(fAvMap,'file')
    %         mriRef  = MRIread(ref,1);
    %         for i = 1:length(fList)
    %             mri = MRIread(fList{i});
    %             if i==1
    %                 mriRef.vol = mri.vol;
    %                 mriRef.volres = mri.volres;
    %                 mriRef.xsize  = mri.xsize;
    %                 mriRef.ysize  = mri.ysize;
    %                 mriRef.zsize  = mri.zsize;
    %                 mriRef.tr     = mri.tr;
    %                 mriRef.te     = mri.te;
    %             else
    %                 mriRef.vol = cat(4,mriRef.vol,mri.vol);
    %             end
    %         end
    %         MRIwrite(mriRef,fAvMap);
    %     end
    %     avMap{S}.fList_invfMRI = cellstr(fAvMap);
    %     if S==2; keyboard; end
    %     try length(volAnat2{S}); catch keyboard; end
    %     for i = 1:length(volAnat2{S})
    %         if ~strcmp(volAnat2{S}{i}.label,'avMap'); continue; end
    %         volAnat2{S}{i}.fList_invfMRI = cellstr(fAvMap);
    %     end
    % end
    % 
    % % disp(strjoin([fullfile(vfMRI{S}.bidsDerivDir,'sesAvCat_av_cat_av_preproc_volTs.nii.gz')
    % % fullfile({avMap{S}.fList.folder},{avMap{S}.fList.name})'
    % % avMap{S}.fList_invfMRI],[' \\' newline]))
    % 
    % % %%% Surface registration not working for avMap for a lack of WM to GM
    % % %%% contrast. May be able to make it work somehow but too much work
    % % [SUBJECTS_DIR,SUBJECT,~] = fileparts(fs{S}.fsDir);
    % % MOV = {avMap{S}.fList.name}'; MOV = avMap{S}.fList(contains(MOV,'echo-1')); MOV = fullfile(MOV.folder,MOV.name);
    % % [~,curOutDir,~] = fileparts(replace(MOV,'.nii.gz','')); curOutDir = fullfile(avMap{S}.bidsDerivDir,curOutDir);
    % % surfReg(SUBJECTS_DIR,SUBJECT,MOV,curOutDir)
    % for s = 1:length(runSet)
    %     for ar = 1:length(runSet{s})
    %         if ~strcmp(runSet{s}{ar}.label,'vfMRI'); continue; end
    %         sub = runSet{s}{ar}.sub;
    %         for S = 1:length(avMap)
    %             if ~strcmp(avMap{S}.sub,sub); continue; end
    %             runSet{s}{ar}.avMap.f = avMap{S}.fList_invfMRI;
    %         end
    %     end
    % end
    %% %%%%%%%%%%%%%%%%%%%%%



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Refactor from set to cond (and anonymize) %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rCondOrig = rCond;
    % rCond = rCondOrig;
    [rCond ,subList ,runCondAcqList ,runCondStimList ] = set2cond4(runSet,rCond,phs,volAnat);

    
    %%% QA preprocessing including cross-session
    forceThis = 0;
    for S = 1:length(rCond)
        acq = fields(rCond{S}); acq(ismember(acq,{'phs' 'QA'})) = [];
        for a = 1:length(acq)
            [rCond{S}.QA.(acq{a}).cmd,rCond{S}.QA.(acq{a}).fig,rCond{S}.QA.(acq{a}).prcSmr] = qaRegOnRunCond(rCond{S}.(acq{a}),forceThis);
            % rCond{S}.QA.(acq{a}).prcSmr = rCond{S}.(acq{a}).prcSmr.smr;
            % rCond{S}.(acq{a}) = rmfield(rCond{S}.(acq{a}),'prcSmr');
        end
        rCond{S}.QA.skipFlag = 1;
    end

    %%% preload volTs headers
    rCond = MRIload3(rCond)';
    
    %%% save info and headers
    disp(['saving to ' info.datasetDir '.mat']);
    save(info.datasetDir,'info','rCond','subList','runCondAcqList','runCondStimList','-v7.3')
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Load preprocessed data filenames %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['loading from ' info.datasetDir '.mat']);
    load(info.datasetDir,'rCond','subList','runCondAcqList','runCondStimList')
    % intermediateMatFile = [mfilename('fullpath') '_study-' info.dataSetLabel];
    % disp(['loading from ' intermediateMatFile '.mat']);
    % load(intermediateMatFile,'rCond','subList','runCondAcqList','runCondStimList')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%% %%%%%%%%%%%%%






return















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Anatomical processing (masks and rois) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do.loadIt = 0;
do.doIt   = 1;
do.saveIt = 0;
forceThis   = 0;
forceRoi    = 0;
verboseThis = 1;

for S = 1:length(rCond)
    info.sub = subList{S};
    for rca = 1:length(runCondAcqList)
        if ~contains(runCondAcqList{rca},'vfMRI'); continue; end
        if ~isfield(rCond{S},runCondAcqList{rca}); continue; end
        % if isfield(runCond{S},'avMap')
        %     [out,avMap] = volAnatPreproc4(do,info,runCond{S}.(runCondAcqList{rca}),runCond{S}.avMap,forceThis,forceRoi);
        % else
            [out,avMap] = volAnatPreproc4(do,info,rCond{S}.(runCondAcqList{rca}),[],forceThis,forceRoi);
        % end
        for rcs = 1:length(runCondStimList)
            if ~isfield(rCond{S},runCondAcqList{rca});                        continue; end
            if ~isfield(rCond{S}.(runCondAcqList{rca}),runCondStimList{rcs}); continue; end
            if ~isfield(out.label,'vfMRI');                         continue; end
            rCond{S}.(runCondAcqList{rca}).(runCondStimList{rcs}).volAnat = out.label.vfMRI;
            rCond{S}.avMap = avMap;
            rCond{S}.acq   = runCondAcqList{rca};
            rCond{S}.mask  = out.mask;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response estimation and activation detection processing %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do.loadIt   = 0;
do.doIt     = 1;
do.saveIt   = 0;
do.writeIt  = 1;
forceThis   = 0;
verboseThis = 0;

% runCondStimList_tmp = runCondStimList(~contains(runCondStimList,{'task_eyeOpenRest'}));
runCondStimList_tmp = runCondStimList(contains(runCondStimList,{'task_50sPrd1sDur'}));
runCondAcqList_tmp  = runCondAcqList( contains(runCondAcqList ,{'vfMRIinflowSlcBck' 'vfMRIinflowSlcMid' 'vfMRIinflowSlcFrnt'}));

% Double-check designs look fine (especially catch trials)
for S = 1:size(rCond,1)
    for A = 1:length(runCondAcqList_tmp)
        runCondAcq  = runCondAcqList_tmp{A}; if ~isfield(rCond{S},runCondAcq) || isempty(rCond{S}.(runCondAcq)); continue; end
        for C = 1:length(runCondStimList_tmp)
            runCondStim = runCondStimList_tmp{C}; if ~isfield(rCond{S}.(runCondAcq),runCondStim) || isempty(rCond{S}.(runCondAcq).(runCondStim)); continue; end
            disp('!!!!')
            disp([num2str(S) '; ' runCondAcq  '; ' runCondStim])
            
            dsgn = rCond{S}.(runCondAcq).(runCondStim).dsgn;
            if ~isfield(dsgn,'nullTrial')
                disp([dsgn.label '; ' num2str(mean(diff(dsgn.onsetList))) '; ' num2str(0) '; ' num2str(0)])
            else
                disp([dsgn.label '; ' num2str(mean(diff(dsgn.onsetList))) '; ' num2str(find(dsgn.nullTrial)) '; ' num2str(length(dsgn.nullTrial))])
            end

            bhvr = rCond{S}.(runCondAcq).(runCondStim).bhvr;
            disp({bhvr.command}')
        end
    end
end

% Do the thing
for S = 1:size(rCond,1)
    for A = 1:length(runCondAcqList_tmp)
        runCondAcq  = runCondAcqList_tmp{A}; if ~isfield(rCond{S},runCondAcq) || isempty(rCond{S}.(runCondAcq)); continue; end
        
        %anat
        % veMask = runCond{S}.label.vfMRI.calcarineVessel.f;
        veMask = [];
        hdMask = rCond{S}.mask{1}.head.mri;
        
        for C = 1:length(runCondStimList_tmp)
            % if S==3
            %     runCondStim = 'task_50sPrd1sDur'; if ~isfield(runCond{S}.(runCondAcq),runCondStim) || isempty(runCond{S}.(runCondAcq).(runCondStim)); continue; end
            % else
                runCondStim = runCondStimList_tmp{C}; if ~isfield(rCond{S}.(runCondAcq),runCondStim) || isempty(rCond{S}.(runCondAcq).(runCondStim)); continue; end
            % end

            %ts
            volTs = cpInfoDown(...
                rCond{S}.(runCondAcq).(runCondStim),...
                rCond{S}.(runCondAcq).(runCondStim).volTs);
            volTs = MRIload3(volTs,[],[],1);

            % % get alternate design matrix (50% dutty cycle)
            % if S==1
            %     tmpTs = volTs(1:2);
            %     [tmpTs.dryRun] = deal(true);
            %     dsgn = volTs(1).dsgn;
            %     dsgn.ondurList = diff(dsgn.onsetList)/2;
            %     info.dryRun = 1;
            %     [~,volActCat,~] = volTsGetResp3(do,info,tmpTs,dsgn,hdMask,forceThis,verboseThis);
            %     info.dryRun = 0;
            %     xMatAlt{C} = volActCat.afni.fMatFig;
            % end
            
            %resp
            info.doCat = 1;
            info.doRun = 0;
            [volRespCat,volActCat,volResp,volAct,info] = volTsGetResp3(do,info,volTs,[],hdMask,forceThis,verboseThis);
            rCond{S}.(runCondAcq).(runCondStim).volRespCat = volRespCat;
            rCond{S}.(runCondAcq).(runCondStim).volActCat  = volActCat;
            rCond{S}.(runCondAcq).(runCondStim).volResp    = volResp;
            rCond{S}.(runCondAcq).(runCondStim).volAct     = volAct;

        end
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strjoin({rCond{S}.vfMRIinflowSlcBck.task_50sPrd1sDur.volActCat.fs.fBaseAv
rCond{S}.vfMRIinflowSlcBck.task_50sPrd1sDur.volActCat.fs.fCoef
rCond{S}.vfMRIinflowSlcBck.task_50sPrd1sDur.volRespCat.fs.fRespTs},' ')

strjoin({rCond{S}.vfMRIinflowSlcMid.task_50sPrd1sDur.volActCat.fs.fBaseAv
rCond{S}.vfMRIinflowSlcMid.task_50sPrd1sDur.volActCat.fs.fCoef
rCond{S}.vfMRIinflowSlcMid.task_50sPrd1sDur.volRespCat.fs.fRespTs},' ')

strjoin({rCond{S}.vfMRIinflowSlcFrnt.task_50sPrd1sDur.volActCat.fs.fBaseAv
rCond{S}.vfMRIinflowSlcFrnt.task_50sPrd1sDur.volActCat.fs.fCoef
rCond{S}.vfMRIinflowSlcFrnt.task_50sPrd1sDur.volRespCat.fs.fRespTs},' ')


strjoin({rCond{S}.vfMRIinflowSlcFrnt.task_50sPrd1sDur.volActCat.fs.fBaseAv
rCond{S}.vfMRIinflowSlcMid.task_50sPrd1sDur.volActCat.fs.fBaseAv},' ')


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Temporal hyper-resolution %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = 1;
volTs = rCond{S}.vfMRI.task_50sPrd5sDur.volTs;
volTs = MRIload3(volTs,[],[],0);
im = [volTs.mri];
im = cat(3,im.vol); % PE x FE x R x T
% tmp = abs(fftshift(fft(mean(im(:,:,:),3),[],1),1));
% imagesc(tmp)
% ax = gca; ax.ColorScale = 'log'; ax.DataAspectRatio = [1 1 1]; ax.Colormap = gray; colorbar;
km = abs(fft(im,[],1));
% imagesc(mean(abs(km),4))
% ax = gca; ax.ColorScale = 'log'; ax.DataAspectRatio = [1 1 1]; ax.Colormap = gray; colorbar;
km = permute(km,[2 1 4 3]); % FE x PE x T x R
% km = mean(km,5);
% km = km - mean(km(:,:,:),3);
kmtf = fft(km(:,:),[],1);



Y = kmtf;
Fs = 1/(volTs(1).mri.tr/1000/100);
L = size(Y(:,:),2);
P2 = abs(Y/L);
P1 = P2(:,1:L/2+1);
P1(:,2:end-1) = 2*P1(:,2:end-1);
f = Fs*(0:(L/2))/L;
figure('WindowStyle','docked');
Y = mean(P1,1);
plot(f,Y)
xlim([0 1])
[a,b] = max(Y(f<0.06666));
bb = find(f<0.06666);
Fs/f(bb(b))

1/(volTs(1).mri.tr/1000/100)

imagesc([],f,P1')
ax = gca; ax.ColorScale = 'log';


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Single line projection %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = 1;
volTs = rCond{S}.vfMRI.task_50sPrd5sDur.volTs;
volTs = MRIload3(volTs,[],[],0);

mri = [volTs.mri];
im = cat(5,mri.vol);
imM = mean(im(:,:,:,:),4);
figure('WindowStyle','docked');
ht = tiledlayout(2,1); ht.Padding = 'tight'; ht.TileSpacing = 'tight';
nexttile
imagesc(imM);
ax = gca; ax.DataAspectRatio = [1 1 1]; ax.Colormap = gray;
ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off';
nexttile
hP = plot(squeeze(mean(reshape(imM',[400 80 5]),2)))
ax2 = gca;
linkprop([ax ax2],'PlotBoxAspectRatio');
linkaxes([ax ax2],'x');
for i = 1:length(hP)
    hL(i) = line(ax,[1 1],[1 80]+(i-1)*80)
    hL(i).Color = hP(i).Color;
    hL(i).LineWidth = 5;
    hL2(i) = line(ax,[400 400],[1 80]+(i-1)*80)
    hL2(i).Color = hP(i).Color;
    hL2(i).LineWidth = 5;
end
xlabel(ax2,'frequency-encoding voxel index')
ylabel(ax2,'MR signal (a.u.)')

delete([hX1 hX2 hY1]); clear hX1 hX2 hY1
while 1
    [x,y] = ginput(1);
    if ~exist('hX1','var') || ~exist('hX2','var') || ~exist('hY1','var')
        hX1 = xline(ax,x,'r');
        hX2 = xline(ax2,x,'r')
        hY1 = yline(ax,y,'r');
        drawnow
    else
        hX1.Value = x;
        hX2.Value = x;
        hY1.Value = y;
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
%% Per vessel analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%
for S = 1:5
    % if ~isfield(runCond{S}.vfMRI,'task_50sPrd5sDur'); hFigCat{S} = []; hFigRun{S} = []; continue; end
    catFlag = 1;
    runFlag = 0;
    if S==3
        [hFigCat{S},hFigRun{S}] = plotVessels(rCond{S}.vfMRI.task_50sPrd1sDur,catFlag,runFlag);
    else
        [hFigCat{S},hFigRun{S}] = plotVessels(rCond{S}.vfMRI.task_50sPrd5sDur,catFlag,runFlag);
    end
end
% FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
% for i = 1:length(FigList)
%     saveas(FigList(i),['doIt_vsmDriven4simpleR' num2str(i) '.fig'])
% end

x = cell(0,0); y = cell(0,0);
metric1 = 'psd'; % coh psd
metric2 = 'lstPC'; % ful lst lstPC
for S = 1:5
    if S>length(hFigCat) || isempty(hFigCat{S}); continue; end
    x{end+1,1} = []; y{end+1,1} = [];
    % coh 6; psd 5
    switch metric1
        case 'coh'
            metInd = 6;
        case 'psd'
            metInd = 5;
    end
    % ful [0 0 0]; lst [1 0 0]
    switch metric2
        case 'ful'
            metCol = [0 0 0];
        case 'lst'
            metCol = [1 0 0];
        case 'lstPC'
            metCol = [0 0 1];
    end
    % art
    vesCol = [1 0 0];
    [x{end}(end+1,:),y{end}(end+1,:)] = doIt_vsmDriven4simple_extractSpc(hFigCat{S}(metInd),vesCol,metCol);
    % vei
    vesCol = [0 0 1];
    [x{end}(end+1,:),y{end}(end+1,:)] = doIt_vsmDriven4simple_extractSpc(hFigCat{S}(metInd),vesCol,metCol);
    % all
    vesCol = [0 0 0];
    [x{end}(end+1,:),y{end}(end+1,:)] = doIt_vsmDriven4simple_extractSpc(hFigCat{S}(metInd),vesCol,metCol);
end

x = cat(3,x{:});
y = cat(3,y{:});

labelList = {'art' 'vei' 'all'};
ax = {};
for vesInd = 1:3 % art 1; vei 2; all 3
    figure('WindowStyle','docked');

    xAv = mean(squeeze(x(vesInd,:,:)),2);
    yAv = mean(squeeze(y(vesInd,:,:)),2);
    yEr = std(squeeze(y(vesInd,:,:)),[],2)./sqrt(5);
    shplot(xAv,yAv,yEr)
    hold on
    
    hPlot = plot(...
        squeeze(x(vesInd,:,:)),...
        squeeze(y(vesInd,:,:))...
        )
    
    ylabel([labelList{vesInd} ' ' metric1 ' ' metric2])

    legend(hPlot,num2str((1:5)'))

    switch metric1
        case 'coh'
            ax{end+1} = gca; ax{end}.YScale = 'linear';
        case 'psd'
            ax{end+1} = gca; ax{end}.YScale = 'log';
    end
end
yLim = get([ax{:}],'YLim');
yLim = [yLim{:}];
yLim = [min(yLim) max(yLim)];
set([ax{:}],'YLim',yLim);








% psd.full.x = x;
% psd.full.y = y;
% psd.lastPC.x = x;
% psd.lastPC.y = y;
% save allPsd psd
load allPsd

f = figure('WindowStyle','docked');
ht = tiledlayout(2,5,'TileIndexing','columnmajor');
ht.TileSpacing = 'tight';
ht.Padding = 'tight';
ax = cell(2,5);
for S = 1:5
    %art
    ax{1,S} = nexttile;
    %ful
    x = squeeze(psd.full.x(1,:,S));
    y = squeeze(psd.full.y(1,:,S));
    plot(x,y,'k'); hold on
    %lstPC
    x = squeeze(psd.lastPC.x(1,:,S));
    y = squeeze(psd.lastPC.y(1,:,S));
    plot(x,y,'m','LineWidth',2); hold on
    ax{1,S}.XAxis.Color = 'r';
    ax{1,S}.YAxis.Color = 'r';
    axis tight

    %vei
    ax{2,S} = nexttile;
    %ful
    x = squeeze(psd.full.x(2,:,S));
    y = squeeze(psd.full.y(2,:,S));
    plot(x,y,'k'); hold on
    %lstPC
    x = squeeze(psd.lastPC.x(2,:,S));
    y = squeeze(psd.lastPC.y(2,:,S));
    plot(x,y,'m','LineWidth',2); hold on
    ax{2,S}.XAxis.Color = 'b';
    ax{2,S}.YAxis.Color = 'b';
    axis tight
end
set([ax{:}],'YScale','log')
yLim = get([ax{:}],'YLim'); yLim = [yLim{:}]; yLim = [min(yLim) max(yLim)];
set([ax{:}],'YLim',yLim);
% for S = 1:5
    % yLim = get([ax{:,S}],'YLim'); yLim = [yLim{:}]; yLim = [min(yLim) max(yLim)];
    % set([ax{:,S}],'YLim',yLim);
% end
grid([ax{:}],'on')
set([ax{:}],'XMinorGrid','on')
tmp = get([ax{:}],'XAxis'); set([tmp{:}],'LineWidth',3)
tmp = get([ax{:}],'YAxis'); set([tmp{:}],'LineWidth',3)
for i = 1:numel(ax)
    uistack(xline([ax{i}],(1:4)/mean(diff(dsgn.onsetList)),'g','LineWidth',0.05),'bottom')
end
f.Color = 'w'
set([ax{:}],'PlotBoxAspectRatio',[1 1 1])
tmp = [ax{:,2:end}]; tmp.YTickLabel
set([ax{:,2:end}],'YTickLabel',{})



return
%% %%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Multi-taper spectral processing %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
verboseThis = 2;

runCondStimList_tmp = runCondStimList(~contains(runCondStimList,{'task_eyeOpenRest'}));
% runCondStimList_tmp = runCondStimList;
runCondAcqList_tmp  = runCondAcqList( ~contains(runCondAcqList ,{'bold'}));

volPsd = cell(size(rCond));
for S = 1:size(rCond,1)
    for A = 1:length(runCondAcqList_tmp)
        runCondAcq  = runCondAcqList_tmp{A};
        if ~isfield(rCond{S},runCondAcq) || isempty(rCond{S}.(runCondAcq))
            continue
        end

        %anat
        veMask      = MRIload3(rCond{S}.label.vfMRI.calcarineVessel.f,[],[],0);
        artMask = veMask.vol==902;
        veiMask = veMask.vol==914;
        % hdMask      = runCond{S}.mask{1}.head.mri;
        % brMask      = runCond{S}.mask{1}.brain.mri;
        % veNtissMask = MRIread(runCond{S}.label.vfMRI.calcarineVesselPlusTissueSurround.f);
        
        for C = 9%1:length(runCondStimList_tmp)
            runCondStim = runCondStimList_tmp{C};
            if ~isfield(rCond{S}.(runCondAcq),runCondStim) || isempty(rCond{S}.(runCondAcq).(runCondStim))
                continue
            end

            
            %ts
            volTs = cpInfoDown(...
                rCond{S}.(runCondAcq).(runCondStim),...
                rCond{S}.(runCondAcq).(runCondStim).volTs);
            volTs = MRIload3(volTs,[],[],0);
            % for r = 1:length(volTs)
            %     [volTs(r),poly,order] = dtrnd2(volTs(r));
            % end



            % %mt-spectra
            % K     = 4;
            % W     = [];
            % % win   = mean(diff(runCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
            % % win   = min(win,20); % in seconds [lenght, step]
            % win   = []; % in seconds [lenght, step]
            % extra = [];
            % mask      = artMask;
            % volResp   = runCond{S}.(runCondAcq).(runCondStim).volRespCat;
            % volAct    = runCond{S}.(runCondAcq).(runCondStim).volActCat;
            % outField  = ['volPsd_K' num2str(K)];
            % volPsd{S} = runFullMT3(volTs,W,K,win,[],[],mask,extra,[],[],verboseThis,[],[])';
            % dsgn = volTs(1).dsgn;
            % for r = 1:length(volTs)
            %     plotSpecAll3(volPsd{S}(r),volTs(r),volResp,volAct,dsgn,mask,[],0.05)
            % end
            
            
            

            %mt-spectra
            K     = 5;
            W     = [];
            % win   = mean(diff(runCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
            % win   = min(win,20); % in seconds [lenght, step]
            win   = 20; % in seconds [lenght, step]
            extra = [];
            mask      = artMask;
            volResp   = rCond{S}.(runCondAcq).(runCondStim).volRespCat;
            volAct    = rCond{S}.(runCondAcq).(runCondStim).volActCat;
            outField  = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
            % runCond{S}.(runCondAcq).(runCondStim).(outField)  = runFullMT3(volTs,W,K,win,[],[],artMask,extra,[],[],verboseThis,[],[])';
            volPsd{S} = runFullMT3(volTs(1),W,K,win,[],[],mask,extra,[],[],verboseThis,[],[])';
            dsgn = volTs(1).dsgn;

            plotSpecAll3(volPsd{S}(end),volTs,volResp,volAct,dsgn,mask,[],0.05)


            for r = 1:6
                volPsd1 = runFullMT3(volTs(r),W,K,win,[],[],mask,extra,[],[],verboseThis,[],[])';
                % plotSpecAll3(volPsd1,volTs(1),volResp,volAct,dsgn,mask,[],0.05)
                figure('WindowStyle','docked');
                ht{r} = tiledlayout(1,2)
                ax1{r} = nexttile;
                plotSpecGram4(ax1{r},volPsd1,'trialGramMD','cohEPC',dsgn);
                xlim auto
            end



            ht  = cell(size(volPsd{S}));
            ax1 = cell(size(volPsd{S}));
            ax2 = cell(size(volPsd{S}));
            for r = 1:length(volPsd{S})
                figure('WindowStyle','docked');
                ht{r} = tiledlayout(1,2)
                ax1{r} = nexttile;
                plotSpecGram4(ax1{r},volPsd{S}(r),'trialGramMD','psdEPC',dsgn);
                xlim auto
                ax2{r} = nexttile;
                plotSpecGram4(ax2{r},volPsd{S}(r),'trialGramMD','cohEPC',dsgn);
                xlim auto
                title(ht{r},[subList{S} ';run ' num2str(r) '/' num2str(length(volPsd{S}))])
            end
            cLim = get([ax1{:}],'CLim'); cLim = [cLim{:}]; cLim = [min(cLim) max(cLim)];
            set([ax1{:}],'CLim',cLim);
            cLim = get([ax2{:}],'CLim'); cLim = [cLim{:}]; cLim = [min(cLim) max(cLim)];
            set([ax2{:}],'CLim',cLim);


            
            % %mt-spectra
            % K     = 13;
            % W     = [];
            % % win   = mean(diff(runCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
            % % win   = min(win,20); % in seconds [lenght, step]
            % win   = 20; % in seconds [lenght, step]
            % extra = [];
            % outField = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
            % runCond{S}.(runCondAcq).(runCondStim).(outField)  = runFullMT3(volTs,W,K,win,[],[],veNtissMask,extra,[],[],verboseThis,[],[])';
            % 
            % K     = 10;
            % W     = [];
            % % win   = mean(diff(runCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
            % % win   = min(win,20); % in seconds [lenght, step]
            % win   = 20; % in seconds [lenght, step]
            % extra = [];
            % outField = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
            % runCond{S}.(runCondAcq).(runCondStim).(outField)  = runFullMT3(volTs,W,K,win,[],[],veMask,extra,[],[],verboseThis,[],[])';
            % 
            % K     = 15;
            % W     = [];
            % % win   = mean(diff(runCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
            % % win   = min(win,20); % in seconds [lenght, step]
            % win   = 20; % in seconds [lenght, step]
            % extra = [];
            % outField = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
            % runCond{S}.(runCondAcq).(runCondStim).(outField) = runFullMT3(volTs,W,K,win,[],[],veMask,extra,[],[],verboseThis,[],[])';
        end
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Frequency-domain frequency-response prediction (fundamental only) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
verboseThis = 2;

runCondAcq          = runCondAcqList{  contains(runCondAcqList ,{'vfMRI'})           };
runCondStimList_tmp = runCondStimList(~contains(runCondStimList,{'task_eyeOpenRest'}));

% Compute
res.harm       = cell(length(rCond),length(runCondStimList_tmp));
res.harmCanon  = cell(length(rCond),length(runCondStimList_tmp));
res.f          = cell(length(rCond),length(runCondStimList_tmp));
res.voxSelCond = cell(length(rCond),1                          );
for S = 1:size(rCond,1)
    
    % anatomical voxel selection
    vesselMask = MRIload3(rCond{S}.label.(runCondAcq).calcarineVessel.f,[],[],0);
    vesselMask = logical(vesselMask.vol);

    % functional voxel selection (SPM canon+deriv)
    %%% selection condition 
    if isfield(rCond{S}.(runCondAcq),'task_50sPrd5sDur') && ~isempty(rCond{S}.(runCondAcq).task_50sPrd5sDur)
        curCond = rCond{S}.(runCondAcq).task_50sPrd5sDur;
    elseif isfield(rCond{S}.(runCondAcq),'task_50sPrd1sDur') && ~isempty(rCond{S}.(runCondAcq).task_50sPrd1sDur)
        % special case (vsmDrivenP3):
        % we don't have task_50sPrd5sDur for this subject, so
        % let's use task_50sPrd1sDur. Importantly, we must discard
        % task_50sPrd1sDur from the final analysis.
        % % % % % % % % % curCond = runCond{S}.(runCondAcq).task_50sPrd1sDur;
        % or we just don't use any functional mask, allowing to keep the
        % task_50sPrd1sDur condition for the final analysis
        curCond = [];
    else
        error('can''t find a condition for voxel selection' )
    end
    if isempty(curCond)
        fdrMask = true(size(vesselMask));
        res.voxSelCond{S} = 'none';
    else
        pVal                = MRIread(curCond.volActCat.fs.fFullP); pVal = pVal.vol;
        fdrMask             = nan(size(pVal));
        fdrMask(vesselMask) = mafdr(pVal(vesselMask));
        fdrMask             = fdrMask<0.05;
        % looks like almost all vessels are activated, so we may do without the
        % functional voxel selection
        res.voxSelCond{S} = ['task_' curCond.label];
    end
    allMask{S} = vesselMask&fdrMask;
    
    for C = 1:length(runCondStimList_tmp)
        runCondStim = runCondStimList_tmp{C};
        if ~isfield(rCond{S}.(runCondAcq),runCondStim) || isempty(rCond{S}.(runCondAcq).(runCondStim)) ...
                || strcmp(runCondStim,res.voxSelCond{S}) ...
                || strcmp(runCondStim,'task_50sPrd5sDur')
            % skip if condition does not exist
            % or if it was used for voxel selection
            % or if it is the 5sDur condition
            continue
        end

        % load ts
        volTs = cpInfoDown(...
            rCond{S}.(runCondAcq).(runCondStim),...
            rCond{S}.(runCondAcq).(runCondStim).volTs);
        volTs = MRIload3(volTs,[],[],0);

        % perfrom mt spectral ana
        K     = 13;
        W     = [];
        win   = inf; % in seconds [lenght, step]
        extra = [];
        outField = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
        curCond = runFullMT3(volTs,W,K,win,[],[],vesselMask&fdrMask,extra,[],[],verboseThis,[],[])';

        % extract line power (harmonic signal amplitudes)
        for r = 1:size(curCond,1)
            curCond(r).vec = permute(curCond(r).harm.linePwr(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
            curCond(r).f   = permute(curCond(r).harm.f(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
        end
        res.harm{S,C} = cat(4,curCond.vec); % {sub x cond} [1 x vox x 1 x run]
        res.f{S,C}    = cat(4,curCond.f); % {sub x cond} [1 x vox x 1 x run]


        % Prediction from canonical HRF
        % load fit
        volFit = MRIload3(rCond{S}.(runCondAcq).(runCondStim).volActCat.afni.fFit,[],[],0);
        mri = [volTs.mri]; if length(unique([mri.nFrame]))>1; warning('XX'); end
        volFit = cpInfoDown(...
            rCond{S}.(runCondAcq).(runCondStim),...
            volFit);
        volFit.vol(:,:,:,volTs(1).mri.nFrame+1:end) = [];
        volFit.nframes = volTs(1).mri.nFrame;
        % perfrom mt spectral ana on canonical fit
        K     = 13;
        W     = [];
        win   = inf; % in seconds [lenght, step]
        extra = [];
        outField = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
        curCond = runFullMT3(volFit,W,K,win,[],[],vesselMask&fdrMask,extra,[],[],verboseThis,[],[])';
        % extract line power (harmonic signal amplitudes)
        for r = 1:size(curCond,1)
            curCond(r).vec = permute(curCond(r).harm.linePwr(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
            curCond(r).f   = permute(curCond(r).harm.f(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
        end
        res.harmCanon{S,C} = cat(4,curCond.vec); % {sub x cond} [1 x vox x 1 x run]
        % res.f{S,C}    = cat(4,curCond.f); % {sub x cond} [1 x vox x 1 x run]



    end
end

% Summarize
harm        = cell(length(rCond),length(runCondStimList_tmp));
harmAv      = cell(length(rCond),length(runCondStimList_tmp));
harmEr      = cell(length(rCond),length(runCondStimList_tmp));
harmCanon   = cell(length(rCond),length(runCondStimList_tmp));
harmCanonAv = cell(length(rCond),length(runCondStimList_tmp));
harmNrun    = cell(length(rCond),length(runCondStimList_tmp));
harmNvox    = cell(length(rCond),length(runCondStimList_tmp));
f           = cell(length(rCond),length(runCondStimList_tmp));
for S = 1:size(res.harm,1)
    for C = 1:size(res.harm,2)
        if ~isempty(res.harm{S,C})
            % average across voxels
            harm{S,C}      = mean(abs(res.harm{S,C}),2); % {sub x cond} [1 x 1 x 1 x run]
            % summarize across runs
            harmAv{S,C}    = mean(harm{S,C},4)    ; % {sub x cond} [1 x 1 x 1 x 1]
            harmEr{S,C}    = std(harm{S,C},[],4)  ; % {sub x cond} [1 x 1 x 1 x 1]
            harmNrun{S,C}  = size(harm{S,C},4)    ; % {sub x cond} [1 x 1 x 1 x 1]
            harmNvox{S,C}  = size(res.harm{S,C},2); % {sub x cond} [1 x 1 x 1 x 1]
            f{S,C}         = unique(res.f{S,C})   ; % {sub x cond}
            % similar for canonical prediction
            harmCanon{S,C}   = mean(abs(res.harmCanon{S,C}),2); % {sub x cond} [1 x 1 x 1 x run]
            harmCanonAv{S,C} = mean(harmCanon{S,C},4)    ; % {sub x cond} [1 x 1 x 1 x 1]
        else
            harm{S,C}     = nan;
            harmAv{S,C}   = nan;
            harmEr{S,C}   = nan;
            harmNrun{S,C} = nan;
            harmNvox{S,C} = nan;
            f{S,C}        = nan;
            harmCanon{S,C}   = nan;
            harmCanonAv{S,C} = nan;
        end
    end
end
harmAv   = flip(cell2mat(harmAv)  ,2);
harmEr   = flip(cell2mat(harmEr)  ,2);
harmNrun = flip(cell2mat(harmNrun),2);
harmNvox = flip(cell2mat(harmNvox),2);
f        = flip(cell2mat(f)       ,2);
harmCanonAv = flip(cell2mat(harmCanonAv),2);

fFreq = figure('WindowStyle','docked');
for S = 1:size(harmAv,1)
    ind = ~isnan(f(S,:));
    hErr(S) = errorbar(f(S,ind),harmAv(S,ind),harmEr(S,ind)./sqrt(harmNrun(S,ind))); hold on
    % text(f(S,ind),harmAv(S,ind),num2str(harmNvox(S,ind)'))
end
set(hErr,'CapSize',0,'Marker','o','MarkerFaceColor','w')
grid on
xlabel('Stimulus frequency (Hz)')
ylabel({'response at stimulus frequency' 'harmonic signal amplitude' '+/-SEM across runs or subjects'})
xLim = xlim; xLim(1) = 0; xlim(xLim)

%%% Group summary
harmAvNorm = harmAv - mean(harmAv,2,'omitmissing') + mean(mean(harmAv,2,'omitmissing'));
harmAvNormAv = mean(harmAvNorm,1,'omitmissing');
harmAvNormEr = std(harmAvNorm,[],1,'omitmissing');
harmAvNormN  = sum(~isnan(harmAvNorm));

% pool low frequencies
fOk = nan(1,size(f,2)); for metInd = 1:size(f,2); tmp = f(~isnan(f(:,metInd)),metInd); if ~isempty(tmp); fOk(metInd) = unique(tmp); end; end
harmAvNormLowFreq = harmAvNorm(:,fOk<0.05);
harmAvNormLowFreqN  = sum(~isnan(harmAvNormLowFreq(:)));
fAvNorm      = [mean(fOk(fOk<0.05))                          fOk(fOk>0.05)           ];
harmAvNormAv = [mean(harmAvNormLowFreq(:),1,'omitmissing')   harmAvNormAv(:,fOk>0.05)];
harmAvNormEr = [std(harmAvNormLowFreq(:),[],1,'omitmissing') harmAvNormEr(:,fOk>0.05)];
harmAvNormN  = [sum(~isnan(harmAvNormLowFreq(:)))            harmAvNormN(:,fOk>0.05) ];

% add to plot
hErGr = errorbar(fAvNorm(harmAvNormN>1),harmAvNormAv(harmAvNormN>1),harmAvNormEr(harmAvNormN>1)./sqrt(harmAvNormN(harmAvNormN>1)));
set(hErGr,'CapSize',0,'Marker','^','MarkerFaceColor','k','Color','k','MarkerEdgeColor','k','MarkerSize',10,'LineWidth',2)


%%% Canonical prediction
S = 1
% ind = ~isnan(f(S,:));
% hPred = plot(f(S,ind),harmCanonAv(S,ind),':*','Color',hErr(S).Color); hold on
% legend([hErr hErGr hPred],[subList; {'groupe mean'}; {'canonHRF'}],'box','off','AutoUpdate','off')

%%% Canonical prediction (equal stimulus model amplitude)
% !!!variable duty cycle (1% to 50%)!!!
S = 1;
% get average coef from task_50sPrd5sDur
C = ismember(runCondStimList_tmp,'task_50sPrd5sDur');
runCondStim = runCondStimList_tmp{C};
coef = MRIread(rCond{S}.(runCondAcq).(runCondStim).volActCat.fs.fCoef); coef = coef.vol;
coef = permute(coef,[4 1 2 3]);
coef = coef(:,allMask{S});
slp = coef(1,:)'\coef(2,:)';
slpPos = coef(1,coef(1,:)>0)'\coef(2,coef(1,:)>0)';
slpNeg = coef(1,coef(1,:)<0)'\coef(2,coef(1,:)<0)';
coefMod = [1 slp];
% figure('WindowStyle','docked');
% scatter(coef(1,:),coef(2,:),'MarkerEdgeColor','k'); hold on
% grid on
% hRef = refline(slp,0); hRef.Color = 'k';
% xLim = xlim;
% yLim = ylim;
% xx = [0 xLim(2)]; yy = xx.*slpPos;
% line(xx,yy,'color','r')
% xx = [xLim(1) 0]; yy = xx.*slpNeg;
% line(xx,yy,'color','b')

cMap = flip(turbo(size(res.f,2)),1);
figure('WindowStyle','docked');
fitTs = cell(1,length(runCondStimList_tmp));
hP    = cell(1,length(runCondStimList_tmp));
fX    = nan(1,length(runCondStimList_tmp));
for C = 1:length(runCondStimList_tmp)
    runCondStim = runCondStimList_tmp{C};
    if ~isfield(rCond{S}.(runCondAcq),runCondStim)
            % || strcmp(runCondStim,'task_50sPrd5sDur')
        continue
    end
    fFig = open(rCond{S}.(runCondAcq).(runCondStim).volActCat.afni.fMatFig);
    xMat = fFig.Children.Children.CData;
    close(fFig)
    rgr = xMat(logical(xMat(:,1)),end-1:end);
    fX(C)   = 1./mean(diff(rCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
    fX(C)   = 1./mean(diff(rCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
    fitTs{C}         = cpInfoDown(rCond{S}.(runCondAcq).(runCondStim),rCond{S}.(runCondAcq).(runCondStim).volTs(1));
    fitTs{C}.mri.vol = permute(rgr*coefMod',[2 3 4 1]);
    t = linspace(0,(fitTs{C}.mri.nFrame-1)*fitTs{C}.mri.tr/1000,fitTs{C}.mri.nFrame) + fitTs{C}.mri.nDummyRemoved*fitTs{C}.mri.tr/1000;
    hP{C} = plot(t,squeeze(fitTs{C}.mri.vol),'Color',cMap(C,:)); hold on

    K     = 13;
    W     = [];
    win   = inf; % in seconds [lenght, step]
    extra = [];
    outField = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
    curCond = runFullMT3(fitTs{C},W,K,win,[],[],[],extra,[],[],verboseThis,[],[])';
    % extract line power (harmonic signal amplitudes)
    for r = 1:size(curCond,1)
        curCond(r).vec = permute(curCond(r).harm.linePwr(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
        curCond(r).f   = permute(curCond(r).harm.f(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
    end
    res.harmCanon2{S,C} = cat(4,curCond.vec); % {sub x cond} [1 x vox x 1 x run]
end
set([hP{ismember(runCondStimList_tmp,{'task_05sPrd1sDur' 'task_10sPrd1sDur' 'task_50sPrd1sDur'})}],'LineWidth',3)
ind = isnan(fX);
fitTs(ind) = [];
fX(ind) = [];
hP(ind) = [];
legend([hP{:}],runCondStimList_tmp(~ind),'interpreter','none')
xlim([54 150])

figure(fFreq)
ind = ~cellfun('isempty',res.f(S,:));

fX = [];
harmCanon2 = [];
for C = 1:length(runCondStimList_tmp)
    if isempty(res.f{S,C}); continue; end
    fX         = [fX         res.f{S,C}(:,:,:,1)];
    harmCanon2 = [harmCanon2 res.harmCanon2{S,C}];
end
hPred2 = plot(fX,abs(harmCanon2)*35,'*:k')



%%% Canonical prediction (equal stimulus model amplitude)
% !!!fixed duty cycle (50%)!!!
S = 1;
% get average coef from task_50sPrd5sDur
C = ismember(runCondStimList_tmp,'task_50sPrd5sDur');
runCondStim = runCondStimList_tmp{C};
coef = MRIread(rCond{S}.(runCondAcq).(runCondStim).volActCat.fs.fCoef); coef = coef.vol;
coef = permute(coef,[4 1 2 3]);
coef = coef(:,allMask{S});
slp = coef(1,:)'\coef(2,:)';
slpPos = coef(1,coef(1,:)>0)'\coef(2,coef(1,:)>0)';
slpNeg = coef(1,coef(1,:)<0)'\coef(2,coef(1,:)<0)';
coefMod = [1 slp];
% figure('WindowStyle','docked');
% scatter(coef(1,:),coef(2,:),'MarkerEdgeColor','k'); hold on
% grid on
% hRef = refline(slp,0); hRef.Color = 'k';
% xLim = xlim;
% yLim = ylim;
% xx = [0 xLim(2)]; yy = xx.*slpPos;
% line(xx,yy,'color','r')
% xx = [xLim(1) 0]; yy = xx.*slpNeg;
% line(xx,yy,'color','b')

figure('WindowStyle','docked');
fitTs = cell(1,length(runCondStimList_tmp));
hP    = cell(1,length(runCondStimList_tmp));
fX    = nan(1,length(runCondStimList_tmp));
for C = 1:length(runCondStimList_tmp)
    runCondStim = runCondStimList_tmp{C};
    if ~isfield(rCond{S}.(runCondAcq),runCondStim)
            % || strcmp(runCondStim,'task_50sPrd5sDur')
        continue
    end
    
    fFig = open(xMatAlt{C});
    xMat = fFig.Children.Children.CData;
    close(fFig)
    rgr = xMat(logical(xMat(:,1)),end-1:end);
    fX(C)   = 1./mean(diff(rCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
    fX(C)   = 1./mean(diff(rCond{S}.(runCondAcq).(runCondStim).dsgn.onsetList));
    fitTs{C}         = cpInfoDown(rCond{S}.(runCondAcq).(runCondStim),rCond{S}.(runCondAcq).(runCondStim).volTs(1));
    fitTs{C}.mri.vol = permute(rgr*coefMod',[2 3 4 1]);
    t = linspace(0,(fitTs{C}.mri.nFrame-1)*fitTs{C}.mri.tr/1000,fitTs{C}.mri.nFrame) + fitTs{C}.mri.nDummyRemoved*fitTs{C}.mri.tr/1000;
    hP{C} = plot(t,squeeze(fitTs{C}.mri.vol),'Color',cMap(C,:)); hold on

    K     = 13;
    W     = [];
    win   = inf; % in seconds [lenght, step]
    extra = [];
    outField = ['volPsd_K' num2str(K) '_win' replace(num2str(win(1),'%0.1f'),'.','p')];
    curCond = runFullMT3(fitTs{C},W,K,win,[],[],[],extra,[],[],verboseThis,[],[])';
    % extract line power (harmonic signal amplitudes)
    for r = 1:size(curCond,1)
        curCond(r).vec = permute(curCond(r).harm.linePwr(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
        curCond(r).f   = permute(curCond(r).harm.f(:,:,:,:,1,:,:),[1 6 2 3 4 5 7]);
    end
    res.harmCanon3{S,C} = cat(4,curCond.vec); % {sub x cond} [1 x vox x 1 x run]
end
set([hP{ismember(runCondStimList_tmp,{'task_05sPrd1sDur' 'task_10sPrd1sDur' 'task_50sPrd1sDur'})}],'LineWidth',3)
ind = isnan(fX);
fitTs(ind) = [];
fX(ind) = [];
hP(ind) = [];
legend([hP{:}],runCondStimList_tmp(~ind),'interpreter','none','box','off')
xlim([54 150])

figure(fFreq)
ind = ~cellfun('isempty',res.f(S,:));

fX = [];
harmCanon3 = [];
for C = 1:length(runCondStimList_tmp)
    if isempty(res.f{S,C}); continue; end
    fX         = [fX         res.f{S,C}(:,:,:,1)];
    harmCanon3 = [harmCanon3 res.harmCanon3{S,C}];
end
hPred3 = plot(fX,abs(harmCanon3)*35,'sq-.k')
legend([hErr hErGr hPred2 hPred3],[subList; {'groupe mean'}; {'1sDur canonHRF prediction'}; {'50%dutyCycle canonHRF prediction'}],'box','off','AutoUpdate','off')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time-domain frequency-response prediction %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
verboseThis = 2;

runCondAcq          = runCondAcqList{  contains(runCondAcqList ,{'vfMRI'})           };
runCondStimList_tmp = runCondStimList(~contains(runCondStimList,{'task_eyeOpenRest'}));

% Compute
res.task           = cell(length(rCond),length(runCondStimList_tmp));
res.respPosArt     = cell(length(rCond),length(runCondStimList_tmp));
res.respNegArt     = cell(length(rCond),length(runCondStimList_tmp));
res.respPosVei     = cell(length(rCond),length(runCondStimList_tmp));
res.respNegVei     = cell(length(rCond),length(runCondStimList_tmp));
res.respPosArtSz = cell(length(rCond),length(runCondStimList_tmp));
res.respNegArtSz = cell(length(rCond),length(runCondStimList_tmp));
res.respPosVeiSz = cell(length(rCond),length(runCondStimList_tmp));
res.respNegVeiSz = cell(length(rCond),length(runCondStimList_tmp));
res.t              = cell(length(rCond),length(runCondStimList_tmp));
res.f              = cell(length(rCond),length(runCondStimList_tmp));
res.voxSelCond     = cell(length(rCond),1                          );
for S = 1:size(rCond,1)
    
    % Anatomical voxel selection / classification as vein or artery
    volLabel = MRIload3(rCond{S}.label.(runCondAcq).calcarineVessel.f,[],[],0);
    % artery -> 902
    % vein   -> 914
    % unkown -> 30 or 62
    vesMask = volLabel.vol~=0  ; % vessels (including ambiguous aartery vs vein identities)
    artMask = volLabel.vol==902; % arteries
    veiMask = volLabel.vol==914; % veins
    
    % Functional (SPM canon+deriv) voxel selection / classification 
    %%% selection condition 
    if isfield(rCond{S}.(runCondAcq),'task_50sPrd5sDur') && ~isempty(rCond{S}.(runCondAcq).task_50sPrd5sDur)
        curCond = rCond{S}.(runCondAcq).task_50sPrd5sDur;
    elseif isfield(rCond{S}.(runCondAcq),'task_50sPrd1sDur') && ~isempty(rCond{S}.(runCondAcq).task_50sPrd1sDur)
        % special case (vsmDrivenP3):
        % we don't have task_50sPrd5sDur for this subject, so
        % let's use task_50sPrd1sDur. Importantly, we must discard
        % task_50sPrd1sDur from the final analysis.
        curCond = rCond{S}.(runCondAcq).task_50sPrd1sDur;
        % or we just don't use any functional mask, allowing to keep the
        % task_50sPrd1sDur condition for the final analysis
        % % % % % % % % % curCond = [];
    else
        error('can''t find a condition for voxel selection' )
    end
    res.voxSelCond{S} = ['task_' curCond.label];

    pVal            = MRIread(curCond.volActCat.fs.fFullP); pVal = pVal.vol;
    fdrVal          = nan(size(pVal));
    fdrVal(vesMask) = mafdr(pVal(vesMask));
    
    amp = MRIread(curCond.volActCat.fs.fCoefPol); amp = amp.vol;
    % positively activated voxels 
    posMask = abs(amp(:,:,:,2))<pi/2; % & fdrVal<0.05;
    % negatively activated voxels
    negMask = abs(amp(:,:,:,2))>pi/2; % & fdrVal<0.05;
        


    % Extract response timecourses
    for C = 1:length(runCondStimList_tmp)
        runCondStim = runCondStimList_tmp{C};
        if ~isfield(rCond{S}.(runCondAcq),runCondStim) || isempty(rCond{S}.(runCondAcq).(runCondStim)) ...
                || strcmp(runCondStim,res.voxSelCond{S}) ...
                || strcmp(runCondStim,'task_50sPrd5sDur')
            % skip if condition does not exist
            % or if it was used for voxel selection/classification
            % or if it is the 5sDur condition
            continue
        end
        
        % load response ts
        curCond = rCond{S}.(runCondAcq).(runCondStim);
        mri = MRIread(curCond.volRespCat.fs.fRespTs);
        im = permute(mri.vol,[4 1 2 3]);
        res.task{S,C}       = curCond.label;
        res.respPosArt{S,C} = mean(im(:,posMask & artMask                        ),2);
        res.respNegArt{S,C} = mean(im(:,negMask & artMask                        ),2);
        res.respPosVei{S,C} = mean(im(:,posMask & veiMask                        ),2);
        res.respNegVei{S,C} = mean(im(:,negMask & veiMask                        ),2);
        res.respPosAmb{S,C} = mean(im(:,posMask & (vesMask & ~artMask & ~veiMask)),2);
        res.respNegAmb{S,C} = mean(im(:,negMask & (vesMask & ~artMask & ~veiMask)),2);

        
        res.respPosArtSz{S,C} = [size(im(:,posMask & artMask                        )) size(curCond.volTs,1)]; % T x Nvox x Nruns
        res.respNegArtSz{S,C} = [size(im(:,negMask & artMask                        )) size(curCond.volTs,1)];
        res.respPosVeiSz{S,C} = [size(im(:,posMask & veiMask                        )) size(curCond.volTs,1)];
        res.respNegVeiSz{S,C} = [size(im(:,negMask & veiMask                        )) size(curCond.volTs,1)];
        res.respPosAmb{S,C}   = [size(im(:,posMask & (vesMask & ~artMask & ~veiMask))) size(curCond.volTs,1)];
        res.respNegAmb{S,C}   = [size(im(:,negMask & (vesMask & ~artMask & ~veiMask))) size(curCond.volTs,1)];
        
        tr = mri.tr/1000;
        n  = mri.nframes;
        res.t{S,C} = linspace(0,tr*(n-1),n)';
        res.f{S,C} = 1/mean(diff(curCond.dsgn.onsetList)); % {sub x cond} [time x vox x 1 x run]
    end
end

for i = 1:numel(res.f)
    if isempty(res.f{i})
        res.f{i} = nan;
    end
end
res.f = cell2mat(res.f);

% Plot all
cMap = flip(turbo(size(res.f,2)),1);
voxClassList = {'PosArt' 'NegArt' 'PosVei' 'NegVei'};
fFig1  = cell(size(res.f,1));
ht1 = cell(size(res.f,1));
ax1 = cell(size(res.f,1),length(voxClassList));
f2  = cell(size(res.f,1));
ht2 = cell(size(res.f,1));
ax2 = cell(size(res.f,1),length(voxClassList));
for S = 1:size(res.f,1)
    fFig1{S} = figure('WindowStyle','docked');
    ht1{S} = tiledlayout(2,2); ht1{S,C}.Padding = 'tight'; ht1{S,C}.TileSpacing = 'tight';
    f2{S} = figure('WindowStyle','docked');
    ht2{S} = tiledlayout(2,2); ht2{S,C}.Padding = 'tight'; ht2{S,C}.TileSpacing = 'tight';
    for V = 1:length(voxClassList)
        voxClass = voxClassList{V};
        if all(cellfun('isempty',res.(['resp' voxClass])(S,:))) || all(isnan(cat(1,res.(['resp' voxClass]){S,:})))
            nexttile(ht1{S});
            nexttile(ht2{S});
            continue
        else
            ax1{S,V} = nexttile(ht1{S}); hold(ax1{S,V},'on');
            ax2{S,V} = nexttile(ht2{S}); hold(ax2{S,V},'on');
        end
        Cok = false(1,size(res.f,2));
        t = [];
        y = [];
        f = [];
        for C = 1:size(res.f,2)
            if ~isempty(res.(['resp' voxClass]){S,C}) && any(~isnan(res.(['resp' voxClass]){S,C}))
                plot(ax1{S,V},...
                    res.t{S,C},...
                    res.(['resp' voxClass]){S,C},...
                    'color',cMap(C,:));
                plot3(ax2{S,V},...
                    res.t{S,C},...
                    repmat(res.f(S,C),size(res.t{S,C})),...
                    res.(['resp' voxClass]){S,C},...
                    'color',cMap(C,:)); hold on
                Cok(1,C) = true;
                % t = [t; res.t{S,C}];
                % y = [y; res.(['resp' voxClass]){S,C}];
                % f = [f; repmat(res.f(S,C),size(res.(['resp' voxClass]){S,C}))];
            end
        end
        grid(ax1{S,V},'on')
        grid(ax2{S,V},'on')
        axis(ax1{S,V},'tight')
        axis(ax2{S,V},'tight')
        sz = cell2mat(res.(['resp' voxClass 'Sz'])(S,:)');
        if V==2
            legend(ax1{S,V},...
                strcat(res.task(S,Cok)','; nRun=', cellstr(num2str(sz(:,3)))),...
                'AutoUpdate','off','Box','off');
            legend(ax2{S,V},...
                strcat(res.task(S,Cok)','; nRun=', cellstr(num2str(sz(:,3)))),...
                'AutoUpdate','off','Box','off');
        end
        title(ax1{S,V},[subList{S} '; nVox=' num2str(sz(1,2)) '; ' voxClass])
        title(ax2{S,V},[subList{S} '; nVox=' num2str(sz(1,2)) '; ' voxClass])
        uistack(yline(ax1{S,V},0),'bottom');


        % plot3
        % [T,F] = meshgrid(linspace(min(t),max(t),10),linspace(min(f),max(f),10))
        % Y = interp2(t,f,y,T(:),F(:));
        % surf(t,f,y)
        
        xlabel(ax2{S,V},'time (s)')
        ylabel(ax2{S,V},'stim freq (Hz)')
        zlabel(ax2{S,V},'MR signal change (a.u.)')
    end
    set([ax2{S,:}],'view',[-15 20]);

    yLim1{S} = get([ax1{S,:}],'ylim'); yLim1{S} = [-1 1].*max(abs([yLim1{S}{:}])); set([ax1{S,:}],'ylim',yLim1{S});
    zLim2{S} = get([ax2{S,:}],'zlim'); zLim2{S} = [-1 1].*max(abs([zLim2{S}{:}])); set([ax2{S,:}],'zlim',zLim2{S});
end
drawnow
xLim1 = get([ax1{:}],'xlim'); xLim1 = [min([xLim1{:}]) max([xLim1{:}])]; set([ax1{:}],'xlim',xLim1);
xLim2 = get([ax2{:}],'xlim'); xLim2 = [min([xLim2{:}]) max([xLim2{:}])]; set([ax2{:}],'xlim',xLim2);
yLim2 = get([ax2{:}],'ylim'); yLim2 = [min([yLim2{:}]) max([yLim2{:}])]; set([ax2{:}],'ylim',yLim2);



% Group summary
for V = 1:length(voxClassList)
    voxClass = voxClassList{V};
    % number of tPts
    if iscell(res.(['resp' voxClass 'Sz'])) % -> S x C x [Nt Nvox Nrun]
        res.(['resp' voxClass 'Sz'])(cellfun('isempty',res.(['resp' voxClass 'Sz']))) = {[nan nan nan]};
        res.(['resp' voxClass 'Sz']) = permute(cell2mat(permute(res.(['resp' voxClass 'Sz']),[1 3 2])),[1 3 2]);
    end
    for C = 1:size(res.f,2)
        ind = ~isnan(res.(['resp' voxClass 'Sz'])(:,C,1));
        if any(ind)
            res.(['resp' voxClass 'Sz'])(:,C,1) = unique(res.(['resp' voxClass 'Sz'])(ind,C,1))
        end
    end
    % number of runs
    for S = 1:size(res.f,1)
        for C = 1:size(res.f,2)
            if isnan(res.f(S,C))
                res.(['resp' voxClass 'Sz'])(S,C,3) = 0;
            end
        end
    end
    % number of voxels
    tmp = res.(['resp' voxClass 'Sz'])(:,:,2);
    ind = isnan(res.(['resp' voxClass 'Sz'])(:,:,2)) & res.(['resp' voxClass 'Sz'])(:,:,3)~=0;
    tmp(ind) = 0;
    res.(['resp' voxClass 'Sz'])(:,:,2) = tmp;
end
% Normalize according to std of response from condition 10s since it was acquired in all subject
Cnorm = ismember(runCondStimList_tmp,'task_10sPrd1sDur');
normFac = [];
for S = 1:size(res.f,1)
    rStd = [];
    nVox = [];
    for V = 1:length(voxClassList)
        voxClass = voxClassList{V};
        rStd(V) = std(res.(['resp' voxClass]){S,Cnorm});
        nVox(V) = res.(['resp' voxClass 'Sz'])(S,Cnorm,2);
    end
    normFac(S,1) = sum(rStd.*nVox,'omitmissing')./sum(nVox);
end
res.normFac = normFac./mean(normFac);
% Plot all conditions
f3 = figure('WindowStyle','docked');
ht3 = tiledlayout(2,2); ht3.Padding = 'tight'; ht3.TileSpacing = 'tight';
nSub = zeros(1              ,size(res.f,2),length(voxClassList));
nRun = zeros(length(subList),size(res.f,2),length(voxClassList));
nVox = zeros(length(subList),size(res.f,2),length(voxClassList));
for V = 1:length(voxClassList)
    voxClass = voxClassList{V};
    ax3{V} = nexttile(ht3); hold(ax3{V},'on');
    Cok = false(1,size(res.f,2));
    for C = 1:size(res.f,2)
        if all(isnan(res.f(:,C))); continue; end
        Cok(C) = true;
        ind  = ~cellfun('isempty',res.(['resp' voxClass])(:,C));
        resp = cell2mat(res.(['resp' voxClass])(ind,C)')' ./ res.normFac(ind);
        t    = cell2mat(res.t(ind,C)')';
        nSub(1,C,V) = nnz(ind);
        nRun(ind,C,V) = res.(['resp' voxClass 'Sz'])(ind,C,3);
        nVox(ind,C,V) = res.(['resp' voxClass 'Sz'])(ind,C,2);

        respAv = mean(resp,1,'omitmissing');
        if nSub(1,C,V)==1
            respEr = zeros(size(resp));
        else
            respEr = std(resp,[],1,'omitmissing') ./ sqrt(nSub(1,C,V));
        end
        t = t(1,:)
        hEr{1,C,V} = errorbar(t,respAv,respEr,'color',cMap(C,:))
    end
    if V==2
        tmp = replace(runCondStimList_tmp,'task_','')
        legend(ax3{1,V},...
            tmp(Cok)',...
            'AutoUpdate','off','Box','off','interpreter','none','location','southeast');
    end
end
set([hEr{:}],'CapSize',0)
set([ax3{:}],'XLim',[0 20])
grid([ax3{:}],'on')
yLim = get([ax3{:}],'YLim'); set([ax3{:}],'YLim',[-1 1].*max(abs([yLim{:}])));
% Plot 3 conditions
fFlag = 0; % for a 3D render
f4 = figure('WindowStyle','docked');
ht4 = tiledlayout(2,2); ht4.Padding = 'tight'; ht4.TileSpacing = 'tight';
nSub = zeros(1              ,size(res.f,2),length(voxClassList));
nRun = zeros(length(subList),size(res.f,2),length(voxClassList));
nVox = zeros(length(subList),size(res.f,2),length(voxClassList));
hEr = [];
for V = 1:length(voxClassList)
    voxClass = voxClassList{V};
    ax4{V} = nexttile(ht4); hold(ax4{V},'on');
    
    ismember(runCondStimList_tmp,{'task_10sPrd1sDur' 'task_15sPrd1sDur' 'task_20sPrd1sDur' 'task_30sPrd1sDur'});
    
    taskList = {{'task_10sPrd1sDur'} {'task_15sPrd1sDur'} {'task_20sPrd1sDur' 'task_30sPrd1sDur'}}
    for Cx = 1:length(taskList)
        Cok = ismember(runCondStimList_tmp,taskList{Cx});
        % Cok = ismember(runCondStimList_tmp,{'task_20sPrd1sDur' 'task_30sPrd1sDur'});
        % Cok = ismember(runCondStimList_tmp,{'task_10sPrd1sDur'});
        % res.(['resp' voxClass])(:,Cok);
        clear resp
        clear t
        clear f
        for S = 1:size(res.f,1)
            tmp       = res.(['resp' voxClass])(S,Cok);
            ind = ~cellfun('isempty',tmp);
            if nnz(Cok)>1
                resp(S,:) = tmp{ind}(1:24);
            else
                resp(S,:) = tmp{ind};
            end
            tmp       = res.t(S,Cok);
            if nnz(Cok)>1
                t(S,:)    = tmp{ind}(1:24);
            else
                t(S,:)    = tmp{ind};
            end
            tmp       = res.f(S,Cok);
            f(S,1) = tmp(~isnan(tmp));
        end
        
        % resp = resp./res.normFac;

        ind = any(isnan(resp),2);
        resp(ind,:) = [];
        t(ind,:)    = [];
        respAv = mean(resp,1);
        respEr = std(resp,[],1) ./ sqrt(size(resp,1));
        t      = t(1,:)
        f      = f(1,:);
        if ~fFlag
            hEr{1,Cx,V} = errorbar(t,respAv,respEr,'color',mean(cMap(Cok,:),1));
        else
            plot3(t,repmat(f,size(t)),respAv,'color',mean(cMap(Cok,:),1));
        end
    end
    if fFlag
        set([ax4{V}],'view',[-15 20]);
    end
    axis tight
    if V==2
        legend(ax4{1,V},...
            {'period=10s' 'period=15s' 'period=20s/30s'},...
            'AutoUpdate','off','Box','off','interpreter','none','location','southeast');
    end
    xlabel('time since stimulus onset (s)')
    if fFlag
        ylabel('stimulus frquency (Hz)')
        zlabel('MR signal change (a.u.) mean+/-sem across subject')
    else
        ylabel('MR signal change (a.u.) mean+/-sem across subject')
    end
    title(voxClass)
end
title(ht4,'group average')
if ~fFlag
    set([hEr{:}],'CapSize',0);
end
grid([ax4{:}],'on')
xLim = get([ax4{:}],'XLim'); xLim = [xLim{:}]; xLim = [min(xLim) max(xLim)];
set([ax4{:}],'XLim',xLim)
if ~fFlag
    yLim = get([ax4{:}],'YLim'); yLim = [-1 1].*max(abs([yLim{:}]));
    set([ax4{:}],'YLim',yLim);
else
    yLim = get([ax4{:}],'YLim'); yLim = [yLim{:}]; yLim = [min(yLim) max(yLim)];
    set([ax4{:}],'YLim',yLim)
    zLim = get([ax4{:}],'ZLim'); zLim = [-1 1].*max(abs([zLim{:}]));
    set([ax4{:}],'ZLim',zLim);

    for V = 1:length(voxClassList)
        plot3([ax4{V}],xLim([1 2 2 1 1]),yLim([1 1 2 2 1]),[0 0 0 0 0],'k')
    end
end
% set([ax4{:}],'YLim',[-1 1].*35);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return

%%%%%%%%%%%%%
%% Ringing %%
%%%%%%%%%%%%%
verboseThis = 2;

runCondAcq  = runCondAcqList {contains(runCondAcqList ,'vfMRI')           };
runCondStim = runCondStimList{contains(runCondStimList,'task_50sPrd5sDur')};
res = [];

for S = 1:size(rCond,1)
    if ~isfield(rCond{S}.(runCondAcq),runCondStim); continue; end
    curCond = rCond{S}.(runCondAcq).(runCondStim);
    
    % Anatomical voxel selection / classification as vein or artery
    volLabel = MRIload3(rCond{S}.label.(runCondAcq).calcarineVessel.f,[],[],0);
    % artery -> 902
    % vein   -> 914
    % unkown -> 30 or 62
    vesMask = volLabel.vol~=0  ; % vessels (including ambiguous aartery vs vein identities)
    artMask = volLabel.vol==902; % arteries
    veiMask = volLabel.vol==914; % veins
    
    % Functional (SPM canon+deriv) voxel selection / classification 
    %%% selection condition 
    pVal            = MRIread(curCond.volActCat.fs.fFullP); pVal = pVal.vol;
    fdrVal          = nan(size(pVal));
    fdrVal(vesMask) = mafdr(pVal(vesMask));
    
    amp = MRIread(curCond.volActCat.fs.fCoefPol); amp = amp.vol;
    % positively activated voxels 
    posMask = abs(amp(:,:,:,2))<pi/2; % & fdrVal<0.05;
    % negatively activated voxels
    negMask = abs(amp(:,:,:,2))>pi/2; % & fdrVal<0.05;
        


    % Extract response timecourses
    % load response ts
    R = 1;
    mri = MRIread(curCond.volRespCat.fs.fRespTs);
    im = permute(mri.vol,[4 1 2 3]);
    res.task{S}{R}       = curCond.label;
    res.respPosArt{S}{R} = mean(im(:,posMask & artMask                         & fdrVal<0.05),2);
    res.respNegArt{S}{R} = mean(im(:,negMask & artMask                         & fdrVal<0.05),2);
    res.respPosVei{S}{R} = mean(im(:,posMask & veiMask                         & fdrVal<0.05),2);
    res.respNegVei{S}{R} = mean(im(:,negMask & veiMask                         & fdrVal<0.05),2);
    res.respPosAmb{S}{R} = mean(im(:,posMask & (vesMask & ~artMask & ~veiMask) & fdrVal<0.05),2);
    res.respNegAmb{S}{R} = mean(im(:,negMask & (vesMask & ~artMask & ~veiMask) & fdrVal<0.05),2);

    tr = mri.tr/1000;
    n  = mri.nframes;
    res.t{S}{R}   = linspace(0,tr*(n-1),n)';
    res.sub{S}{R} = curCond.sub;
end


voxClassList = {'PosArt' 'NegArt' 'PosVei' 'NegVei'};
fFig  = cell(size(res.sub,1));
ht    = cell(size(res.sub,1));
ax    = cell(size(res.sub,1),length(voxClassList));
skipV = false(size(res.sub,2),length(voxClassList));
for S = 1:length(res.sub)
    if isempty(res.sub{S}); skipV(S,:) = true; continue; end
    fFig{S} = figure('WindowStyle','docked');
    ht{S} = tiledlayout(2,2); ht{S}.Padding = 'tight'; ht{S}.TileSpacing = 'tight';
    for V = 1:length(voxClassList)
        voxClass = voxClassList{V};
        t = res.t{S}{R};
        y = res.(['resp' voxClass]){S}{R};
        if isempty(y) || all(isnan(y))
            skipV(S,V) = true;
            nexttile(ht{S}); continue
        else
            ax{S,V} = nexttile(ht{S}); hold(ax{S,V},'on');
        end
        plot(t,y); axis tight
        grid on
        grid minor
        title(voxClass)
    end
    title(ht{S},res.sub{S}{R})
end
yLim = get([ax{~skipV}],'YLim');
yLim = [-1 1].*max(abs([yLim{:}]));
set([ax{~skipV}],'YLim',yLim);


findobj([axX.Children],'line')
get([ax{~cellfun('isempty',ax)}],'XLim')


for i = 1:numel(res.f)
    if isempty(res.f{i})
        res.f{i} = nan;
    end
end
res.f = cell2mat(res.f);

% Plot all
cMap = flip(turbo(size(res.f,2)),1);
voxClassList = {'PosArt' 'NegArt' 'PosVei' 'NegVei'};
fFig1  = cell(size(res.f,1));
ht1 = cell(size(res.f,1));
ax1 = cell(size(res.f,1),length(voxClassList));
f2  = cell(size(res.f,1));
ht2 = cell(size(res.f,1));
ax2 = cell(size(res.f,1),length(voxClassList));
for S = 1:size(res.f,1)
    fFig1{S} = figure('WindowStyle','docked');
    ht1{S} = tiledlayout(2,2); ht1{S,C}.Padding = 'tight'; ht1{S,C}.TileSpacing = 'tight';
    f2{S} = figure('WindowStyle','docked');
    ht2{S} = tiledlayout(2,2); ht2{S,C}.Padding = 'tight'; ht2{S,C}.TileSpacing = 'tight';
    for V = 1:length(voxClassList)
        voxClass = voxClassList{V};
        if all(cellfun('isempty',res.(['resp' voxClass])(S,:))) || all(isnan(cat(1,res.(['resp' voxClass]){S,:})))
            nexttile(ht1{S});
            nexttile(ht2{S});
            continue
        else
            ax1{S,V} = nexttile(ht1{S}); hold(ax1{S,V},'on');
            ax2{S,V} = nexttile(ht2{S}); hold(ax2{S,V},'on');
        end
        Cok = false(1,size(res.f,2));
        t = [];
        y = [];
        f = [];
        for C = 1:size(res.f,2)
            if ~isempty(res.(['resp' voxClass]){S,C}) && any(~isnan(res.(['resp' voxClass]){S,C}))
                plot(ax1{S,V},...
                    res.t{S,C},...
                    res.(['resp' voxClass]){S,C},...
                    'color',cMap(C,:));
                plot3(ax2{S,V},...
                    res.t{S,C},...
                    repmat(res.f(S,C),size(res.t{S,C})),...
                    res.(['resp' voxClass]){S,C},...
                    'color',cMap(C,:)); hold on
                Cok(1,C) = true;
                % t = [t; res.t{S,C}];
                % y = [y; res.(['resp' voxClass]){S,C}];
                % f = [f; repmat(res.f(S,C),size(res.(['resp' voxClass]){S,C}))];
            end
        end
        grid(ax1{S,V},'on')
        grid(ax2{S,V},'on')
        axis(ax1{S,V},'tight')
        axis(ax2{S,V},'tight')
        sz = cell2mat(res.(['resp' voxClass 'Sz'])(S,:)');
        if V==2
            legend(ax1{S,V},...
                strcat(res.task(S,Cok)','; nRun=', cellstr(num2str(sz(:,3)))),...
                'AutoUpdate','off','Box','off');
            legend(ax2{S,V},...
                strcat(res.task(S,Cok)','; nRun=', cellstr(num2str(sz(:,3)))),...
                'AutoUpdate','off','Box','off');
        end
        title(ax1{S,V},[subList{S} '; nVox=' num2str(sz(1,2)) '; ' voxClass])
        title(ax2{S,V},[subList{S} '; nVox=' num2str(sz(1,2)) '; ' voxClass])
        uistack(yline(ax1{S,V},0),'bottom');


        % plot3
        % [T,F] = meshgrid(linspace(min(t),max(t),10),linspace(min(f),max(f),10))
        % Y = interp2(t,f,y,T(:),F(:));
        % surf(t,f,y)
        
        xlabel(ax2{S,V},'time (s)')
        ylabel(ax2{S,V},'stim freq (Hz)')
        zlabel(ax2{S,V},'MR signal change (a.u.)')
    end
    set([ax2{S,:}],'view',[-15 20]);

    yLim1{S} = get([ax1{S,:}],'ylim'); yLim1{S} = [-1 1].*max(abs([yLim1{S}{:}])); set([ax1{S,:}],'ylim',yLim1{S});
    zLim2{S} = get([ax2{S,:}],'zlim'); zLim2{S} = [-1 1].*max(abs([zLim2{S}{:}])); set([ax2{S,:}],'zlim',zLim2{S});
end
drawnow
xLim1 = get([ax1{:}],'xlim'); xLim1 = [min([xLim1{:}]) max([xLim1{:}])]; set([ax1{:}],'xlim',xLim1);
xLim2 = get([ax2{:}],'xlim'); xLim2 = [min([xLim2{:}]) max([xLim2{:}])]; set([ax2{:}],'xlim',xLim2);
yLim2 = get([ax2{:}],'ylim'); yLim2 = [min([yLim2{:}]) max([yLim2{:}])]; set([ax2{:}],'ylim',yLim2);



% Group summary
for V = 1:length(voxClassList)
    voxClass = voxClassList{V};
    % number of tPts
    if iscell(res.(['resp' voxClass 'Sz'])) % -> S x C x [Nt Nvox Nrun]
        res.(['resp' voxClass 'Sz'])(cellfun('isempty',res.(['resp' voxClass 'Sz']))) = {[nan nan nan]};
        res.(['resp' voxClass 'Sz']) = permute(cell2mat(permute(res.(['resp' voxClass 'Sz']),[1 3 2])),[1 3 2]);
    end
    for C = 1:size(res.f,2)
        ind = ~isnan(res.(['resp' voxClass 'Sz'])(:,C,1));
        if any(ind)
            res.(['resp' voxClass 'Sz'])(:,C,1) = unique(res.(['resp' voxClass 'Sz'])(ind,C,1))
        end
    end
    % number of runs
    for S = 1:size(res.f,1)
        for C = 1:size(res.f,2)
            if isnan(res.f(S,C))
                res.(['resp' voxClass 'Sz'])(S,C,3) = 0;
            end
        end
    end
    % number of voxels
    tmp = res.(['resp' voxClass 'Sz'])(:,:,2);
    ind = isnan(res.(['resp' voxClass 'Sz'])(:,:,2)) & res.(['resp' voxClass 'Sz'])(:,:,3)~=0;
    tmp(ind) = 0;
    res.(['resp' voxClass 'Sz'])(:,:,2) = tmp;
end
% Normalize according to std of response from condition 10s since it was acquired in all subject
Cnorm = ismember(runCondStimList_tmp,'task_10sPrd1sDur');
normFac = [];
for S = 1:size(res.f,1)
    rStd = [];
    nVox = [];
    for V = 1:length(voxClassList)
        voxClass = voxClassList{V};
        rStd(V) = std(res.(['resp' voxClass]){S,Cnorm});
        nVox(V) = res.(['resp' voxClass 'Sz'])(S,Cnorm,2);
    end
    normFac(S,1) = sum(rStd.*nVox,'omitmissing')./sum(nVox);
end
res.normFac = normFac./mean(normFac);
% Plot all conditions
f3 = figure('WindowStyle','docked');
ht3 = tiledlayout(2,2); ht3.Padding = 'tight'; ht3.TileSpacing = 'tight';
nSub = zeros(1              ,size(res.f,2),length(voxClassList));
nRun = zeros(length(subList),size(res.f,2),length(voxClassList));
nVox = zeros(length(subList),size(res.f,2),length(voxClassList));
for V = 1:length(voxClassList)
    voxClass = voxClassList{V};
    ax3{V} = nexttile(ht3); hold(ax3{V},'on');
    Cok = false(1,size(res.f,2));
    for C = 1:size(res.f,2)
        if all(isnan(res.f(:,C))); continue; end
        Cok(C) = true;
        ind  = ~cellfun('isempty',res.(['resp' voxClass])(:,C));
        resp = cell2mat(res.(['resp' voxClass])(ind,C)')' ./ res.normFac(ind);
        t    = cell2mat(res.t(ind,C)')';
        nSub(1,C,V) = nnz(ind);
        nRun(ind,C,V) = res.(['resp' voxClass 'Sz'])(ind,C,3);
        nVox(ind,C,V) = res.(['resp' voxClass 'Sz'])(ind,C,2);

        respAv = mean(resp,1,'omitmissing');
        if nSub(1,C,V)==1
            respEr = zeros(size(resp));
        else
            respEr = std(resp,[],1,'omitmissing') ./ sqrt(nSub(1,C,V));
        end
        t = t(1,:)
        hEr{1,C,V} = errorbar(t,respAv,respEr,'color',cMap(C,:))
    end
    if V==2
        tmp = replace(runCondStimList_tmp,'task_','')
        legend(ax3{1,V},...
            tmp(Cok)',...
            'AutoUpdate','off','Box','off','interpreter','none','location','southeast');
    end
end
set([hEr{:}],'CapSize',0)
set([ax3{:}],'XLim',[0 20])
grid([ax3{:}],'on')
yLim = get([ax3{:}],'YLim'); set([ax3{:}],'YLim',[-1 1].*max(abs([yLim{:}])));
% Plot 3 conditions
fFlag = 0; % for a 3D render
f4 = figure('WindowStyle','docked');
ht4 = tiledlayout(2,2); ht4.Padding = 'tight'; ht4.TileSpacing = 'tight';
nSub = zeros(1              ,size(res.f,2),length(voxClassList));
nRun = zeros(length(subList),size(res.f,2),length(voxClassList));
nVox = zeros(length(subList),size(res.f,2),length(voxClassList));
hEr = [];
for V = 1:length(voxClassList)
    voxClass = voxClassList{V};
    ax4{V} = nexttile(ht4); hold(ax4{V},'on');
    
    ismember(runCondStimList_tmp,{'task_10sPrd1sDur' 'task_15sPrd1sDur' 'task_20sPrd1sDur' 'task_30sPrd1sDur'});
    
    taskList = {{'task_10sPrd1sDur'} {'task_15sPrd1sDur'} {'task_20sPrd1sDur' 'task_30sPrd1sDur'}}
    for Cx = 1:length(taskList)
        Cok = ismember(runCondStimList_tmp,taskList{Cx});
        % Cok = ismember(runCondStimList_tmp,{'task_20sPrd1sDur' 'task_30sPrd1sDur'});
        % Cok = ismember(runCondStimList_tmp,{'task_10sPrd1sDur'});
        % res.(['resp' voxClass])(:,Cok);
        clear resp
        clear t
        clear f
        for S = 1:size(res.f,1)
            tmp       = res.(['resp' voxClass])(S,Cok);
            ind = ~cellfun('isempty',tmp);
            if nnz(Cok)>1
                resp(S,:) = tmp{ind}(1:24);
            else
                resp(S,:) = tmp{ind};
            end
            tmp       = res.t(S,Cok);
            if nnz(Cok)>1
                t(S,:)    = tmp{ind}(1:24);
            else
                t(S,:)    = tmp{ind};
            end
            tmp       = res.f(S,Cok);
            f(S,1) = tmp(~isnan(tmp));
        end
        
        % resp = resp./res.normFac;

        ind = any(isnan(resp),2);
        resp(ind,:) = [];
        t(ind,:)    = [];
        respAv = mean(resp,1);
        respEr = std(resp,[],1) ./ sqrt(size(resp,1));
        t      = t(1,:)
        f      = f(1,:);
        if ~fFlag
            hEr{1,Cx,V} = errorbar(t,respAv,respEr,'color',mean(cMap(Cok,:),1));
        else
            plot3(t,repmat(f,size(t)),respAv,'color',mean(cMap(Cok,:),1));
        end
    end
    if fFlag
        set([ax4{V}],'view',[-15 20]);
    end
    axis tight
    if V==2
        legend(ax4{1,V},...
            {'period=10s' 'period=15s' 'period=20s/30s'},...
            'AutoUpdate','off','Box','off','interpreter','none','location','southeast');
    end
    xlabel('time since stimulus onset (s)')
    if fFlag
        ylabel('stimulus frquency (Hz)')
        zlabel('MR signal change (a.u.) mean+/-sem across subject')
    else
        ylabel('MR signal change (a.u.) mean+/-sem across subject')
    end
    title(voxClass)
end
title(ht4,'group average')
if ~fFlag
    set([hEr{:}],'CapSize',0);
end
grid([ax4{:}],'on')
xLim = get([ax4{:}],'XLim'); xLim = [xLim{:}]; xLim = [min(xLim) max(xLim)];
set([ax4{:}],'XLim',xLim)
if ~fFlag
    yLim = get([ax4{:}],'YLim'); yLim = [-1 1].*max(abs([yLim{:}]));
    set([ax4{:}],'YLim',yLim);
else
    yLim = get([ax4{:}],'YLim'); yLim = [yLim{:}]; yLim = [min(yLim) max(yLim)];
    set([ax4{:}],'YLim',yLim)
    zLim = get([ax4{:}],'ZLim'); zLim = [-1 1].*max(abs([zLim{:}]));
    set([ax4{:}],'ZLim',zLim);

    for V = 1:length(voxClassList)
        plot3([ax4{V}],xLim([1 2 2 1 1]),yLim([1 1 2 2 1]),[0 0 0 0 0],'k')
    end
end
% set([ax4{:}],'YLim',[-1 1].*35);


%% %%%%%%%%%%
return


%% %%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualize Individual Runs  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = 1;
runCondAcq  = runCondAcqList{ contains(runCondAcqList ,'vfMRI'  )};
runCondStim = runCondStimList{contains(runCondStimList,'task_50sPrd5sDur')};


r = 1
volResp     = rCond{S}.(runCondAcq).(runCondStim).volRespCat;
volAct      = rCond{S}.(runCondAcq).(runCondStim).volActCat;
volTs       = rCond{S}.(runCondAcq).(runCondStim).volTs(r);
dsgn        = rCond{S}.(runCondAcq).(runCondStim).dsgn;
mask        = rCond{S}.label.vfMRI.calcarineVessel.f;

close all
volPsd  = rCond{S}.(runCondAcq).(runCondStim).volPsd_K5_win20(r);
[volPsd,volTs,volResp,volAct] = plotSpecAll3(volPsd,volTs,volResp,volAct,dsgn,mask,[],0.05)
volPsd  = rCond{S}.(runCondAcq).(runCondStim).volPsd_K10_win20(r);
[volPsd,volTs,volResp,volAct] = plotSpecAll3(volPsd,volTs,volResp,volAct,dsgn,mask,[],0.05)
volPsd  = rCond{S}.(runCondAcq).(runCondStim).volPsd_K15_win20(r);
[volPsd,volTs,volResp,volAct] = plotSpecAll3(volPsd,volTs,volResp,volAct,dsgn,mask,[],0.05)

return


for r = 1:length(volPsd)
    tryL2svd(volPsd(r))
    plotSpecAll2(volPsd(r),volTs(r),volResp(r),volTs(r).dsgn,volAnat.roi{roiInd}.f,[],0.05)
end

for r = 1:length(volPsd)
    plotSpecAll2(volPsd(r),volTs(r),volResp(r),volTs(r).dsgn,volAnat.roi{roiInd}.f,[],0.05)

    figure('WindowStyle','docked');
    winInd = 1;
    volPsd(r).psdTrialGramMD.t(:,1,1,1,1,1,winInd)
    f = squeeze(volPsd(r).psdTrialGramMD.f);
    psd = squeeze(mean(volPsd(r).psdTrialGramMD.vec.psdPC(:,:,:,:,:,:,winInd),6));
    plot(f,psd);
    set(gca,'YScale','log')
    grid on; grid minor
    hold on

    winInd = round(size(volPsd(r).psdTrialGramMD.t,7)/2);
    volPsd(r).psdTrialGramMD.t(:,1,1,1,1,1,winInd)
    f = squeeze(volPsd(r).psdTrialGramMD.f);
    psd = squeeze(mean(volPsd(r).psdTrialGramMD.vec.psdPC(:,:,:,:,:,:,winInd),6));
    plot(f,psd);

    winInd = size(volPsd(r).psdTrialGramMD.t,7);
    volPsd(r).psdTrialGramMD.t(:,1,1,1,1,1,winInd)
    f = squeeze(volPsd(r).psdTrialGramMD.f);
    psd = squeeze(mean(volPsd(r).psdTrialGramMD.vec.psdPC(:,:,:,:,:,:,winInd),6));
    plot(f,psd);

    legend({'early' 'mid' 'late'})
    ax = gca;
    yLim = get(ax.Children,'YData'); yLim = min(cat(1,yLim{:}),[],1); yLim = min(yLim(f>0.05)); tmp = ylim; yLim(2) = tmp(2); ylim(yLim);
end

return

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%
%% Freeview %%
%%%%%%%%%%%%%%

S = 1;
rCond{S};
popp2(sesPhys{end})

5
S = 1;
curDir = rCond{S}.vfMRI.task_50sPrd5sDur.wd{1};
dir(fullfile(curDir,'sub-vsmDrivenP1_ses-1_task-50sPrd5sDur_run-*_angio','*'))
derivDir = '/autofs/space/takoyaki_001/users/proulxs/vsmDriven/doIt_vsmDriven4/bids/sub-vsmDrivenP1/ses-1/derivatives/set-vfMRI';


cmd = {srcFs};
cmd{end+1} = 'freeview \';
tmp = fullfile('/autofs/space/takoyaki_001/users/proulxs/vsmDriven/doIt_vsmDriven4/bids/sub-vsmDrivenP1/ses-1/derivatives/set-vfMRI/sub-vsmDrivenP1_ses-1_task-50sPrd5sDur_run-av_angio',...
    'cond-visOn_base.nii.gz');
cmd{end+1} = [tmp ' \'];
tmp = fullfile('/autofs/space/takoyaki_001/users/proulxs/vsmDriven/doIt_vsmDriven4/bids/sub-vsmDrivenP1/ses-1/derivatives/set-vfMRI/sub-vsmDrivenP1_ses-1_task-50sPrd5sDur_run-av_angio',...
    'cond-visOn_resp.nii.gz');
cmd{end+1} = [tmp ' \'];
tmp = fullfile('/autofs/space/takoyaki_001/users/proulxs/vsmDriven/doIt_vsmDriven4/bids/sub-vsmDrivenP1/ses-1/derivatives/set-vfMRI/sub-vsmDrivenP1_ses-1_task-50sPrd5sDur_run-av_angio',...
    'cond-visOn_respF.nii.gz');
cmd{end+1} = [tmp ':colormap=heat'];
clipboard("copy",strjoin(cmd,newline))

dir(tmp)
%% %%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PPG to brain vessel coherence %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S = 1;
r = 1;
volTs = rCond{S}.vfMRI.task_50sPrd5sDur.volTs(r).mri;
Fstim = 1/mean(diff(rCond{S}.vfMRI.task_50sPrd5sDur.dsgn.onsetList));
volTs = MRIload2(volTs);
physTs = rCond{S}.vfMRI.task_50sPrd5sDur.phys(r);

% volAnat = runCond{S}.vfMRI.task_50sPrd5sDur.volAnatSub
% roi = [volAnat.roi{:}];
% ind = ismember({roi.label},'vesselCalcarineRoi01a');

% volTs = vol2vec(volTs,volAnat.roi{ind}.f,1)
fMask = '/autofs/space/takoyaki_001/users/proulxs/vsmDriven/doIt_vsmDriven4/bids/sub-vsmDrivenP1/ses-cat/derivatives/center_vesselRoi01a.nii.gz';
volTs = vol2vec(volTs,fMask,1);


figure('WindowStyle','docked');
prd   = [60 30 20 15 12 10];
prdTr = round(prd./tr);
prd   = prdTr.*tr;
x = 1./prd;
xline(x,'Color','k')
y = repmat(mean(ylim),size(x));
text(x,y,num2str(prd','%0.2f'))
xline(1/50,'g')

xlim([0 0.6])
grid on
ax = gca;
ax.XMinorGrid = 'on'
ax.XMinorTick = 'on'

prd2 = prd([2 4 6]);
xline(1./prd2,'r')
prd2Tr = prdTr([2 4 6]);




tr = volTs.tr/1000;

1./(1./15 + diff(1./[15 10])/2)



1./(1./20 - diff(1./[20 15]))
1./linspace(0,0.1,6)



for Kmri = 3:10

    ax = {};
    figure('WindowStyle','docked');
    ht = tiledlayout(4,1); ht.Padding = 'tight'; ht.TileSpacing = 'tight';
    ax{end+1} = nexttile([2 1]);

    % MRI
    dMri = volTs.vec;
    tMri = volTs.t;
    FsMri = 1 / (volTs.tr/1000);
    dMri = dtrnd2(dMri,1/FsMri);
    dMri = dMri./std(dMri);

    % Kmri = 5;
    nMri = size(dMri,1);
    Tmri = (nMri-1)/FsMri;
    [TWmri,Wmri,Kmri] = K2W(Tmri,Kmri);
    paramMri.Fs = FsMri;
    paramMri.tapers = [TWmri Kmri];
    paramMri.err = [1 0.05];
    [psdMri,fMri,Serr] = mtspectrumc(dMri,paramMri);
    hMriPsd = plot(fMri,psdMri,'k'); hold on
    hMriPsdEr = plot(fMri,Serr,':k'); hold on


    % physio
    chanInd = ismember(physTs.chanLabel,'cardiac');
    d = physTs.vec(:,chanInd);
    n = size(d,1);
    Fs = physTs.Fs(chanInd);
    % t0 = physTs.t0(1,chanInd);
    t = linspace(0,(n-1)/Fs,n);
    % t = physTs.t(:,:,:,r) - sum([hour(physTs.blocktimes)*60*60 minute(physTs.blocktimes)*60 second(physTs.blocktimes)]);
    d = dtrnd2(d,1/Fs);
    d = d./std(d);

    K = 22;
    T = (n-1)/Fs;
    [TW,W,K] = K2W(T,K);
    param.Fs = Fs;
    param.tapers = [TW K];
    [psd,f] = mtspectrumc(d,param);
    hPhysPsd = plot(f,psd,'b'); hold on

    ax{end}.YScale = 'log'; grid on
    ax{end}.XMinorGrid = 'on'
    xlim([0 2.5])


    % physio downsample
    dDs = interp1(t,d,tMri);
    FsDs = FsMri;
    nDs = nMri;
    Tds = (nMri-1)/FsMri;
    Kds = Kmri;
    [TWds,Wds,Kds] = K2W(T,K);
    paramDs.Fs = FsDs;
    paramDs.tapers = [TWds Kds];
    [psdDs,fDs] = mtspectrumc(dDs,paramDs);
    hPhysPsdDs = plot(fDs,psdDs,'-.b'); hold on

    % xline(FsMri/2,'k')
    hHarm1 = xline(1.17111,'Color','r')
    hHarm2 = xline(1.17111*2,'Color','r','LineStyle','--')
    hHarm3 = xline(1.17111*3,'Color','r','LineStyle',':')
    hStim  = xline(Fstim,'Color','g');

    xline(FsMri/2 - (1.17111 - FsMri/2),'Color','r')
    xline(FsMri/2 - (abs((FsMri/2 - (1.17111*2 - FsMri/2))) - FsMri/2),'Color','r','LineStyle','--')
    xline(FsMri/2 - (abs(FsMri/2 - (abs((FsMri/2 - (1.17111*3 - FsMri/2))) - FsMri/2)) - FsMri/2),'Color','r','LineStyle',':')
    ylabel('psd')

    legend(...
        [hMriPsd
        hMriPsdEr(1)
        hPhysPsd
        hPhysPsdDs
        hStim
        hHarm1
        hHarm2
        hHarm3],...
        {'MRI' 'MRI 95%CI' ['cardiac (K=' num2str(K) ')'] 'cardiac ds to mri' 'stimulus' 'cardiacHarm1' 'cardiacHarm2' 'cardiacHarm3'})

    uistack([hHarm1 hHarm2 hHarm3],'bottom')

    % coherence
    paramMri.err = [2 0.05];
    [C,phi,S12,S1,S2,f,confC,phistd,Cerr]=coherencyc(dMri,dDs,paramMri);
    ax{end+1} = nexttile;
    hCoh = plot(f,C,'k'); hold on
    hCohEr = plot(f,Cerr,':k')
    hW = line(0.1 + [-Wmri Wmri],0.5.*[1 1],'LineWidth',5,'color','g')
    ylim([0 1])
    grid on
    hCohConf = yline(confC,'m')
    ax{end}.XMinorGrid = 'on'
    xline(1.17111,'Color','r')
    xline(1.17111*2,'Color','r','LineStyle','--')
    xline(1.17111*3,'Color','r','LineStyle',':')
    xline(Fstim,'Color','g');
    xline(FsMri/2 - (1.17111 - FsMri/2),'Color','r')
    xline(FsMri/2 - (abs((FsMri/2 - (1.17111*2 - FsMri/2))) - FsMri/2),'Color','r','LineStyle','--')
    xline(FsMri/2 - (abs(FsMri/2 - (abs((FsMri/2 - (1.17111*3 - FsMri/2))) - FsMri/2)) - FsMri/2),'Color','r','LineStyle',':')
    ylabel('coherence')

    legend(...
    [hCoh
    hCohEr(1)
    hCohConf
    hW],...
    {'MRI to cardiac coherence' '95%conf' 'thresh' '2W'})
    uistack(hW,'bottom')

    ax{end+1} = nexttile;
    hPhase = plot(f,phi,'k')
    grid on
    ylim([-pi pi])
    xline(1.17111,'Color','r')
    xline(1.17111*2,'Color','r','LineStyle','--')
    xline(1.17111*3,'Color','r','LineStyle',':')
    xline(Fstim,'Color','g');
    xline(FsMri/2 - (1.17111 - FsMri/2),'Color','r')
    xline(FsMri/2 - (abs((FsMri/2 - (1.17111*2 - FsMri/2))) - FsMri/2),'Color','r','LineStyle','--')
    xline(FsMri/2 - (abs(FsMri/2 - (abs((FsMri/2 - (1.17111*3 - FsMri/2))) - FsMri/2)) - FsMri/2),'Color','r','LineStyle',':')
    legend(hPhase,{'MRI to cardiac coherence phase'})



    ylabel('phase')
    set([ax{:}],'XLim',[0 1.3])
    set([ax{:}],'XTick',0:0.1:1.3)
    drawnow

    xlabel(ht,'Hz')
    
    title(ht,['single 5-min run, K=' num2str(Kmri)])
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cardiac phase-locking to stimulus %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

chanInd = 1;
taskList = {'task_50sPrd5sDur' 'task_20sPrd1sDur' 'task_15sPrd1sDur' 'task_10sPrd1sDur'};
for s = 1:2
    for tInd = 1:length(taskList)
        task = taskList{tInd};
        if isempty(rCond{s}.vfMRI.(task).physRuns); continue; end
        Fs = rCond{s}.vfMRI.(task).physRuns.samplerate(1);
        onsetList = rCond{s}.vfMRI.(task).dsgn.onsetList;
        isiSec = mean(diff(onsetList)); % isiSec = 47.88; % isi = mean(diff(onsetList));
        isiPts = round(isiSec*Fs);
        isiSec = isiPts/Fs;
        card  = zeros(isiPts,length(onsetList),size(rCond{s}.vfMRI.(task).physRuns.vec,4));
        cardM = zeros(isiPts,1                ,1                                           );
        smWinSec    = 0.05;
        smWinSecPts = smWinSec*Fs;
        for r = 1:size(rCond{s}.vfMRI.(task).physRuns.vec,4)
            t    = rCond{s}.vfMRI.(task).physRuns.t(:,1,1,r);
            t    = t - t(1);
            for e = 1:length(onsetList)
                [~,iS] = min(abs(t-onsetList(e)));
                iE = iS + isiPts - 1;
                card(:,e,r) = zscore(rCond{s}.vfMRI.(task).physRuns.vec(iS:iE,chanInd,1,r));
                cardM = cardM + card(:,e,r);
                card(:,e,r) = smooth(card(:,e,r),smWinSecPts);
            end
        end
        cardM = cardM./(size(rCond{s}.vfMRI.(task).physRuns.vec,4)*length(onsetList));
        cardM = smooth(cardM,smWinSecPts);
        figure('WindowStyle','docked');
        t = (0:1/Fs:(isiSec-1/Fs))';
        % hP = plot(t,mean(card(:,:),2));
        hP = plot(t,cardM);
        hP.LineWidth = 3; hP.Color = 'r';
        hold on
        hPx = plot(t,card(:,:),'Color',[0 0 0 0.15]);
        % xlim([0 15])
        uistack(hP,'top')
        grid on
        grid minor
        title(['sub-' num2str(s) '; ' replace(task,'_','-') '; ' num2str(size(rCond{s}.vfMRI.(task).physRuns.vec,4)) 'runs, ' num2str(length(onsetList)) 'trial each'])
        xlim([0 40])
        ylim([-2 4])

        xlabel('time since stimulus onset (s)')
        ylabel('ppg trace (z-scored run by run)')
        legend([hP hPx(1)],{'trial-triggered average' ['single-trial (n=' num2str(length(hPx)) ')']},'AutoUpdate','off')

        x = [0 mean(rCond{s}.vfMRI.(task).dsgn.ondurList)];
        y = ylim; y = y([1 1]);
        plot(x,y,'k','LineWidth',10)

        outDir = fullfile(info.bidsDir,['sub-' rCond{s}.vfMRI.(task).sub],'ses-cat'); if ~exist(outDir,'dir'); mkdir(outDir); end
        outFile = [task '_run-cat_trialTriggeredCardiac.fig'];
        drawnow
        % saveas(gcf,fullfile(outDir,outFile))
    end
end

t    = rCond{s}.vfMRI.(task).physRuns.t(:,1,1,r);
card = zscore(rCond{s}.vfMRI.(task).physRuns.vec(:,chanInd,1,r));
t    = t(10:end);
card = card(10:end);
cardSm = smooth(card,200);

a = findpeaks(cardSm,2);
figure('WindowStyle','docked');
plot(t,cardSm)
xline(t(a.loc))

TR = 0.84;
[hr, hrv_rmsd] = HRcal(t(a.loc),10/TR,TR,6,0);



tmp.loc

% chanInd = 1;
% taskList = {'task_50sPrd5sDur' 'task_20sPrd1sDur' 'task_15sPrd1sDur' 'task_10sPrd1sDur'};
% dsFac = 500;
% for s = 2
%     for tInd = 1
%         task = taskList{tInd};
%         if isempty(runCond{s}.vfMRI.(task).physRuns); continue; end
%         Fs = runCond{s}.vfMRI.(task).physRuns.samplerate(1);
%         for r = 1 %:size(runCond{s}.vfMRI.(task).physRuns.vec,4)
%             t    = runCond{s}.vfMRI.(task).physRuns.t(:,1,1,r);
%             t    = t - t(1);
%             card = runCond{s}.vfMRI.(task).physRuns.vec(:,chanInd,1,r);
%             nfft = length(card);
%             nfft = 2^(nextpow2(nfft)-1);
%             W = 0.05;
%             T = length(card)./Fs;
%             TW = T.*W;
%             K = round(TW*2-1);
%             TW = (K+1)/2;
%             W = TW/T;
%             disp(['computing mt spectum with ' num2str(K) ' tapers; run ' num2str(r) '/' num2str(size(runCond{s}.vfMRI.(task).physRuns.vec,4))])
%             tic
%             [pw,f] = pmtm(card-mean(card),TW,nfft,Fs);
% 
%             figure('WindowStyle','docked');
%             plot(f,pw)
%             ax = gca;
%             ax.YScale = 'log';
%             xlim([0 10])
%             hold on
% 
%             tq = downsample(t,dsFac);
%             cardq = interp1(t,card,downsample(t,dsFac));
%             nfft = length(cardq);
%             nfft = 2^(nextpow2(nfft)-1);
%             [pw,f] = pmtm(cardq-mean(cardq),TW,nfft,Fs/dsFac);
%             plot(f,pw)
% 
% 
%             grid on
%             grid minor
%             title(['sub-' num2str(s) '; ' replace(task,'_','-') '; ' num2str(size(runCond{s}.vfMRI.(task).physRuns.vec,4)) 'runs, ' num2str(length(onsetList)) 'trial each'])
%             drawnow
%         end
%     end
% end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load and run on demand example %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do.loadIt  = 0;
do.doIt    = 1;
do.saveIt  = 0;
do.writeIt = 1;

for S = 1:5
    runCondStim = runCondStimList{contains(runCondStimList,'task_50sPrd5sDur')};
    runCondAcq  = runCondAcqList{ contains(runCondAcqList ,'vfMRI'  )};
    if ~isfield(rCond{S}.(runCondAcq),runCondStim) || isempty(rCond{S}.(runCondAcq).(runCondStim)); continue; end

    %anat
    veMask = rCond{S}.label.vfMRI.calcarineVessel.f;
    hdMask = rCond{S}.mask{1}.head.mri;
    % volAnat = runCond{S}.(runCondAcq).(runCondStim).volAnatSub;
    % volAnat.roi{end+1} = volAnat.roi{end};
    % volAnat.roi{end}.label = 'calcarine';
    % volAnat.roi{end}.f = fullfile(fileparts(replace(volAnat.roi{end}.f,'.nii.gz','')),'sesAvCat_cat_av_preproc_calcarineMask.nii.gz');
    % roiLabelList = [volAnat.roi{:}]; roiLabelList = {roiLabelList.label}';
    % % roiLabel = 'calcarine';
    % roiLabel = 'vesselCalcarine';
    % roiInd = ismember(roiLabelList,roiLabel);

    %ts
    volTs = rCond{S}.(runCondAcq).(runCondStim).volTs;
    if ~isfield(volTs,'dsgn') && isfield(rCond{S}.(runCondAcq).(runCondStim),'dsgn')
        [volTs.dsgn] = deal(rCond{S}.(runCondAcq).(runCondStim).dsgn);
    end
    for r = 1:length(volTs)
        volTs(r) = MRIload2(volTs(r));
    end

    %resp
    forceThis   = 1;
    verboseThis = 2;
    info.doCat  = 1;
    info.doRun  = 0;
    info.doMov  = 1;
    if isfield(volTs,'dsgn') && ~isempty(volTs(1).dsgn.onsetList)
        % [volResp, ~, info] = volTsGetResp3(do,info,volTs,[],volAnat,forceThis,verboseThis);
        [volResp, ~, info] = volTsGetResp3(do,info,volTs,[],hdMask,forceThis,verboseThis);
        % fIn = [volTs.mri]; fIn = {fIn.fspec}';
        % fld = JSNread(fIn,[]);

    else
        volResp = [];
    end
end
strjoin({volResp.base.fspec
volResp.ts.fspec
volResp.F.fspec},' ')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot responses for each vessels %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close all
figure('WindowStyle','docked');

volResp.ts = MRIload2(volResp.ts,volAnat.roi{roiInd}.f);
volResp.F = MRIload2(volResp.F,volAnat.roi{roiInd}.f);

roiList      = [volAnat.roi{4:end-1}];
roiLabelList = {roiList.label}';
roiList      = {roiList.f}';

row = floor(sqrt(length(roiList)));
col = ceil(length(roiList)/row);
ht = tiledlayout(row,col); ht.TileSpacing = 'tight'; ht.Padding = 'tight';
for roi = 1:length(roiList)
    nexttile
    mask = MRIread(roiList{roi});
    Fq  = vol2vec(vec2vol(volResp.Fq),mask.vol,1);
    F   = vol2vec(vec2vol(volResp.F ),mask.vol,1);
    for c = 1:length(volResp.ts)
        t  = volResp.ts(c).t;
        ts = vol2vec(vec2vol(volResp.ts(c)),mask.vol,1);
        ts = mean(ts.vec(:,Fq.vec<0.05),2);
        plot(t,ts); hold on
        xlabel('time (s)')
        ylabel('MR signal (a.u.)')
    end
    F   = mean(F.vec(:,Fq.vec<0.05));
    title([replace(roiLabelList{roi},'vesselCalcarineRoi','') '; ' num2str(nnz(Fq.vec<0.05)) 'vox; F_{av}=' num2str(F)])
    grid on
    grid minor
    ylim([-180 100])
end
legend({'stimTrial' 'catchTrial'})
title(ht,[volTs(1).mri.sub '; ' runCondStim '; ' num2str(length(volTs)) 'runs'],'interpreter','none')


ax = gcf;
ax = findobj(ax.Children.Children,'type','axes');
% set(ax,'XLim',[0 20])
set(ax,'YLim',[-175 175])
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot ts for each vessels %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
volResp.F = MRIload2(volResp.F,volAnat.roi{roiInd}.f);
volTsX = MRIload2([volTs.mri]',volAnat.roi{roiInd}.f);

% close all
figure('WindowStyle','docked');

roiList      = [volAnat.roi{4:end-1}];
roiLabelList = {roiList.label}';
roiList      = {roiList.f}';

row = floor(sqrt(length(roiList)));
col = ceil(length(roiList)/row);
ht = tiledlayout(row,col); ht.TileSpacing = 'tight'; ht.Padding = 'tight';
for roi = 1:length(roiList)
    nexttile
    mask = MRIread(roiList{roi});
    Fq  = vol2vec(vec2vol(volResp.Fq),mask.vol,1);
    F   = vol2vec(vec2vol(volResp.F ),mask.vol,1);
    t  = volTsX(1).t + volTsX(1).nDummyRemoved*volTsX(1).tr/1000;
    ts = [];
    for r = 1:length(volTsX)
        tsX = vol2vec(vec2vol(volTsX(r)),mask.vol,1);
        ts(:,r) = mean(tsX.vec(:,Fq.vec<0.05),2);
    end
    plot(t,mean(ts,2),'k'); hold on
    xlabel('time (s)')
    ylabel('MR signal (a.u.)')
    F   = mean(F.vec(:,Fq.vec<0.05));
    title([replace(roiLabelList{roi},'vesselCalcarineRoi','') '; ' num2str(nnz(Fq.vec<0.05)) 'vox; F_{av}=' num2str(F)])
    grid on
    grid minor
    % ylim([-180 100])
    xline(volResp.dsgn.onsetList(volResp.dsgn.condList==1),'b')
    xline(volResp.dsgn.onsetList(volResp.dsgn.condList==2),'r')
end
title(ht,[volTs(1).mri.sub '; ' runCondStim '; ' num2str(length(volTs)) 'runs'],'interpreter','none')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%
%% Behavior %%
%%%%%%%%%%%%%%
do.loadIt  = 0;
do.doIt    = 1;
do.saveIt  = 0;
do.writeIt = 0;

S = 2;
runCondStim = runCondStimList{contains(runCondStimList,'task_20sPrd1sDur')};
runCondAcq  = runCondAcqList{ contains(runCondAcqList ,'vfMRI'  )};

%anat
volAnat = rCond{S}.(runCondAcq).(runCondStim).volAnatSub;
volAnat.roi{end+1} = volAnat.roi{end};
volAnat.roi{end}.label = 'calcarine';
volAnat.roi{end}.f = fullfile(fileparts(replace(volAnat.roi{end}.f,'.nii.gz','')),'sesAvCat_cat_av_preproc_calcarineMask.nii.gz');
roiLabelList = [volAnat.roi{:}]; roiLabelList = {roiLabelList.label}';
% roiLabel = 'calcarine';
roiLabel = 'vesselCalcarine';
roiInd = ismember(roiLabelList,roiLabel);

%ts
volTs = rCond{S}.(runCondAcq).(runCondStim).volTs;
if ~isfield(volTs,'dsgn') && isfield(rCond{S}.(runCondAcq).(runCondStim),'dsgn')
    [volTs.dsgn] = deal(rCond{S}.(runCondAcq).(runCondStim).dsgn);
end
for r = 1:length(volTs)
    volTs(r).bhvr = rCond{S}.(runCondAcq).(runCondStim).bhvr(r);
end


for r = 1:length(volTs)
    fMask = volAnat.roi{roiInd}.f;
    h(r) = plotSpec3([],volTs(r),'psd',volTs(r).dsgn,fMask,[],[],[]);
    h(r).Title.String = [h(r).Title.String '; perf=' num2str(str2num(volTs(r).bhvr.performance))];
end
yLim = get(h,'YLim'); yLim = [yLim{:}]; yLim = [min(yLim) max(yLim)];
set(h,'YLim',yLim)

mri = [volTs.mri];
mri.ses


%% %%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% vRF (vessel Response Function) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do.loadIt  = 0;
do.doIt    = 1;
do.saveIt  = 0;
do.writeIt = 1;

S = 1;
runCondStim = runCondStimList{contains(runCondStimList,'task_50sPrd5sDur')};
runCondAcq  = runCondAcqList{ contains(runCondAcqList ,'vfMRI'  )};

%anat
volAnat = rCond{S}.(runCondAcq).(runCondStim).volAnatSub;
% volAnat.roi{end+1} = volAnat.roi{end};
% volAnat.roi{end}.label = 'calcarine';
% volAnat.roi{end}.f = fullfile(fileparts(replace(volAnat.roi{end}.f,'.nii.gz','')),'sesAvCat_cat_av_preproc_calcarineMask.nii.gz');
roiLabelList = [volAnat.roi{:}]; roiLabelList = {roiLabelList.label}';
% roiLabel = 'calcarine';
roiLabel = 'vesselCalcarineRoi08ax';
% roiLabel = 'vesselCalcarine';
roiInd = ismember(roiLabelList,roiLabel);

volAnatX = volAnat;
volAnatX.roi{roiInd}.mri = MRIload2(MRIload2(volAnatX.roi{roiInd}.f));
volAnatX.roi{roiInd}.mri = vec2vol(volAnatX.roi{roiInd}.mri);
volAnatX.roi{roiInd}.mri.vol2vec(207,211) = true;
volAnatX.roi{roiInd}.mri.vol2vec(208,210) = true;
volAnatX.roi{roiInd}.mri.vol2vec(206,212) = true;
volAnatX.roi{roiInd}.mri.vol2vec(206,213) = true;
volAnatX.roi{roiInd}.mri.vol2vec(209,213) = true;
volAnatX.roi{roiInd}.mri.vol2vec(210,212) = true;
volAnatX.roi{roiInd}.mri.vol2vec(211,209) = true;
volAnatX.roi{roiInd}.mri = vol2vec(volAnatX.roi{roiInd}.mri);
volAnatX.roi{roiInd}.mri.vec(:) = true;
volAnatX.roi{roiInd}.mri = vec2vol(volAnatX.roi{roiInd}.mri);
volAnatX.roi{roiInd}.mri.vol(isnan(volAnatX.roi{roiInd}.mri.vol)) = false;


%ts
volTs = rCond{S}.(runCondAcq).(runCondStim).volTs;
if ~isfield(volTs,'dsgn') && isfield(rCond{S}.(runCondAcq).(runCondStim),'dsgn')
    [volTs.dsgn] = deal(rCond{S}.(runCondAcq).(runCondStim).dsgn);
end
for r = 1:length(volTs)
    volTs(r) = MRIload2(volTs(r),volAnatX.roi{roiInd}.mri);
end

% ses = [volTs.mri];
% cat(1,ses.ses)

%resp
forceThis   = 1;
verboseThis = 1;
for r = 1:length(volTs)
    [volResp(r), ~, info] = volTsGetResp3(do,info,volTs(r),[],volAnat,forceThis,verboseThis);
end




mask = volAnatX.roi{roiInd}.f;

info.method = 'uniSVD'; % 'uniSVD' 'multiSVD' 'canon' 'pls'
r = 1;
MVPA(volTs(r),info,mask,volResp(r))

info.method = 'multiSVD'; % 'uniSVD' 'multiSVD' 'canon' 'pls'
MVPA(volTs,info,mask,volResp)

info.method = 'canon'; % 'uniSVD' 'multiSVD' 'canon' 'pls'
MVPA(volTs,info,mask,volResp)

info.method = 'pls'; % 'uniSVD' 'multiSVD' 'canon' 'pls'
MVPA(volTs,info,mask,volResp)


roiIndList = [4 9 11 14];
for roiInd = 1:length(roiIndList)
    mask = volAnatX.roi{roiIndList(roiInd)}.f;
    info.method = 'uniSVD'; % 'uniSVD' 'multiSVD' 'canon' 'pls'
    info.label = volAnatX.roi{roiIndList(roiInd)}.label;
    MVPA(volTs,info,mask,[]);
end


%mt
K = 4;
extra.Kf = [1 2 3] .* 1/mean(diff(volTs(r).dsgn.onsetList));
W = [];
win = inf;
verboseThis = 1;
r = 1;
volPsd(r) = runFullMT3(volTs(r),W,K,win,[],[],volAnatX.roi{roiInd}.mri,extra,[],[],verboseThis,[],[])';

M = 1;
ax = {};
figure('WindowStyle','docked');
imagesc(volTs(r).mri.imMean);
ax{end+1} = gca;
ax{end}.Colormap = gray;
ax{end}.DataAspectRatio = [1 1 1];
ax{end}.PlotBoxAspectRatio = [1 1 1];
figure('WindowStyle','docked');
im = zeros(size(volTs(r).mri.vol2vec));
im(volTs(r).mri.vol2vec) = volPsd(r).svdXfreq.spSV(:,:,:,:,:,:,:,M);
imagesc(abs(im));
ax{end+1} = gca;
ax{end}.DataAspectRatio = [1 1 1];
ax{end}.PlotBoxAspectRatio = [1 1 1]; colorbar
figure('WindowStyle','docked');
imagesc(angle(im));
ax{end+1} = gca;
ax{end}.Colormap = hsv;
ax{end}.DataAspectRatio = [1 1 1];
ax{end}.PlotBoxAspectRatio = [1 1 1];
ax{end}.CLim = [-pi pi]; colorbar
linkaxes([ax{:}])

figure('WindowStyle','docked');
x = squeeze(imag(volPsd(r).svdXfreq.spSV(:,:,:,:,:,:,:,M)));
y = squeeze(real(volPsd(r).svdXfreq.spSV(:,:,:,:,:,:,:,M)));
scatter(x,y);
lim = [-1 1].*max(abs([x; y]));
xlim(lim); ylim(lim);
ax = gca; ax.DataAspectRatio = [1 1 1];
grid on; grid minor;
b0 = x\y;
yhat0=b0*[0; x]; 
hold on
plot([0; x],yhat0)
b0 = (x.^2)\(y.^2);
yhat0=b0*[0; x]; 
hold on
plot([0; x],yhat0)
b0 = (x.^3)\(y.^3);
yhat0=b0*[0; x]; 
hold on
plot([0; x],yhat0)


plotSpec3([],volPsd(r),'coh',volTs(r).dsgn,volAnatX.roi{roiInd}.f);


ax = {};
for K = 2:10
    W = [];
    win = inf;
    verboseThis = 1;
    r = 1;
    volPsd(r) = runFullMT3(volTs(r),W,K,win,[],[],volAnatX.roi{roiInd}.f,[],[],[],verboseThis,[],[])';
    plotSpec3([],volPsd(r),'coh',volTs(r).dsgn,volAnatX.roi{roiInd}.f);

    ax{end+1} = gca;
    axL = findobj(ax{end}.Children,'Type','ConstantLine');
    axL(end+1) = copyobj(axL(1),ax{end}); axL(end).Value = axL(1).Value*2;
    axL(end+1) = copyobj(axL(1),ax{end}); axL(end).Value = axL(1).Value*3;
    axL(end+1) = copyobj(axL(1),ax{end}); axL(end).Value = axL(1).Value*4;
end
yLim = get([ax{:}],'YLim'); yLim = [yLim{:}]; yLim = [min(yLim) max(yLim)];
set([ax{:}],'YLim',yLim);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualize Individual Runs  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do.loadIt  = 0;
do.doIt    = 1;
do.saveIt  = 0;
do.writeIt = 1;

S = 1;
runCondStim = runCondStimList{contains(runCondStimList,'task_50sPrd5sDur')};
runCondAcq  = runCondAcqList{ contains(runCondAcqList ,'vfMRI'  )};

%anat
volAnat = rCond{S}.(runCondAcq).(runCondStim).volAnatSub;
volAnat.roi{end+1} = volAnat.roi{end};
volAnat.roi{end}.label = 'calcarine';
volAnat.roi{end}.f = fullfile(fileparts(replace(volAnat.roi{end}.f,'.nii.gz','')),'sesAvCat_cat_av_preproc_calcarineMask.nii.gz');
roiLabelList = [volAnat.roi{:}]; roiLabelList = {roiLabelList.label}';
roiLabel = 'calcarine';
% roiLabel = 'vesselCalcarine';
roiInd = ismember(roiLabelList,roiLabel);

%ts
volTs = rCond{S}.(runCondAcq).(runCondStim).volTs;
if ~isfield(volTs,'dsgn') && isfield(rCond{S}.(runCondAcq).(runCondStim),'dsgn')
    [volTs.dsgn] = deal(rCond{S}.(runCondAcq).(runCondStim).dsgn);
end
for r = 1:length(volTs)
    disp([''])
    volTs(r) = MRIload2(volTs(r));
end

%resp
forceThis   = 1;
verboseThis = 1;
for r = 1:length(volTs)
    [volResp(r), ~, info] = volTsGetResp3(do,info,volTs(r),[],volAnat,forceThis,verboseThis);
end

%mt
W = [];
K = 20;
win = inf;
% win = round(30/(volTs(1).mri.tr/1000));
verboseThis = 1;
volPsd = runFullMT3(volTs,W,K,win,[],[],volAnat.roi{roiInd}.f,[],[],[],verboseThis,[],[])';

r = 1;
plotSpecAll2(volPsd(r),volTs(r),volResp(r),volTs(r).dsgn,volAnat.roi{roiInd}.f,[],0.05)

for r = 1:length(volPsd)
    tryL2svd(volPsd(r))
    plotSpecAll2(volPsd(r),volTs(r),volResp(r),volTs(r).dsgn,volAnat.roi{roiInd}.f,[],0.05)
end

for r = 1:length(volPsd)
    plotSpecAll2(volPsd(r),volTs(r),volResp(r),volTs(r).dsgn,volAnat.roi{roiInd}.f,[],0.05)

    figure('WindowStyle','docked');
    winInd = 1;
    volPsd(r).psdTrialGramMD.t(:,1,1,1,1,1,winInd)
    f = squeeze(volPsd(r).psdTrialGramMD.f);
    psd = squeeze(mean(volPsd(r).psdTrialGramMD.vec.psdPC(:,:,:,:,:,:,winInd),6));
    plot(f,psd);
    set(gca,'YScale','log')
    grid on; grid minor
    hold on

    winInd = round(size(volPsd(r).psdTrialGramMD.t,7)/2);
    volPsd(r).psdTrialGramMD.t(:,1,1,1,1,1,winInd)
    f = squeeze(volPsd(r).psdTrialGramMD.f);
    psd = squeeze(mean(volPsd(r).psdTrialGramMD.vec.psdPC(:,:,:,:,:,:,winInd),6));
    plot(f,psd);

    winInd = size(volPsd(r).psdTrialGramMD.t,7);
    volPsd(r).psdTrialGramMD.t(:,1,1,1,1,1,winInd)
    f = squeeze(volPsd(r).psdTrialGramMD.f);
    psd = squeeze(mean(volPsd(r).psdTrialGramMD.vec.psdPC(:,:,:,:,:,:,winInd),6));
    plot(f,psd);

    legend({'early' 'mid' 'late'})
    ax = gca;
    yLim = get(ax.Children,'YData'); yLim = min(cat(1,yLim{:}),[],1); yLim = min(yLim(f>0.05)); tmp = ylim; yLim(2) = tmp(2); ylim(yLim);
end



volTs(r).mri.dsgn = volTs(r).dsgn;



plotSpecAll(volPsd(r),volTs(r).mri,volResp(r),0.05);

plotSpecAll

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%



