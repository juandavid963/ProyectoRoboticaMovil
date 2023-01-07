function [B]=recibir_datos(PS,n)
A=fread(PS,n,'uint8')';
B=ones(1,length(A));
for i=1:n
    B(i)=decod(A(i));
end
end