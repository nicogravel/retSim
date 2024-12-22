function plotCartMapPhaseColored_test(cX,cY,origPhase,BOLD,v)
doHold=ishold(gca);
[B,II,JJ]=unique([cX;cY]','rows');
origPhase=origPhase(II);
cX=B(:,1);
cY=B(:,2);
lhemi=cY<0;
try
 t=delaunay(cX(lhemi),cY(lhemi));
 trisurf(t,cX(lhemi),cY(lhemi),zeros(length(cX(lhemi)),1),origPhase(lhemi));
catch
end
hold on;
try
 t=delaunay(cX(~lhemi),cY(~lhemi));
 trisurf(t,cX(~lhemi),cY(~lhemi),zeros(length(cX(~lhemi)),1),origPhase(~lhemi));
catch
end

     colormap(nawhimar)

 shading interp;
 %shading flat;
 %colormap hsv;
 rnum =2;
 cxlim =  max(BOLD(:))/2;

     caxis([-round(cxlim,rnum)  round(cxlim,rnum)]); % comment if plotting phase

 view(0,90);
 hold on
 if ~doHold
     hold off;
 end
 
 
axis off; axis equal;

lighting gouraud
    %axis 'image';
    %axis square;
    %grid off
    %axis off
    %view([240 -90]);
    
    
    
    caxis([-round(cxlim,rnum)  round(cxlim,rnum)]); % comment if plotting phase
    
    
    h = colorbar('YTickLabel',{'','','',''},...
        'FontSize',18,'Position',[0.85 .45 .05 .25],'Color','k');
    ylabel(h, 'BOLD ({\ita.u.})','FontSize',12); h.LineWidth = 1.5;
    frm = getframe(gcf);
    writeVideo(v,frm);
    %pause(0.1)
    clear gcf
    clf

return
