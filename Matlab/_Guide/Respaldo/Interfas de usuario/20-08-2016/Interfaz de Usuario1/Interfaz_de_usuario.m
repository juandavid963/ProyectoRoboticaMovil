function varargout = Interfaz_de_usuario(varargin)
% INTERFAZ_DE_USUARIO M-file for Interfaz_de_usuario.fig
%      INTERFAZ_DE_USUARIO, by itself, creates a new INTERFAZ_DE_USUARIO or raises the existing
%      singleton*.
%
%      H = INTERFAZ_DE_USUARIO returns the handle to a new INTERFAZ_DE_USUARIO or the handle to
%      the existing singleton*.
%
%      INTERFAZ_DE_USUARIO('CALLBACK',hObject,eventData,handle{{{{{{{{{{s,...) calls the local
%      function named CALLBACK in INTERFAZ_DE_USUARIO.M with the given input arguments.
%
%      INTERFAZ_DE_USUARIO('Property','Value',...) creates a new INTERFAZ_DE_USUARIO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Interfaz_de_usuario_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Interfaz_de_usuario_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help Interfaz_de_usuario
% Last Modified by GUIDE v2.5 07-Aug-2016 18:25:05
% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @Interfaz_de_usuario_OpeningFcn, ...
                       'gui_OutputFcn',  @Interfaz_de_usuario_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT


% --- Executes just before Interfaz_de_usuario is made visible.
function Interfaz_de_usuario_OpeningFcn(hObject, eventdata, handles, varargin)
    global cerrar;
    global vid_obj;
    global fin_proceso;
    global joys;

    fin_proceso=1;
    vid_obj=0;
    cerrar=0;
    clc

    % poner logos
    axes(handles.axes1);
    imagen=imread('universidad_surcolombiana.png'); 
    imagesc(imagen) 
    axis off 
    axes(handles.axes4);
    imagen=imread('ingenieria_electronica.png'); 
    imagesc(imagen) 
    axis off 

    % posicionar la figura en el centro de la imagen
    scrsz=get(0,'screensize');
    pos_act=get(gcf,'Position');
    xr=round((scrsz(3)-pos_act(3))/2);
    yr=round((scrsz(4)-pos_act(4))/2);
    set(gcf,'Position',[xr yr pos_act(3) pos_act(4)])
    figure(gcf);
    drawnow;

    % poner la informacion de las camaras web
    info=imaqhwinfo('winvideo');
    numero=size(info.DeviceInfo,2);
    nombres_cam=[];
    a=[];
    max=0;
    for i=1:numero
        a=info.DeviceInfo(1,i).DeviceName;
        if (length(a)>max) max=length(a); end
    end
    for i=1:numero
        a=info.DeviceInfo(1,i).DeviceName;
        while(length(a)<max) a=[a,' ']; end % dejar el mismo tama�o todos los string
        nombres_cam=[nombres_cam; a];
    end
    set(handles.camara_popupmenu,'String',nombres_cam);
    set(handles.formato_popupmenu,'String',info.DeviceInfo(1,1).SupportedFormats');
    set(handles.formato_popupmenu,'Value',3);
    configurar_camara(handles);

    % poner la informacion del puerto serial
    serialInfo=instrhwinfo('serial');
    if (strcmp(serialInfo.AvailableSerialPorts,' ')==0)
        set(handles.puerto_popupmenu,'String',serialInfo.AvailableSerialPorts);
    end
    configurar_puerto_serial(handles);

    % poner informacion del color del patron
    set(handles.patron_popupmenu,'String',['Negro ';'Blanco']);
    set(handles.patron_popupmenu,'Value',1);

    % iniciar el control joystick si existe
    try
        joys=vrjoystick(1);
    catch me
        joys='';    
    end

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Interfaz_de_usuario (see VARARGIN)
% Choose default command line output for Interfaz_de_usuario
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

    
% Funcion para configurar camara
function configurar_camara(handles)
    global vid_obj;
    num_cam=get(handles.camara_popupmenu,'Value');
    num_formato=get(handles.formato_popupmenu,'Value');
    info=imaqhwinfo('winvideo');
    formato=info.DeviceInfo(1,num_cam).SupportedFormats(num_formato);
    vid_obj=videoinput('winvideo',num_cam,char(formato));
    set(vid_obj,'FrameGrabInterval',1);
    set(vid_obj,'FramesPerTrigger',inf);
    set(vid_obj,'ReturnedColorspace','rgb');  % rgb grayscale

%Funcion para configurar puerto serial
function configurar_puerto_serial(handles)
    global PS
    numero_PS=get(handles.puerto_popupmenu,'Value');
    nombre_PS=char(get(handles.puerto_popupmenu,'String'));
    if (strcmp(nombre_PS,'Seleccione Puerto COM')==0)
        PS=serial(nombre_PS(numero_PS,:),'Baudrate',9600,'StopBits',1,'DataBits',8,'Parity','none');    
    else
        PS=0;
    end

%Funcion para dibujar los triangulos de la referencia
function dibujar_triangulos(handles)
    global imagen_referencia;

    %pongo imagen de referencia
    axes(handles.axes7);
    plot(0); imshow(imagen_referencia);

    datos=get(handles.uitable1,'Data');
    pixel_x=cell2mat(datos(:,1));
    pixel_y=cell2mat(datos(:,2));
    orientacion=cell2mat(datos(:,3));
    tam_imagen=size(imagen_referencia);
    a=round(0.04*tam_imagen(2));
    b=round(0.09*tam_imagen(2));

    axes(handles.axes7);
    for i=1:length(pixel_x)
        p1=[pixel_x(i)+(sqrt(2)*a*cos(deg2rad(-135-orientacion(i)))),pixel_y(i)-(sqrt(2)*a*sin(deg2rad(-135-orientacion(i))))];
        p2=[pixel_x(i)+(sqrt(2)*a*cos(deg2rad(-45-orientacion(i)))), pixel_y(i)-(sqrt(2)*a*sin(deg2rad(-45-orientacion(i))))];
        p3=[pixel_x(i)+(b*cos(deg2rad(90-orientacion(i)))), pixel_y(i)-(b*sin(deg2rad(90-orientacion(i))))];
        %pone el triangulo
        patch([p1(1);p2(1);p3(1)],[p1(2);p2(2);p3(2)],'r');     
    end

    %pone la linea
    for i=1:length(pixel_x)-1
        line([pixel_x(i); pixel_x(i+1)],[pixel_y(i); pixel_y(i+1)],'LineWidth',2,'LineStyle',':')
    end

    % pone la numeracion
    for i=1:length(pixel_x)
        text(pixel_x(i),pixel_y(i),num2str(i),'FontUnits','normalized','Fontsize',0.1,'FontWeight','bold','FontName','FixedWidth','HorizontalAlignment','center','Color','w');  
    end
   


%----------------------------------------------------------------------

% --- Executes on selection change in camara_popupmenu.
function camara_popupmenu_Callback(hObject, eventdata, handles)
    global imagen_referencia;
    num_cam=get(handles.camara_popupmenu,'Value');
    info=imaqhwinfo('winvideo');
    set(handles.formato_popupmenu,'String',info.DeviceInfo(1,num_cam).SupportedFormats');
    set(handles.formato_popupmenu,'Value',1);
    set(handles.formato_popupmenu,'Enable','on');
    axes(handles.axes7); plot(0);
    imagen_referencia=0;
    set(handles.uitable1,'data',cell(4,3));
    configurar_camara(handles);

% hObject    handle to camara_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns camara_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from camara_popupmenu


% --- Executes on selection change in formato_popupmenu.
function formato_popupmenu_Callback(hObject, eventdata, handles)
    global vid_obj;
    closepreview
    axes(handles.axes7); plot(0);
    imagen_referencia=0;
    set(handles.uitable1,'data',cell(4,3));
    configurar_camara(handles);
    preview(vid_obj);

% hObject    handle to formato_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns formato_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from formato_popupmenu


% --- Executes on selection change in puerto_popupmenu.
function puerto_popupmenu_Callback(hObject, eventdata, handles)
    configurar_puerto_serial(handles);
% hObject    handle to puerto_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns puerto_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        puerto_popupmenu


% --- Executes on button press in ref_pushbutton.
function ref_pushbutton_Callback(hObject, eventdata, handles)
    global vid_obj;
    global imagen_referencia;
    closepreview
    start(vid_obj);
    img=getsnapshot(vid_obj);
    imagen_referencia=img;
    alto=size(imagen_referencia,1);
    ancho=size(imagen_referencia,2);
    marco=8;
    stop(vid_obj); 
    flushdata(vid_obj);

    % Pintar marco filas
    for i=marco:ancho-marco
    img(marco,i,1)=255;
    img(marco,i,2)=255;
    img(marco,i,3)=255;
    img(alto-marco,i,1)=255;
    img(alto-marco,i,2)=255;
    img(alto-marco,i,3)=255;
    end

    % Pintar marco filas
    for i=marco:alto-marco
    img(i,marco,1)=255;
    img(i,marco,2)=255;
    img(i,marco,3)=255;
    img(i,ancho-marco,1)=255;
    img(i,ancho-marco,2)=255;
    img(i,ancho-marco,3)=255;
    end

    f=figure();
    set(f,'Menubar','none');
    set(f,'NumberTitle','off');
    set(f,'Name','Referencias');
    imshow(img,'Border','tight');
    jFig=get(handle(gcf),'JavaFrame');               
    figure(gcf);                     
    jFig.setMaximized(true);  
    hold on;

    try
        [x,y,pixel]=impixel(img);  % tomo los puntos (ultimo punto con click derecho)
        close(f);
    catch me
        return;
    end

    % construyo tabla
    filas=length(x);    
    tabla=cell(filas,3);
    for i=1:filas
        % si se escoge un punto por fuera de la imagen
        if(x(i)>ancho) x(i)=ancho; end
        if(x(i)<1) x(i)=1; end
        tabla(i,1)={x(i)};    

        % si se escoge un punto por fuera de la imagen
        if(y(i)>alto) y(i)=alto; end
        if(y(i)<1) y(i)=1; end
        tabla(i,2)={y(i)};    

        % angulo pro defecto 0
        tabla(i,3)={0};                   
    end
    set(handles.uitable1,'Data',tabla);
    set(handles.uitable1,'ColumnEditable',[false(1,2) true]);
    set(handles.uitable1,'Enable','on');

    % imprimo imagen
    dibujar_triangulos(handles);

%set(handles.uitable1,'Enable','on');
% hObject    handle to ref_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
    fila=eventdata.Indices(1);
    columna=eventdata.Indices(2);
    datos=get(handles.uitable1,'Data');

    try
        eventdata.NewData=eval(eventdata.EditData);  
    end

    if(isreal(eventdata.NewData)==0) % si es un numero imaginario
    	datos{fila,columna}=0; 
    elseif(isnan(eventdata.NewData)==1) % si est� vacio
    	datos{fila,columna}=0;
    else
    	datos{fila,columna}=round(eventdata.NewData); % redondea a un numero enter
    end
    set(handles.uitable1,'Data',datos);
    dibujar_triangulos(handles);
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in start_radiobutton.
function start_radiobutton_Callback(hObject, eventdata, handles)
    global cerrar;          % para cerrar el programa desde la ventana
    global vid_obj;         % objeto de video
    global PS;              % objeto del puerto serial
    global fin_proceso;     % para no entrar hasta que el programa haya terminado.
    global joys;            % variable del Joystick
    global control_automatico;

    closepreview
    
    % variables de control
    control_automatico=0;
    control_activar=1; % variable para tiempo de espera
    longitudinal=0;
    lateral=0;
    orientacion=0;

    if(get(handles.start_radiobutton,'Value')==1 && fin_proceso==1) 
        fin_proceso=0;
        % abro el puerto serial
        try
            fopen(PS);
        catch me   
            fin_proceso=1;
            mode = struct('WindowStyle','modal','Interpreter','tex');
            msgbox('Ocurrio un Error al abrir el PS','Error',mode); 
            set(handles.start_radiobutton,'Value',0);            
            return;                
        end    

        % desavilitar los "popmenu" y el boton de "imagen de referncia"
        set(handles.camara_popupmenu,'Enable','off');
        set(handles.formato_popupmenu,'Enable','off');
        set(handles.puerto_popupmenu,'Enable','off');
        set(handles.ref_pushbutton,'Enable','off');
        set(handles.uitable1,'ColumnEditable',false(1,3));
        set(handles.slider_umbral,'Enable','on');
        set(handles.text_umbral,'Enable','on');
        
        % empieza el objeto de video
        start(vid_obj);

        %iniciaclizo variable
        orientacion_buffer=ones(1,30);
        longitudinal_buffer=ones(1,30);
        lateral_buffer=ones(1,30); 

        % Variables de orientacion del robot  
        orientacion_mem=0;
        contador_vuelta=0;

        % variables de la tabla
        datos=get(handles.uitable1,'Data');
        pixel_x=cell2mat(datos(:,1));
        pixel_y=cell2mat(datos(:,2));
        orientacion_tabla=cell2mat(datos(:,3));
        k=1;        % contador de puntos
        k_mem=1;    % memoria para detectar cambio
        
        % variables de tiempo
        tiempo_inicial=cputime; % inicio para el control
        tiempo_cambio=0;         % tiempo para detectar cambio
        tiempo=0.080; % 80ms
        tiempo_real=0.1*ones(1,30); % vector que guarda el tiempo pasado
        tic;

    %------------%%------------%%------------%%------------%%------------%
        % CICLO PRINCIPAL
        while get(handles.start_radiobutton,'Value')==1              
            img=getsnapshot(vid_obj); % obtengo imagen de la camara
            flushdata(vid_obj); % libero datos del objeto de video        
            img_gris=rgb2gray(img); % convierto la imagen a escala de grises

            umb=get(handles.slider_umbral,'value'); % tomo umbral manual por slider
            set(handles.text_umbral,'String',round(100*umb)/100); % poner valor del humbral en el text 
            bw=im2bw(img_gris,umb);  %encuentro imagen a blanco y negro 
            area_imagen=size(bw,1)*size(bw,2); % area de la imagen segun el formato selecciondo

            % Contornos elementos conectados de la iamgen a blanco y negro
            [L1 N1]=bwlabel(bw);   % para los contornos blancos
            [L2 N2]=bwlabel(~bw);  % para los contornos negros
            % calcular propiedades de los objetos blancos y negros
            contornos_1=regionprops(L1,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength'); 
            contornos_2=regionprops(L2,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength');
            % unifico todos los contornos (blancos y negros)
            contornos=[contornos_1; contornos_2];  
            % variable para saber si en el ciclo encontro el patr�n 
            robot_encontrado=0;

            %graficar imagen
            axes(handles.axes6); imshow(bw);  % muestro imagen a blanco y negro
            hold on

            % Analisis de los contornos
            for i=1:length(contornos)
                if (contornos(i).Area > 15) % para filtrar ruido                
                    if(contornos(i).BoundingBox(3)*contornos(i).BoundingBox(4) < area_imagen*0.9) % excluir contornos grandes, que puedan contener otros contornos en su interior
                        x1=contornos(i).BoundingBox(1);
                        y1=contornos(i).BoundingBox(2);
                        x2=contornos(i).BoundingBox(1)+contornos(i).BoundingBox(3);
                        y2=contornos(i).BoundingBox(2)+contornos(i).BoundingBox(4);
                        contador_contornos=0; 
                        circulos=[]; % variable de los contornos que contienen los patrones circulares
                        for j=1:length(contornos)   % analiso los contornos internos
                            if(contornos(j).Area > 3) % ruido de contorno interior   
                                if(contornos(j).BoundingBox(1)>x1 && contornos(j).BoundingBox(1)<x2) % identifico los contornos dentro del cuadrado por BoundinBox
                                    if(contornos(j).BoundingBox(2)>y1 && contornos(j).BoundingBox(2)<y2) % identifico los contornos dentro del cuadrado por BoundinBox
                                        if(contornos(j).Centroid(1)>x1 && contornos(j).Centroid(1)<x2) % identifico los contornos dentro del cuadrado por Centroid
                                            if(contornos(j).Centroid(2)>y1 && contornos(j).Centroid(2)<y2) % identifico los contornos dentro del cuadrado por Centroid
                                                contador_contornos=contador_contornos+1; % cuento contornos
                                                circulos=[circulos j]; % guardo ubicacion del contorno interno
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if (contador_contornos==2) % si reconoce el patron con 2 contornos internos   
                            % organizar circulos (1) mas grande (2) mas peque�o
                            if (contornos(circulos(1)).Area < contornos(circulos(2)).Area) 
                                memoria_circulo=circulos(1);
                                circulos(1)=circulos(2);
                                circulos(2)=memoria_circulo;
                            end

                            % filtrar por el color de los circulos internos (0) Negro (1) Blanco 
                            color=get(handles.patron_popupmenu,'Value'); % optengo el color selccionado del popmenu
                            if (bw(floor(contornos(circulos(1)).Centroid(2)),floor(contornos(circulos(1)).Centroid(1)))==(color-1) && bw(floor(contornos(circulos(2)).Centroid(2)),floor(contornos(circulos(2)).Centroid(1)))== (color-1))
                                %calcular distancia entre dos puntos de referencia 
                                dist_2_puntos=sqrt((contornos(circulos(1)).Centroid(1)-contornos(circulos(2)).Centroid(1))^2+(contornos(circulos(1)).Centroid(2)-contornos(circulos(2)).Centroid(2))^2);                            
                                factor_cm_px=8.25/dist_2_puntos; %factor de conversion

                                %Calcula area real del patron en cm^2
                                AreaRectangulo=contornos(i).Area*factor_cm_px*factor_cm_px;
                                AreaCirculoGrande=contornos(circulos(1)).Area*factor_cm_px*factor_cm_px;
                                AreaCirculoPeque=contornos(circulos(2)).Area*factor_cm_px*factor_cm_px;
                                %disp([AreaRectangulo AreaCirculoGrande AreaCirculoPeque]);

                                %Filtro por area real
                                if (AreaRectangulo>90 && AreaRectangulo<130 && AreaCirculoGrande>7 && AreaCirculoGrande<20 && AreaCirculoPeque>2 && AreaCirculoPeque<15)
                                    robot_encontrado=1;
                                    % Dibuja patrones y centro
                                    rectangle('Position',[contornos(circulos(1)).Centroid 2 2],'EdgeColor','b','LineWidth',2);
                                    rectangle('Position',[contornos(circulos(2)).Centroid 2 2],'EdgeColor','r','LineWidth',2);
                                   
                                    % Calcula orientacion [-pi a pi]
                                    orientacion_robot=-round(rad2deg(atan2(-(contornos(circulos(1)).Centroid(2)-contornos(circulos(2)).Centroid(2)),(contornos(circulos(1)).Centroid(1)-contornos(circulos(2)).Centroid(1)))));                               
                                    if (abs(orientacion_robot)>90 && orientacion_robot<0 && orientacion_mem>0)
                                        contador_vuelta=contador_vuelta+1;
                                    end
                                    if (abs(orientacion_robot)>90 && orientacion_robot>0 && orientacion_mem<0)
                                        contador_vuelta=contador_vuelta-1;
                                    end                                                                                                
                                    orientacion_mem=orientacion_robot;
                                    orientacion_corregida=orientacion_robot+(360*contador_vuelta);  % orientacion corregida [-inf inf]
                                    
                                    
                                    %Calcular los puntos extremos del robot
                                    %Primer punto
                                    %coordeadas cartesianas
                                    robot_x1_prima=-15*(1/factor_cm_px);
                                    robot_y1_prima=30*(1/factor_cm_px); 
                                    %Pasar a polares
                                    [robot_t1_prima,robot_m1_prima]=cart2pol(robot_x1_prima,robot_y1_prima);
                                    %correccion de angulo
                                    robot_t1_prima=robot_t1_prima+deg2rad(-orientacion_corregida);
                                    %Pasar a cartesianas
                                    [robot_x1,robot_y1]=pol2cart(robot_t1_prima,robot_m1_prima);
                                    robot_x1=contornos(i).Centroid(1)+robot_x1;
                                    robot_y1=contornos(i).Centroid(2)-robot_y1;

                                    %Segundo punto
                                    %coordeadas cartesianas
                                    robot_x2_prima=15*(1/factor_cm_px);
                                    robot_y2_prima=30*(1/factor_cm_px); 
                                    %Pasar a polares
                                    [robot_t2_prima,robot_m2_prima]=cart2pol(robot_x2_prima,robot_y2_prima);
                                    %correccion de angulo
                                    robot_t2_prima=robot_t2_prima+deg2rad(-orientacion_corregida);
                                    %Pasar a cartesianas
                                    [robot_x2,robot_y2]=pol2cart(robot_t2_prima,robot_m2_prima);
                                    robot_x2=contornos(i).Centroid(1)+robot_x2;
                                    robot_y2=contornos(i).Centroid(2)-robot_y2;

                                    %Tercer punto
                                    %coordeadas cartesianas
                                    robot_x3_prima=15*(1/factor_cm_px);
                                    robot_y3_prima=-6*(1/factor_cm_px); 
                                    %Pasar a polares
                                    [robot_t3_prima,robot_m3_prima]=cart2pol(robot_x3_prima,robot_y3_prima);
                                    %correccion de angulo
                                    robot_t3_prima=robot_t3_prima+deg2rad(-orientacion_corregida);
                                    %Pasar a cartesianas
                                    [robot_x3,robot_y3]=pol2cart(robot_t3_prima,robot_m3_prima);
                                    robot_x3=contornos(i).Centroid(1)+robot_x3;
                                    robot_y3=contornos(i).Centroid(2)-robot_y3;

                                    %Cuarto punto
                                    %coordeadas cartesianas
                                    robot_x4_prima=-15*(1/factor_cm_px);
                                    robot_y4_prima=-6*(1/factor_cm_px); 
                                    %Pasar a polares
                                    [robot_t4_prima,robot_m4_prima]=cart2pol(robot_x4_prima,robot_y4_prima);
                                    %correccion de angulo
                                    robot_t4_prima=robot_t4_prima+deg2rad(-orientacion_corregida);
                                    %Pasar a cartesianas
                                    [robot_x4,robot_y4]=pol2cart(robot_t4_prima,robot_m4_prima);
                                    robot_x4=contornos(i).Centroid(1)+robot_x4;
                                    robot_y4=contornos(i).Centroid(2)-robot_y4;

                                    %grafica el contorno del robot
                                    line([robot_x1 robot_x2 robot_x3 robot_x4 robot_x1],[robot_y1 robot_y2 robot_y3 robot_y4 robot_y1],'LineWidth',2)
                                    %escribe el texto de la orientaci�n
                                    %text(contornos(i).Centroid(1),contornos(i).Centroid(2),int2str(orientacion_corregida),'Color','r','BackgroundColor','w','FontWeight','bold'); 
                                    
                                    %Posicion del centro del robot
                                    %coordeadas cartesianas
                                    centro_x_prima=0;
                                    centro_y_prima=8*(1/factor_cm_px); 
                                    %Pasar a polares
                                    [centro_t_prima,centro_m_prima]=cart2pol(centro_x_prima,centro_y_prima);
                                    %correccion de angulo
                                    centro_t_prima=centro_t_prima+deg2rad(-orientacion_corregida);
                                    %Pasar a cartesianas
                                    [centro_x,centro_y]=pol2cart(centro_t_prima,centro_m_prima);
                                    centro_x=contornos(i).Centroid(1)+centro_x;
                                    centro_y=contornos(i).Centroid(2)-centro_y;
                                    rectangle('Position',[centro_x-1 centro_y-1 2 2],'EdgeColor','g','LineWidth',2);
                                end
                            end                                                   
                        end
                    end
                end
             end

            % Control Automatico                               
            waypoint=length(cell2mat(datos(:,1)));  % saber si hay referencias                                  
            if (cputime-tiempo_inicial > 2 && waypoint~=0) % espero 2 segundos mientras se estabilza la camara
                if(get(handles.start_radiobutton,'Value')==1)
                    % habilito el control automatico
                    set(handles.control_pushbutton,'Enable','on'); 
                    if(control_automatico==1 && robot_encontrado==1) % si oprimio el boton de control automatico                        
                        line([centro_x pixel_x(k)],[centro_y pixel_y(k)],'Color','b','LineWidth',1)
                        
                        % distancias lateral y longitudinal
                        Dla=sqrt((pixel_x(k)-centro_x)^2+(centro_y-pixel_y(k))^2)*cos(atan2((centro_y-pixel_y(k)),(pixel_x(k)-centro_x))+deg2rad(orientacion_corregida));
                        Dlo=sqrt((pixel_x(k)-centro_x)^2+(centro_y-pixel_y(k))^2)*sin(atan2((centro_y-pixel_y(k)),(pixel_x(k)-centro_x))+deg2rad(orientacion_corregida));
                        
                        %linea lateral
                        P_Dla_x=centro_x+(abs(Dla)*cos(atan2(0,Dla)-deg2rad(orientacion_corregida)));
                        P_Dla_y=centro_y-(abs(Dla)*sin(atan2(0,Dla)-deg2rad(orientacion_corregida)));
                        line([centro_x P_Dla_x],[centro_y P_Dla_y],'Color','y','LineWidth',2)

                        %linea longitudinal
                        P_Dlo_x=centro_x+(abs(Dlo)*cos(atan2(Dlo,0)-deg2rad(orientacion_corregida)));
                        P_Dlo_y=centro_y-(abs(Dlo)*sin(atan2(Dlo,0)-deg2rad(orientacion_corregida)));
                        line([centro_x P_Dlo_x],[centro_y P_Dlo_y],'Color','g','LineWidth',2)
                        
                        % distancias lateral y longitudinal en cm
                        Dla_cm=Dla*factor_cm_px;
                        Dlo_cm=Dlo*factor_cm_px;
                     
                        % mientras no est� lo suficientemente cerca no puede pasar a la siguiente referencia
                        if(abs(centro_x-pixel_x(k))*factor_cm_px<10 && abs(centro_y-pixel_y(k))*factor_cm_px<10 && abs(orientacion_corregida-orientacion_tabla(k))<10)
                           k=k+1;                           
                           if(k_mem~=k)
                               tiempo_cambio=cputime;
                               control_activar=0;
                           end
                           if(k>waypoint) % aqui termina el ciclo 
                               k=1;
                               control_automatico=0;
                           end
                        end 
                        
                        if(cputime-tiempo_cambio>2 && cputime-tiempo_cambio<2.1)
                           control_activar=1;
                           k_mem=k;
                        end   
                        
                        % CONTROL AUTOMATICO
                        if (control_activar==1)
                            % control en orientacion
                            orientacion=control_orientacion(orientacion_tabla(k)-orientacion_corregida);
                            % control lateral
                            lateral=control_lateral(Dla_cm);
                            % control longitudinal
                            longitudinal=control_longitudinal(Dlo_cm);                        
                        else
                            orientacion=0;
                            lateral=0;     
                            longitudinal=0;
                        end
                    end                                                            
                end
            end

            %%%%%%%%%%%%%%
             axes(handles.axes6);
             hold off
            
            % si acab� la trayectoria debo detener los esfuerzos de control
            if (control_automatico==0)
                orientacion=0;
                lateral=0;
                longitudinal=0;                
            end
             
            
            %tomar datos de los slider o del control game 
            if(get(handles.manual_checkbox,'value')==1) % si el modo manual est� activado
                longitudinal=round(get(handles.longitudinal_slider,'value'));
                lateral=round(get(handles.lateral_slider,'value'));
                orientacion=round(get(handles.orientacion_slider,'value'));
                % si lo ssliders estan en 0 y un control joystick est� conectado
                if (longitudinal==0 && lateral==0 && orientacion==0 && ~isempty(joys))
                    longitudinal=round(axis(joys,2)*-127);
                    lateral=round(axis(joys,1)*127);
                    orientacion=round(axis(joys,3)*127);            
                    boton_1_montacarga=button(joys,1);
                    boton_2_montacarga=button(joys,4);
                    mov=pov(joys,1);
                    if(mov==0)      longitudinal=127;	lateral=0;      orientacion=0; end
                    if(mov==45)     longitudinal=127;	lateral=127;    orientacion=0; end
                    if(mov==90)     longitudinal=0;     lateral=127;    orientacion=0; end
                    if(mov==135)    longitudinal=-127;	lateral=127;    orientacion=0; end
                    if(mov==180)    longitudinal=-127;	lateral=0;      orientacion=0; end            
                    if(mov==225)    longitudinal=-127;	lateral=-127;   orientacion=0; end
                    if(mov==270)    longitudinal=0;     lateral=-127;   orientacion=0; end
                    if(mov==315)    longitudinal=127;   lateral=-127;   orientacion=0; end
                    %programacion movimiento del montacarga
                    if(boton_1_montacarga==1) longitudinal=124; lateral=124; orientacion=124; end
                    if(boton_2_montacarga==1) longitudinal=123; lateral=123; orientacion=123; end
                end
                % poner en los text los valores de los movimientos
                set(handles.orientacion_text,'string',orientacion);
                set(handles.longitudinal_text,'string',longitudinal);
                set(handles.lateral_text,'string',lateral);
            end

            % almacenar vector para plotear datos
            for i=1:29
                orientacion_buffer(i)=orientacion_buffer(i+1);   
                longitudinal_buffer(i)=longitudinal_buffer(i+1);  
                lateral_buffer(i)=lateral_buffer(i+1);  
            end
            orientacion_buffer(30)=orientacion;       
            longitudinal_buffer(30)=longitudinal;       
            lateral_buffer(30)=lateral;               
            % graficar historial de variables de control
            axes(handles.axes9); 
            plot([0 29],[0 0],(0:29),orientacion_buffer,(0:29),longitudinal_buffer,(0:29),lateral_buffer); 
            axis([0 29 -150 150]);

            %EnviaDatos
            try            
                enviar_datos(PS,longitudinal,lateral,orientacion);
            catch me
                start_radiobutton_Callback(hObject, eventdata, handles)
            end

%             %Recibir datos del PIC # bits
%             nb=PS.BytesAvailable;
%             if nb>=3             
%                 A=recibir_datos(PS,3);
%             end


            % vector tiempo control de tiempo
            for i=1:29
                tiempo_real(i)=tiempo_real(i+1);    
            end
            % graficar historial de tiempo 
            axes(handles.axes8);
            plot([0 29],[tiempo tiempo],(0:29),tiempo_real); 
            axis([0 30 0 0.2]);

            tiempo_real(30)=toc; 
            while tiempo_real(30)<tiempo                      
                tiempo_real(30)=toc;
            end             

            tic      
            set(handles.text7,'String',tiempo_real(30)*1000);
        end    
    %------------%%------------%%------------%%------------%%------------%   
        
        % borro las graficas
        axes(handles.axes6); plot(0);
        axes(handles.axes8); plot(0);
        axes(handles.axes9); plot(0);

        % cerrar el puerto
        try fclose(PS); end

        % cierra video
        stop(vid_obj);  
        flushdata(vid_obj); 

        if (cerrar==1)  % para salir del programa
            try delete(PS); end % cuando no hay seleccionado ninguno
            try close(joys); end% cuando no hay control
            clear PS;
            delete(vid_obj);
            % cierrar el programa
            delete(handles.figure1);
        end
        fin_proceso=1;
    else
        % si salgo del ciclo activas popmenus y botones
        set(handles.start_radiobutton,'Value',0);            
        set(handles.camara_popupmenu,'Enable','on');
        set(handles.formato_popupmenu,'Enable','on');
        set(handles.puerto_popupmenu,'Enable','on');
        set(handles.ref_pushbutton,'Enable','on');
        set(handles.slider_umbral,'Enable','off');
        set(handles.text_umbral,'Enable','off');
        set(handles.control_pushbutton,'Enable','off');
        set(handles.control_pushbutton,'Enable','off');
        set(handles.uitable1,'ColumnEditable',[false(1,2) true]);
    end

% hObject    handle to start_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of start_radiobutton



function orientacion=control_orientacion(orientacion_corregida)
orientacion=2*orientacion_corregida;
if orientacion>127 orientacion=127; end
if orientacion<-127 orientacion=-127; end

function lateral=control_lateral(Dla_cm)
lateral=4*Dla_cm;
if lateral>127 lateral=127; end
if lateral<-127 lateral=-127; end

function longitudinal=control_longitudinal(Dlo_cm)
longitudinal=4*Dlo_cm;
if longitudinal>127 longitudinal=127; end
if longitudinal<-127 longitudinal=-127; end

    
    

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
tamano_ventana=get(handles.figure1,'Position');
ancho_ventana=tamano_ventana(3);
tamano_tabla=get(handles.uitable1,'Position');
ancho_tabla=(tamano_tabla(3)*ancho_ventana)-55; % -30 del ancho de la primera colomna que "enumera las fila"
set(handles.uitable1,'ColumnWidth',{round(0.2*ancho_tabla) round(0.2*ancho_tabla) round(0.6*ancho_tabla)});
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global cerrar;
closepreview

if get(handles.start_radiobutton,'Value')==1 
    set(handles.start_radiobutton,'Value',0);
    cerrar=1;
    return
end
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
delete(hObject);



%------------------------------------------------------------------------

% --- Outputs from this function are returned to the command line.
function varargout = Interfaz_de_usuario_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function camara_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camara_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function formato_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to formato_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)

% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

% --- Executes during object creation, after setting all properties.
function axes5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes5

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



% --- Executes during object creation, after setting all properties.
function puerto_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puerto_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on uitable1 and none of its controls.
function uitable1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in manual_checkbox.
function manual_checkbox_Callback(hObject, eventdata, handles)

if (get(handles.manual_checkbox,'value')==1)
set(handles.orientacion_slider,'enable','on');
set(handles.longitudinal_slider,'enable','on');
set(handles.lateral_slider,'enable','on');

set(handles.text10,'enable','on');
set(handles.text11,'enable','on');
set(handles.text12,'enable','on');

set(handles.orientacion_text,'enable','on');
set(handles.longitudinal_text,'enable','on');
set(handles.lateral_text,'enable','on');    
else
set(handles.orientacion_slider,'enable','off');
set(handles.longitudinal_slider,'enable','off');
set(handles.lateral_slider,'enable','off');

set(handles.text10,'enable','off');
set(handles.text11,'enable','off');
set(handles.text12,'enable','off');

set(handles.orientacion_text,'enable','off');
set(handles.longitudinal_text,'enable','off');
set(handles.lateral_text,'enable','off');
end


% hObject    handle to manual_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manual_checkbox


% --- Executes on slider movement.
function longitudinal_slider_Callback(hObject, eventdata, handles)
%pause(0.1);
set(handles.longitudinal_slider,'value',0);
% hObject    handle to longitudinal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function longitudinal_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to longitudinal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function lateral_slider_Callback(hObject, eventdata, handles)
%pause(0.1);
set(handles.lateral_slider,'value',0);
% hObject    handle to lateral_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function lateral_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lateral_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function orientacion_slider_Callback(hObject, eventdata, handles)
%pause(0.1);
set(handles.orientacion_slider,'value',0);
% hObject    handle to orientacion_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function orientacion_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orientacion_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on slider movement.
function slider_umbral_Callback(hObject, eventdata, handles)

% hObject    handle to slider_umbral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_umbral_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_umbral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in patron_popupmenu.
function patron_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to patron_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns patron_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from patron_popupmenu


% --- Executes during object creation, after setting all properties.
function patron_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to patron_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in control_pushbutton.
function control_pushbutton_Callback(hObject, eventdata, handles)
global control_automatico;
control_automatico=1;
% hObject    handle to control_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


