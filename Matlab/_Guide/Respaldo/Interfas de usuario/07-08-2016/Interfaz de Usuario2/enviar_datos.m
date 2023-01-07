function enviar_datos(PS,d1,d2,d3)
d1=encriptar(d1);
d2=encriptar(d2);
d3=encriptar(d3);
if (PS~=0)    
    fwrite(PS,255);
    fwrite(PS,d1);
    fwrite(PS,d2);
    fwrite(PS,d3);
end
end

% enviar 3 datos a traves de el puerto serie