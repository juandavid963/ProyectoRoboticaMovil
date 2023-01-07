function b=encriptar(a) 
% restricciones
if (a>=127) a=127; end
if (a<=-127) a=-127;end
a=a+127;
b=a;
end

% encriptar datos de -100 a 100 para enviarlos como variables tipo char