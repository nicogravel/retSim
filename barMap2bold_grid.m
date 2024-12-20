clear all
close all
cd '/home/nicolas/Documents/Paris/validationFrameworks/CFields/stimBOLD/'

addpath(genpath(pwd));


%% (drifting) Bar Mappping stimulus to BOLD response
% load('inputData/images.mat')
% load('inputData/params.mat')
load stimBOLD_bold_18oct2024
% load stimBOLD_neural_18oct2024
msh = stimBOLD_output.msh;
[msh,retinotopicTemplate] = load_cortical_template(stimBOLD_output.params);


%% Simulated BOLD time series
stimBOLD_output.msh.submesh.visualAreas = retinotopicTemplate.visualAreas;
stimBOLD_output.msh.submesh.ecMap = retinotopicTemplate.eccentricityAreas;
stimBOLD_output.msh.submesh.polMap = retinotopicTemplate.polarAreas;
[stimBOLD_output.msh] = transferMappingToSubmesh(stimBOLD_output.msh);
msh = stimBOLD_output.msh;
data = 1000*ones(size(msh.submesh.mappedInds));
data(msh.submesh.visualAreas.v1) = msh.submesh.visTag.v1;
data(msh.submesh.visualAreas.v2) = msh.submesh.visTag.v2;
data(msh.submesh.visualAreas.v3) = msh.submesh.visTag.v3;
area_template =data;
visualAreas.v1 = find(abs(area_template) == 1); % 4581
visualAreas.v2 = find(abs(area_template) == 2); % 3437
visualAreas.v3 = find(abs(area_template) == 3); % 3271


%% Foveal confluence model
model='bandedDoubleSech';
%model='DoubleSech';
%model='Schwartz';
% basic common Model Parameters:
a=1; %0.75; % Foveal pole
b=8;  % Peripheral pole
K=18;  % scaling parameter
% shear parameters alpha 1 to 3
V1linShear=1;
V2linShear=0.5;
V3linShear=0.4;
%  a few more parameters determening the precrision and time for computation
minEcc=0.05;
maxEcc=6;
% now a few more settings that we provide no GUI support for.

isoEccRings=36; %7;
isoPolarRays=36; %7;
resolution=69; % resolution of the dots along the grid
squareDens=96; % precision of anisotropy estimate, bigger = better

isoEccRings=8; %7;
isoPolarRays=8; %7;
resolution=16; % resolution of the dots along the grid
squareDens=8; % precision of anisotropy estimate, bigger = better

% will project for squareDens^2 for each V1-V3
% must be even
% 50 is fast and fairly O.K.; 200 takes about 4 minutes
% Graphic parameters
fontSize=13;
dotSize=0.2;
%colors=[0.8 0.8 0.8; 0.6 0.6 0.6; 0.4 0.4 0.4];
colors=[0.6 0.6 0.6; 0.6 0.6 0.6; 0.6 0.6 0.6];
cdiv = 1;

% Cortex to Foveal Confluence matching method
% distMethod = @retDist; % polar distance
% distMethod = 'mahalanobis';
% distMethod =  'minkowski'; 
% distMethod =  'chebychev' ;
% distMethod =   'cosine';
% distMethod =   'euclidean' ;
 distMethod =   'seuclidean' ;

 
%% Match stimBOLD output to foveal confluence model
complexGrid=makeVisualGrid(minEcc,maxEcc,isoEccRings,isoPolarRays,resolution);
[V1Grid,V2Grid,V3Grid]=assembleV1V3Complex(complexGrid,[V1linShear,V2linShear,V3linShear],0);


%executing the model
eval(['[V1cartx,V1carty]=',model,'(V1Grid,a,b);']);
eval(['[V2cartx,V2carty]=',model,'(V2Grid,a,b);']);
eval(['[V3cartx,V3carty]=',model,'(V3Grid,a,b);']);


%%  Project time series


%% V1
ecc = msh.submesh.ecMap.v1;
pol = msh.submesh.polMap.v1;
idx_V1 = ecc  < maxEcc & ecc  > minEcc;
ecc_v1 = ecc(idx_V1);
pol_v1 = pol(idx_V1);
%% V2
ecc = msh.submesh.ecMap.v2;
pol = msh.submesh.polMap.v2;
idx_V2 = ecc  < maxEcc & ecc  > minEcc;
ecc_v2 = ecc(idx_V2);
pol_v2 = pol(idx_V2);
%% V3
ecc = msh.submesh.ecMap.v3;
pol = msh.submesh.polMap.v3;
idx_V3 = ecc  < maxEcc & ecc  > minEcc;
ecc_v3 = ecc(idx_V3);
pol_v3 = pol(idx_V3);


