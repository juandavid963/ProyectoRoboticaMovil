% unsando Image Acquisition Toolbox”

info=imaqhwinfo;   % informacion del dispocitivo de video, indica
                   % los drives con los que se puede trabajar: 
                   % InstalledAdaptors: {'coreco'  'winvideo'}                 
info=imaqhwinfo('winvideo');    % En el campo DeviceIDs y DeviceInfo se  
                                % puede obtener información detallada de
                                % los estándares de vídeo que soporta.
                                
                                
%%info.DeviceIDs
% [1]                                
%%info.DeviceInfo                                
%%info_dis = imaqhwinfo('winvideo',1)
%          DefaultFormat: 'RGB24_640x480'
%    DeviceFileSupported: 0
%             DeviceName: 'WebCam SC-13HDL11939N'
%               DeviceID: 1
%      ObjectConstructor: 'videoinput('winvideo', 1)'
%       SupportedFormats: {1x16 cell}

% crea un objeto de entrada de video
vidobj=videoinput('winvideo',1);
%antes de tomar imagenes es necesario ajustar la óptica, el diafragma, el
%sistema de iluminación, Para realizar estas tareas se requiere crear un canal de vídeo en
%línea, esto es, una ventana que muestre de forma continua la señal de
%vídeo
preview(vidobj); 
%Después de haber creado el objeto de vídeo y tener una ventana de vídeo en línea,
%se puede cambiar algunas características de la adquisición. Una lista de las propiedades de
%este proceso se puede ver con:
get(vidobj) 
% se optienen las propiedades de la captura

%para tomar 4 imagenes
start(vidobj); % inicializa el objeto de video
datos=getdata(vidobj,4); % obtiene los datos "toma 4 fotos"
imaqmontage (datos);    % muestra el montaje
stop(vidobj);           % para el objeto de video

%tomar una sola imagen
imgAdq = getsnapshot(vidobj);   
imshow(imgAdq) 
%En este caso la variable 'imgAdq' es una matriz que contiene la información de
%cada píxel de la imagen adquirida.

%cerrar liberar los recursos
closepreview(vidobj) 
delete(vidobj)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARA GUIDE
axes(handles.axes1);
imshow(imgEnt);


clear all
close all
x=0;
RGB=imread('mujer.jpg');
figure(1); imshow(RGB);
%hp=impixelinfo;
[x,y,pixel]=impixel
filas=length(x);
tabla=cell(filas,2);
for i=1:filas
tabla(i,1)=int2str(x(i));    
tabla(i,2)=int2str(y(i));    
end





impixel
pixval
improfile
IMDISTLINE
IMPIXELINFO

while(1)
hp = 
end

pixval on
findm(RGB)

winvid = videoinput('winvideo',1,'RGB24_640x480'); %YUY2_320x240 RGB24_640x480
preview(winvid);
winvid = videoinput('winvideo',1,'RGB24_160x120'); %YUY2_320x240 RGB24_640x480
preview(winvid);
capt1 = getsnapshot(winvid);
imshow(capt1);


vid = videoinput('winvideo',1);
vidRes = get(vid, 'VideoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);
nBands = get(vid, 'NumberOfBands');
%hImage = image( zeros(imHeight, imWidth, nBands),'Parent',handles.axes1);
preview(vid);