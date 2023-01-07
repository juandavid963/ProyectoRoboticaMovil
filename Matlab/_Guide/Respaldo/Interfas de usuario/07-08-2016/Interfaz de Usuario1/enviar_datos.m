function enviar_datos(PS,d1,d2,d3)
d1=encrip(d1);
d2=encrip(d2);
d3=encrip(d3);
aa=[char(d1),char(d2),char(d3)];
fprintf(PS,'%s\r',aa);
end

% enviar 3 datos a traves de el puerto serie