%% Match simulated BOLD with algebraic model
[a_v1, ~] = knnsearch([ecc_v1 pol_v1],complexGrid','dist', distMethod,'NSMethod','exhaustive');
[a_v2, ~] = knnsearch([ecc_v2 pol_v2],complexGrid','dist', distMethod,'NSMethod','exhaustive');
[a_v3, ~] = knnsearch([ecc_v3 pol_v3],complexGrid','dist', distMethod,'NSMethod','exhaustive');


%% Project time series
c = 0 ;
clear V1 V2 V3
for i_frame = 1:10:size( stimBOLD_output.BOLD,1)-4500
    c = c+1;
    X =  stimBOLD_output.BOLD(i_frame,visualAreas.v1);
    X = X(idx_V1);
    V1(:,c) = X(a_v1);
    X =  stimBOLD_output.BOLD(i_frame,visualAreas.v2);
    X = X(idx_V2);
    V2(:,c) = X(a_v2);
    X =  stimBOLD_output.BOLD(i_frame,visualAreas.v3);
    X = X(idx_V3);
    V3(:,c) = X(a_v3);
end


%% BOLD time series
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) 400,1200]); % Set plot size
subplot 311
scatter(V1cartx,V1carty,'ko')
ylabel('V1 sites');
subplot 312
scatter(V2cartx,V2carty,'ko')
ylabel('V2 sites');
subplot 313
scatter(V3cartx,V3carty,'ko')
ylabel('V3 sites');
xlabel('Time');
set(gca, 'FontSize', 12);
set(gca,'LineWidth',2)
set(gca, 'box', 'off');
set(gcf, 'color', 'w');
set(findobj(gcf,'type','axes'),'FontName','Arial', 'FontSize', 14, 'LineWidth', 1.5);


%% BOLD time series
cdiv = 200
figure;
colormap(nawhimar)
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) 1200,800]); % Set plot size
subplot 311
title('V1')
imagesc(V1)
cxlim =  max(V1(:))/cdiv;
caxis([-cxlim  cxlim]); 
h = colorbar('eastoutside')
ylabel(h, 'BOLD ({\ita.u.})','FontSize',12); h.LineWidth = 1.5;
ylabel('V1 site');
subplot 312
title('V2')
imagesc(V2)
cxlim =  max(V2(:))/cdiv;
caxis([-cxlim  cxlim]); 
h = colorbar('eastoutside')
ylabel(h, 'BOLD ({\ita.u.})','FontSize',12); h.LineWidth = 1.5;
ylabel('V2 site');
subplot 313
title('V3')
imagesc(V3)
cxlim =  max(V3(:))/cdiv;
caxis([-cxlim  cxlim]); 
h = colorbar('eastoutside')
ylabel(h, 'BOLD ({\ita.u.})','FontSize',12); h.LineWidth = 1.5;
ylabel('V3 site');
xlabel('Time');
set(gca, 'FontSize', 12);
set(gca,'LineWidth',2)
set(gca, 'box', 'off');
set(gcf, 'color', 'w');
set(findobj(gcf,'type','axes'),'FontName','Arial', 'FontSize', 14, 'LineWidth', 1.5);




