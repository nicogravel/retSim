%% CF validation framework
% Make videos and pictures for BOLD simulations
%
% Nicolas Gravel 2024
% nicolas.gravel@gmail.com

close all
clear all

pth = 'barMapping/';
% mrVista stimulus parameter files
load('images.mat') ;
load('params.mat')



%% Prepare video
v = VideoWriter('barMap_whole.avi');
open(v)

figure,
pos = get(gcf, 'Position');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 8 8]); % Set plot size
set(gcf, 'color', 'w'); % Set figure background
colormap gray
%for idx = 1:20:length(stimulus.seqtiming)
for idx = 1:1:length(stimulus.seqtiming)
    frame = stimulus.seq(idx);
    stim = images(:,:,frame);
    idx = stim ==128;
    stim(~idx)=1;
    stim(~idx)=0;
    stim = stim(1:12:end,1:12:end);
    imagesc(stim); %colorbar;
    %axis square
    grid off
    axis off
    %pause(0.1)
    caxis([0 1]);
    frame = getframe(gcf);
    writeVideo(v,frame);
end
close(v);


%% Prepare input images
figure,
pos = get(gcf, 'Position');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 8 8]); % Set plot size
set(gcf, 'color', 'w'); % Set figure background
colormap gray
c =0;
for a = 1:60:length(stimulus.seqtiming)
    c = c +1;
    frame = stimulus.seq(a);
    stim = images(:,:,frame);
    idx = stim ==128;
    stim(~idx)=1;
    stim(~idx)=0;
    stim = stim(1:12:end,1:12:end);
    imagesc(stim); %colorbar;
    %axis square
    grid off
    axis off
    %pause(0.1)
    caxis([0 1]);
    fname = [pth num2str(c) '.jpg'];
    print( '-djpeg',fname, '-r100');
end
