img=imread('formas_1.jpg');
%img=imread('mujer.jpg');
im_g=rgb2gray(img);
umb=graythresh(im_g);
bw=im2bw(im_g,umb);
imshow(bw)
% etiqueta elementos conectados
[L Ne]=bwlabel(bw);
%Ne numero de elementos

% calcular propiedades de los objetos 
propied=regionprops(L)
hold on

for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