%% Snapshot
cdiv= 2;
i_frame = 30; %70. 120
figure,
pos = get(gcf, 'Position');
%set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 24 24]);
set(gcf, 'Position', [0 0 1200, 1200]);
set(gcf, 'color', 'w');
colormap(nawhimar)
cX = [V1cartx,V2cartx,V3cartx];
cY = [V1carty,V2carty,V3carty];
boldMap = [V1(:,i_frame);V2(:,i_frame);V3(:,i_frame)];
[B,II,JJ]=unique([cX;cY]','rows');
boldMap=boldMap(II);
cX=B(:,1);
cY=B(:,2);
lhemi=cY<0;
t=delaunay(cX(lhemi),cY(lhemi));
trisurf(t,cX(lhemi),cY(lhemi),zeros(length(cX(lhemi)),1),boldMap(lhemi));
hold on
t=delaunay(cX(~lhemi),cY(~lhemi));
trisurf(t,cX(~lhemi),cY(~lhemi),zeros(length(cX(~lhemi)),1),boldMap(~lhemi));
rnum =1;
%cxlim_min  =  min(stimBOLD_output.BOLD(:));
%cxlim_max =  max(stimBOLD_output.BOLD(:));
cxlim =  max(stimBOLD_output.BOLD(:))/cdiv;
hh=plot(V1cartx,V1carty,'.');
set(hh,'color',colors(1,:),'markersize',dotSize);
%hh=plot(V2cartx,V2carty,'.');
%set(hh,'color',colors(2,:),'markersize',dotSize);
hh=plot(V3cartx,V3carty,'.');
set(hh,'color',colors(3,:),'markersize',dotSize);
shading interp;
%shading flat;
%axis equal;
%lighting gouraud
%axis 'image';
axis square;
%grid off
axis off
view(0,90);
%view([240 -90]);
%caxis([-round(cxlim,rnum)  round(cxlim,rnum)]); % comment if plotting phase
%caxis([cxlim_min  cxlim_max]); % comment if plotting phase
caxis([-cxlim  cxlim]); % comment if plotting phase
%h = colorbar('YTickLabel',{'','','',''},...
%    'FontSize',18,'Position',[0.9 .45 .05 .25],'Color','k');
h = colorbar('southoutside')
ylabel(h, 'BOLD ({\ita.u.})','FontSize',12); h.LineWidth = 1.5;







%%  BOLD time flow simulation
%cdiv= 10;
% %%
% %v = VideoWriter('barMap2bold_FovealConfluence_dBSech.avi');
% %v = VideoWriter('barMap2bold_FovealConfluence_Schwartz.avi');
% v = VideoWriter('barMap2bold_FovealConfluence.avi');
% open(v)
% figure,
% pos = get(gcf, 'Position');
% %set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 24 24]);
% set(gcf, 'Position', [0 0 1200, 1200]);
% set(gcf, 'color', 'w');
% colormap(nawhimar)
% pause(1)
% % set(gcf,'Renderer','Painters');
% set(gcf,'Renderer','Zbuffer');
% %set(gcf,'Renderer','OpenGL');
% for i_frame = 1:size(V1,2)
%     cX = [V1cartx,V2cartx,V3cartx];
%     cY = [V1carty,V2carty,V3carty];
%     boldMap = [V1(:,i_frame);V2(:,i_frame);V3(:,i_frame)];
%     [B,II,JJ]=unique([cX;cY]','rows');
%     boldMap=boldMap(II);
%     cX=B(:,1);
%     cY=B(:,2);
%     lhemi=cY<0;
%     t=delaunay(cX(lhemi),cY(lhemi));
%     trisurf(t,cX(lhemi),cY(lhemi),zeros(length(cX(lhemi)),1),boldMap(lhemi));
%     hold on
%     t=delaunay(cX(~lhemi),cY(~lhemi));
%     trisurf(t,cX(~lhemi),cY(~lhemi),zeros(length(cX(~lhemi)),1),boldMap(~lhemi));
%     rnum =1;
%     %cxlim_min  =  min(stimBOLD_output.BOLD(:));
%     %cxlim_max =  max(stimBOLD_output.BOLD(:));
%     cxlim =  max(stimBOLD_output.BOLD(:))/cdiv;
%     hh=plot(V1cartx,V1carty,'.');
%     set(hh,'color',colors(1,:),'markersize',dotSize);
%     %hh=plot(V2cartx,V2carty,'.');
%     %set(hh,'color',colors(2,:),'markersize',dotSize);
%     hh=plot(V3cartx,V3carty,'.');
%     set(hh,'color',colors(3,:),'markersize',dotSize);
%     shading interp;
%     %shading flat;
%     %axis equal;
%     %lighting gouraud
%     %axis 'image';
%     axis square;
%     %grid off
%     axis off
%     view(0,90);
%     %view([240 -90]);
%     %caxis([-round(cxlim,rnum)  round(cxlim,rnum)]); % comment if plotting phase
%     %caxis([cxlim_min  cxlim_max]); % comment if plotting phase
%     caxis([-cxlim  cxlim]); % comment if plotting phase
%     h = colorbar('YTickLabel',{'','','',''},...
%         'FontSize',18,'Position',[0.9 .45 .05 .25],'Color','k');
%     ylabel(h, ['BOLD ({\ita.u.}), frame: ' num2str(i_frame)],'FontSize',12); h.LineWidth = 1.5;
%     frm = getframe(gcf);
%     writeVideo(v,frm);
%     %pause(0.1)
%     clear gcf
%     clf
% end
% close(v);
% close 







