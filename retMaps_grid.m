%% Retinotopic maps
%
%  nicolas gravel, January 2025

clear all
close all

cd '/home/nicolas/Documents/GitHubProjects/retSim/tools/stimBOLD-retSim/'
addpath(genpath('/home/nicolas/Documents/GitHubProjects/retSim/'));

pth = '/home/nicolas/Documents/GitHubProjects/retSim/'


%% Foveal confluence model
modelToDemonstrate=2; %1 = 2D-Parametric-Shear Model, 2 = Divisory Model, 3 = Schwartz Dipole Model
switch modelToDemonstrate
    case 1
        model='DoubleSech';
    case 2
        model='bandedDoubleSech';
    case 3
        model='Schwartz';
end
% basic common Model Parameters:
a=0.75; % Foveal pole
b=90;  % Peripheral pole
K=18;  % scaling parameter
    % shear parameters alpha 1 to 3 
V1linShear=1; 
V2linShear=0.5;
V3linShear=0.4;
minEcc=0.05;
maxEcc=24;
isoEccRings=7;
isoPolarRays=7;
resolution=200; % resolution of the dots along the grid
squareDens=76; % precision of anisotropy estimate
fontSize=13;
dotSize=5;
colors=[1 0 0; 0 1 0; 0 0 1];

complexGrid=makeVisualGrid(minEcc,maxEcc,isoEccRings,isoPolarRays,resolution);

size(complexGrid)

[V1Grid,V2Grid,V3Grid]=assembleV1V3Complex(complexGrid,[V1linShear,V2linShear,V3linShear],0);

size(V1Grid)

%executing the model
eval(['[V1cartx,V1carty]=',model,'(V1Grid,a,b);']);
eval(['[V2cartx,V2carty]=',model,'(V2Grid,a,b);']);
eval(['[V3cartx,V3carty]=',model,'(V3Grid,a,b);']);




%% Plor retinotopic maps
figure,
pos = get(gcf, 'Position');
set(gcf, 'Position', [0 0 1200, 400]);
set(gcf, 'color', 'w');

%% Eccentricity
subplot 131
hold on
colormap jet
eccMap =[complexGrid(1,:),complexGrid(1,:),complexGrid(1,:)];
cX = [V1cartx,V2cartx,V3cartx];
cY = [V1carty,V2carty,V3carty];
[B,II,JJ]=unique([cX;cY]','rows');
cX=B(:,1);
cY=B(:,2);
eccMap=eccMap(II);
lhemi=cY<0;
t=delaunay(cX(lhemi),cY(lhemi));
trisurf(t,cX(lhemi),cY(lhemi),zeros(length(cX(lhemi)),1),eccMap(lhemi));
t=delaunay(cX(~lhemi),cY(~lhemi));
trisurf(t,cX(~lhemi),cY(~lhemi),zeros(length(cX(~lhemi)),1),eccMap(~lhemi));
shading interp;
axis equal;
axis off
view(0,90);
title('eccentricity');

%% Polar angle
subplot 132
hold on
colormap hsv
polMap =[complexGrid(2,:),complexGrid(2,:),complexGrid(2,:)];
cX = [V1cartx,V2cartx,V3cartx];
cY = [V1carty,V2carty,V3carty];
[B,II,JJ]=unique([cX;cY]','rows');
cX=B(:,1);
cY=B(:,2);
polMap=polMap(II);
lhemi=cY<0;
t=delaunay(cX(lhemi),cY(lhemi));
trisurf(t,cX(lhemi),cY(lhemi),zeros(length(cX(lhemi)),1),polMap(lhemi));
t=delaunay(cX(~lhemi),cY(~lhemi));
trisurf(t,cX(~lhemi),cY(~lhemi),zeros(length(cX(~lhemi)),1),polMap(~lhemi));
shading interp;
axis equal;
axis off
view(0,90);
title('polar angle');

%% Polar grid o cortex
subplot 133
hold on
hh=plot(V1cartx,V1carty,'.'); set(hh,'color',colors(1,:));
hh=plot(V2cartx,V2carty,'.'); set(hh,'color',colors(2,:));
hh=plot(V3cartx,V3carty,'.'); set(hh,'color',colors(3,:));
axis equal, axis off; 
title('polar grid on cortex');

print(gcf, [pth, 'figures\retMaps_', model,  '.png'], '-dpng', '-r150', '-painters')
