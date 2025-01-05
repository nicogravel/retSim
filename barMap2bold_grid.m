clear all
close all

cd '/home/nicolas/Documents/GitHubProjects/retSim/tools/stimBOLD-retSim/'
addpath(genpath('/home/nicolas/Documents/GitHubProjects/retSim/'));

pth = '/home/nicolas/Documents/GitHubProjects/retSim/'


%% Foveal confluence model 
% basic common Model Parameters:
model='bandedDoubleSech';
%model='DoubleSech';
%model='Schwartz';
minEcc= 0.05;
maxEcc= 6;
a=0.75; %minEcc; %Foveal pole
b=maxEcc;  % Peripheral pole
K=18;  % scaling parameter
% shear parameters alpha 1 to 3
V1linShear=1; 
V2linShear=0.5;
V3linShear=0.4;
isoEccRings=24; 
isoPolarRays=24; 
resolution=24; % resolution of the dots along the grid
squareDens=24; % precision of anisotropy estimate, bigger = better
% will project for squareDens^2 for each V1-V3 (must be even)
fontSize=13;
dotSize=0.2;
%colors=[0.8 0.8 0.8; 0.6 0.6 0.6; 0.4 0.4 0.4];
colors=[0.6 0.6 0.6; 0.6 0.6 0.6; 0.6 0.6 0.6];
cdiv = 5


%% Load simulated BOLD responses 
load([pth, 'outputs/stimBOLD_output.mat'])
msh = stimBOLD_output.msh;
[msh,retinotopicTemplate] = load_cortical_template(stimBOLD_output.params);


%% Define cortical areas V1, V2 and V3
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


%% Match stimBOLD output to foveal confluence model

% distMethod = @retDist; % polar distance
% distMethod =  'euclidean' ;
 distMethod =   'seuclidean' ;
 
complexGrid=makeVisualGrid(minEcc,maxEcc,isoEccRings,isoPolarRays,resolution);

[V1Grid,V2Grid,V3Grid]=assembleV1V3Complex(complexGrid,[V1linShear,V2linShear,V3linShear],0);

% executing the model
eval(['[V1cartx,V1carty]=',model,'(V1Grid,a,b);']);
eval(['[V2cartx,V2carty]=',model,'(V2Grid,a,b);']);
eval(['[V3cartx,V3carty]=',model,'(V3Grid,a,b);']);


%%  Foveal confluence of V1-V2-V3
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) 1200, 400]); % Set plot size
subplot 131
scatter(V1cartx,V1carty,'ko')
title('V1');
axis off
set(gca, 'FontSize', 24);
subplot 132
scatter(V2cartx,V2carty,'ko')
title('V2');
axis off
set(gca, 'FontSize', 24);
subplot 133
scatter(V3cartx,V3carty,'ko')
title('V3');
axis off
set(gca, 'FontSize', 24);
set(gca,'LineWidth',2)
set(gca, 'box', 'off');
set(gcf, 'color', 'w');
set(findobj(gcf,'type','axes'),'FontName','Arial', 'FontSize', 14, 'LineWidth', 1.5);
print(gcf, [pth, 'figures\fovConSites_',model,  '.png'], '-dpng', '-r150', '-painters')
print(gcf, [pth, 'figures\fovConSites_',model,  '.svg'], '-dsvg', '-r150', '-painters')


%% Project time series
% V1
ecc = msh.submesh.ecMap.v1;
pol = msh.submesh.polMap.v1;
idx_V1 = ecc  < maxEcc & ecc  > minEcc;
ecc_v1 = ecc(idx_V1);
pol_v1 = pol(idx_V1);
% V2
ecc = msh.submesh.ecMap.v2;
pol = msh.submesh.polMap.v2;
idx_V2 = ecc  < maxEcc & ecc  > minEcc;
ecc_v2 = ecc(idx_V2);
pol_v2 = pol(idx_V2);
% V3
ecc = msh.submesh.ecMap.v3;
pol = msh.submesh.polMap.v3;
idx_V3 = ecc  < maxEcc & ecc  > minEcc;
ecc_v3 = ecc(idx_V3);
pol_v3 = pol(idx_V3);


