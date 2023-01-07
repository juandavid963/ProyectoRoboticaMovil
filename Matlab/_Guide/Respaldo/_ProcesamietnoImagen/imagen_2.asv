clear all
close all
x=0;
RGB=imread('mujer.jpg');
figure(1); imshow(RGB);
%hp=impixelinfo;
%x=[];
%y=[];
[x,y,pixel]=impixel(RGB)
filas=length(x);
tabla=cell(filas,2);    
for i=1:filas
tabla(i,1)={x(i)};    
tabla(i,2)={y(i)};    
end

for i=1:filas
text(x(i),y(i),'>')
end

w=ones(4,1);
h=ones(4,1);

rectangle('Position',[12 12 10 10],'Curvature', [1 1])
rectangle('Position',[120 120 10 10],'Curvature', [1 1])

x=100;
y=100;
A=[x-5,y+5];
B=[x+5,y+5];
C=[x,y-10];
patch([A(1); B(1); C(1)],[A(2);B(2);C(2)],'red');