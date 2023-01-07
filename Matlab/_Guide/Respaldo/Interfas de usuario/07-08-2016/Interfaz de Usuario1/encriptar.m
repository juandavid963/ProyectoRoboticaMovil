function b=encriptar(a) 
if (a>=100) a=100; end
if (a<=-100) a=-100;end
a=a+101;
if (a>=127)a=a+33;end
if (a>=13 && a<=126)a=a+1;end
b=a;
end

% encriptar datos de -100 a 100 para enviarlos como variables tipo char