% Match simulated BOLD with algebraic model
[a_v1, ~] = knnsearch([ecc_v1 pol_v1],complexGrid','dist', distMethod,'NSMethod','exhaustive');
[a_v2, ~] = knnsearch([ecc_v2 pol_v2],complexGrid','dist', distMethod,'NSMethod','exhaustive');
[a_v3, ~] = knnsearch([ecc_v3 pol_v3],complexGrid','dist', distMethod,'NSMethod','exhaustive');

c = 0 ;
clear V1 V2 V3
for i_frame = 1:size( stimBOLD_output.BOLD,1)-4000
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
print(gcf, [pth, 'figures\tSeries_',model,  '.png'], '-dpng', '-r150', '-painters')


%%  BOLD time flow simulation onto foveal confluence model
v = VideoWriter('barMap2bold_FovealConfluence.avi');
open(v)
figure,
pos = get(gcf, 'Position');
%set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 24 24]);
set(gcf, 'Position', [0 0 1200, 1200]);
set(gcf, 'color', 'w');
colormap(nawhimar)
pause(1)
% set(gcf,'Renderer','Painters');
set(gcf,'Renderer','Zbuffer');
%set(gcf,'Renderer','OpenGL');
for i_frame = 1:10:size(V1,2)
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
    h = colorbar('YTickLabel',{'','','',''},...
        'FontSize',18,'Position',[0.9 .45 .05 .25],'Color','k');
    ylabel(h, ['BOLD ({\ita.u.}), frame: ' num2str(i_frame)],'FontSize',12); h.LineWidth = 1.5;
    frm = getframe(gcf);
    writeVideo(v,frm);
    %pause(0.1)
    clear gcf
    clf
end
close(v);
close 


%% Snapshot
i_frame = 4301;
%%
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
h = colorbar('YTickLabel',{'','','',''},...
    'FontSize',18,'Position',[0.9 .45 .05 .25],'Color','k');
ylabel(h, 'BOLD ({\ita.u.})','FontSize',12); h.LineWidth = 1.5;
set(findobj(gcf,'type','axes'),'FontName','Arial', 'FontSize', 14, 'LineWidth', 1.5);
print(gcf, [pth, 'figures\stHRF_BOLD_sim_', model,  '.png'], '-dpng', '-r150', '-painters')


%% ROIS

%V1
R = 1;
%idx = visualAreas.v1(idx_V1);
V1= msh.flatCoord(visualAreas.v1(idx_V1),:);
[~,v1] = alphavol(V1,R);


% V2 and V3
R = 0.15;
%idx = visualAreas.v2(idx_V2);
V2  = msh.flatCoord(visualAreas.v2(idx_V2),:);
[L,n] = kmeans(V2,2);
V2d = [V2(find(L==1),1) V2(find(L==1),2)];
V2v =[V2(find(L==2),1) V2(find(L==2),2)];
[~,v2d] = alphavol(V2d,R); [~,v2v] = alphavol(V2v,R);

%idx = visualAreas.v3(idx_V3);
%V3= msh.flatCoord(idx,:); 
V3  = msh.flatCoord(visualAreas.v3(idx_V3),:);
[L,n] = kmeans(V3,2);
V3d = [V3(find(L==1),1) V3(find(L==1),2)];
V3v =[V3(find(L==2),1) V3(find(L==2),2)];
[~,v3d] = alphavol(V3d,R); [~,v3v] = alphavol(V3v,R);


%% Plot cortical reconstruction of BOLD activity 
figure,
pos = get(gcf, 'Position');
set(gcf, 'Position', [0 0 1200, 1200]);
set(gcf, 'color', 'w');
%set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 12 12]); % Set plot sizetitle(['CF biophysical simulation arena']);
%set(gcf, 'color', 'w'); % Set figure background
%bar = [1:20:length(stimulus.seqtiming)]
dim = size(stimBOLD_output.BOLD)
bold = [1:10:dim(1)]
tri = stimBOLD_output.msh.submesh.triangles;
msh = stimBOLD_output.msh;
rnum = 2
cxlim =  max(stimBOLD_output.BOLD(:))/2;
set(gcf,'Renderer','OpenGL');
v = VideoWriter('barMap2bold_ROIs.avi');
open(v)

for id = 1:length(bold)
    i_frame = bold(id);
    X =  stimBOLD_output.BOLD(i_frame,:)'; %Y(i_frame,:)';
    X = round(X,rnum);
    %hold on
    patch('Vertices',msh.flatCoord,'Faces',msh.submesh.triangles.'+1,'FaceColor','interp','FaceVertexCData',msh.submesh.oldColors(1:3,:).'/255,'EdgeColor','none','facealpha',0.5);
    hold on   
    plot(V1(v1.bnd,1),V1(v1.bnd,2),'k-','LineWidth',2);
    plot(V2d(v2d.bnd,1),V2d(v2d.bnd,2),'k-','LineWidth',2);
    plot(V2v(v2v.bnd,1),V2v(v2v.bnd,2),'k-','LineWidth',2);
    plot(V3d(v3d.bnd,1),V3d(v3d.bnd,2),'k-','LineWidth',2);
    plot(V3v(v3v.bnd,1),V3v(v3v.bnd,2),'k-','LineWidth',2);
    trisurf(msh.submesh.triangles.'+1, msh.flatCoord(:,1), msh.flatCoord(:,2), zeros(size(msh.flatCoord(:,2),1),1),'facevertexcdata',X,'edgecolor','none','facecolor','flat','facealpha',0.5);
    colormap(nawhimar)
    lighting gouraud
    axis square;
    axis off
    caxis([-round(cxlim,rnum)  round(cxlim,rnum)]); % comment if plotting phase
    h = colorbar('YTickLabel',{'','','',''},...
        'FontSize',18,'Position',[0.9 .45 .05 .25],'Color','k');
    ylabel(h, ['BOLD ({\ita.u.}), frame: ' num2str(i_frame)],'FontSize',12); h.LineWidth = 1.5;
    frm = getframe(gcf);
    writeVideo(v,frm);
    %pause(0.1)
    clear gcf
    clf
end
close(v);






