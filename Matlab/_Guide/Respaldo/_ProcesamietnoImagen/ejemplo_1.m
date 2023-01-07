clear all
close all
clc

vid=videoinput('winvideo',1);
set(vid,'FramesPerTrigger',inf);
set(vid,'ReturnedColorspace','rgb');
vid.FrameGrabInterval=1;
start(vid);
tic

while(1)   

    img=getsnapshot(vid);   
%img=getdata(vid,1);
subplot(2,2,1); imshow(img);
img_gris=rgb2gray(img);
img_gris=fliplr(img_gris);
subplot(2,2,2); imshow(img_gris);
img_gris_2=histeq(img_gris);
subplot(2,2,3); imshow(img_gris_2);
T=graythresh(img_gris_2);
img_bin=im2bw(img_gris_2,T);
subplot(2,2,4); imshow(img_bin);
toc
tic
end

%closepreview(vidobj) 
stop(vid);
flushdata(vid);
delete(vid);
clear vid img;
close all