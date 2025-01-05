%% Visualization of BOLD time series onto the cortical surface
%
%  nicolas gravel, December 2024


%% Plot cortical reconstruction of BOLD activity
%V1
R = 1;
%idx = visualAreas.v1(idx_V1);
V1= msh.flatCoord(visualAreas.v1(idx_V1),:);
V1 = [V1(:,1)*-1, V1(:,2)];
[~,v1] = alphavol(V1,R);


% V2 and V3
R = 0.15;
%idx = visualAreas.v2(idx_V2);
V2  = msh.flatCoord(visualAreas.v2(idx_V2),:);
V2 = [V2(:,1)*-1, V2(:,2)];
[L,n] = kmeans(V2,2);
V2d = [V2(find(L==1),1) V2(find(L==1),2)];
V2v =[V2(find(L==2),1) V2(find(L==2),2)];
[~,v2d] = alphavol(V2d,R); [~,v2v] = alphavol(V2v,R);


%idx = visualAreas.v3(idx_V3);
%V3= msh.flatCoord(idx,:);
V3  = msh.flatCoord(visualAreas.v3(idx_V3),:);
V3 = [V3(:,1)*-1, V3(:,2)];
[L,n] = kmeans(V3,2);
V3d = [V3(find(L==1),1) V3(find(L==1),2)];
V3v =[V3(find(L==2),1) V3(find(L==2),2)];
[~,v3d] = alphavol(V3d,R); [~,v3v] = alphavol(V3v,R);

%% Plot flattened cortical surface
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
    coords = msh.flatCoord;
    coords = [coords(:,1)*-1, coords(:,2)];
    patch('Vertices',coords,'Faces',msh.submesh.triangles.'+1,'FaceColor','interp','FaceVertexCData',msh.submesh.oldColors(1:3,:).'/255,'EdgeColor','none','facealpha',0.5);
    hold on
    plot(V1(v1.bnd,1),V1(v1.bnd,2),'k-','LineWidth',2);
    plot(V2d(v2d.bnd,1),V2d(v2d.bnd,2),'k-','LineWidth',2);
    plot(V2v(v2v.bnd,1),V2v(v2v.bnd,2),'k-','LineWidth',2);
    plot(V3d(v3d.bnd,1),V3d(v3d.bnd,2),'k-','LineWidth',2);
    plot(V3v(v3v.bnd,1),V3v(v3v.bnd,2),'k-','LineWidth',2);
    trisurf(msh.submesh.triangles.'+1, coords(:,1), coords(:,2), zeros(size(msh.flatCoord(:,2),1),1),'facevertexcdata',X,'edgecolor','none','facecolor','flat','facealpha',0.5);
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

%% Cortical reconstruction snapshot
i_frame = 4301;
%%
figure,
pos = get(gcf, 'Position');
set(gcf, 'Position', [0 0 1200, 1200]);
set(gcf, 'color', 'w');
tri = stimBOLD_output.msh.submesh.triangles;
msh = stimBOLD_output.msh;
rnum = 2
cxlim =  max(stimBOLD_output.BOLD(:))/20;
set(gcf,'Renderer','OpenGL');
X =  stimBOLD_output.BOLD(i_frame,:)';
X = round(X,rnum);
%hold on
coords = msh.flatCoord;
coords = [coords(:,1)*-1, coords(:,2)];
patch('Vertices',coords,'Faces',msh.submesh.triangles.'+1,'FaceColor','interp','FaceVertexCData',msh.submesh.oldColors(1:3,:).'/255,'EdgeColor','none','facealpha',0.5);hold on
plot(V1(v1.bnd,1),V1(v1.bnd,2),'k-','LineWidth',2);
plot(V2d(v2d.bnd,1),V2d(v2d.bnd,2),'k-','LineWidth',2);
plot(V2v(v2v.bnd,1),V2v(v2v.bnd,2),'k-','LineWidth',2);
plot(V3d(v3d.bnd,1),V3d(v3d.bnd,2),'k-','LineWidth',2);
plot(V3v(v3v.bnd,1),V3v(v3v.bnd,2),'k-','LineWidth',2);
trisurf(msh.submesh.triangles.'+1, coords(:,1), coords(:,2), zeros(size(msh.flatCoord(:,2),1),1),'facevertexcdata',X,'edgecolor','none','facecolor','flat','facealpha',0.5);
colormap(nawhimar)
lighting gouraud
axis square;
axis off
caxis([-round(cxlim,rnum)  round(cxlim,rnum)]); % comment if plotting phase
h = colorbar('YTickLabel',{'','','',''},...
    'FontSize',18,'Position',[0.9 .45 .05 .25],'Color','k');
ylabel(h, ['BOLD ({\ita.u.}), frame: ' num2str(i_frame)],'FontSize',12); h.LineWidth = 1.5;
print(gcf, [pth, 'figures\stHRF_BOLD_sim_cortex.png'], '-dpng', '-r150', '-painters')





