%% From the pRF drifting bar stimuli to neuronal drive to BOLD
% nicolas gravel, October 2024 

% Script adapted from:
% A computational framework to estimate the BOLD response directly from an
% input stimulus.
%
% Kevin Aquino
% Mark Schira
% Peter Robinson.
%
% Acknowledgments:
% Wenbin Shao       - for computional work
% Romesh Abeysuriya - for GUI and visualization assistance
% Thomas Lacy       - for help in equations
% Michael Breakspear- help in development of the model
% Noah Benson       - Aiding of the retinotopic template


clear all
cd '/home/nicolas/Documents/Paris/validationFrameworks/CFields/stimBOLD/'


%filename = 'single_sweep.avi';
filename = 'visualStimuli/barMap.avi';  % Just the frames we need
%filename = 'visualStimuli/barMap_whole.avi';  % too many redundant frames


% Add the current directory of stimBOLD to the path (and all its
% subfolders)
addpath(genpath(pwd));
% Generate
path_fs = getpath_freesurfer([pwd filesep 'GUIcode'],{'data'});
path_fs_cell ={path_fs};

% This section is if you do not have Freesurfer installed and you want to
% use the sections of freesurfer needed for stimBOLD to run.

matlab_fs =fullfile(path_fs, 'matlab');

if exist(matlab_fs, 'dir')
    addpath(matlab_fs)
else
    addpath(fullfile(path_fs, 'MATLAB'));
end

% Primary initialization:
stimBOLD_output = struct;
params = loadParameters;

data_in = VideoReader(fullfile(pwd, filename));
nFrames = data_in.NumberOfFrames;


%rateFrames = data_in.FrameRate;
rateFrames = 1.5; data_in.FrameRate;  % framerate has been decreased 20 times

time_cell =(0:nFrames-1)/rateFrames;
time_cell =mat2cell_vs(time_cell);
img_cell =cell(1, nFrames);

% Read one frame at a time.
for k = 1 : nFrames
    img_cell{k} = read(data_in, k);
end

% Updte parameters
% ================
params.time_cell = time_cell;
params.time_afterStim = nFrames/rateFrames;
params.t_end =  params.time_cell{end} + params.time_afterStim;
params.t_start = params.time_cell{1};
params.t = params.t_start:params.dt:params.t_end;


% Visual inputs
% ================
[visual_stimulus,params] = retinalProcessing(img_cell,params);
            


% Retinal Response
% ================
% Here add the components from load_stimuli_GUI, then here create the
% contrast response functions

disp('Retinal Processing..')
[retinal_blur,params] = retinalProcessing(visual_stimulus,params);

% After doing the smoothing calculate the contrast response functions i.e.
% in L*A*B space then using this to calculate the contrast response based
% on the luminance variable.

% After this inital processing is down, it is then reduced in size to
% a set retinal template, i.e. a set of co-ordinates in eccentricity and
% polar angle.
[retinalTemplate] = load_retinal_template(params);


% This here loads the co-ordinates of the image in polar-coordinates, this
% is needed to transform from the visual field to the retinal field.
[thmat,rmat] = polar_coordinates_gen(size(visual_stimulus{1}, 1),...
    size(visual_stimulus{1}, 2), params);
[retinal_response,params] = retinalContrastResponse(retinal_blur,params,retinalTemplate,thmat,rmat);



% Cortical mapping (from Retina -> LGN -> Primary Visual Cortex)
% ================
% In this section do the mapping from the retina to visual cortex, in here
% will also add things such as the smoothing -> changing with respect to
% visual area.
[msh,params,v1RetinalOutputs,retinotopicTemplate] = corticalProjection(retinal_response,retinalTemplate,params);

% later include the retinal pooling in another function (in cortical
% projection?)

% Neural Response
% ================
tic
disp('NeuralResponse..')
[neuralActivity,neuralInputs,params,msh] = neuralResponse(msh,v1RetinalOutputs,retinotopicTemplate,params);
toc

stimBOLD_neural.v1RetinalOutputs = v1RetinalOutputs;
stimBOLD_neural.retinotopicTemplate = retinotopicTemplate;
stimBOLD_neural.neuralActivity = neuralActivity;
stimBOLD_neural.neuralInputs = neuralInputs;
stimBOLD_neural.retinal_response = retinal_response;
stimBOLD_neural.params = params;


%save stimBOLD_neural_18oct2024  stimBOLD_neural
save stimBOLD_neural_20dec2024  stimBOLD_neural


% Neural Drive Function (including neural responses)
% ================

%load stimBOLD_neural_18oct2024
load stimBOLD_neural_20dec2024

[zeta] = calculateNeuralDrive(msh,stimBOLD_neural.neuralActivity,stimBOLD_neural.neuralInputs,stimBOLD_neural.params);

clear stimBOLD_neural_20dec2024

% Bold Response
% ================

tic
disp('BOLD model')
[BOLD] = hemodynamicModel(full(zeta),msh,params);
toc


stimBOLD_output.params = params;
stimBOLD_output.BOLD = BOLD;
stimBOLD_output.zeta = zeta;
stimBOLD_output.msh = msh;
stimBOLD_output.retinal_response = retinal_response;
stimBOLD_output.visual_stimulus = visual_stimulus;

%save stimBOLD_bold_18oct2024  stimBOLD_output
save stimBOLD_bold_20dec2024  stimBOLD_output


%% CF field's biophysical simulation 'arena'

% Here is just the visual sitimulus displayed. 
interactive_visualization(stimBOLD_output);

