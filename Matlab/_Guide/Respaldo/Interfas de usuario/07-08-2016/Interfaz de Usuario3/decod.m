function B=decod(A) 
% restricciones
if (A>=255) A=255; end
if (A<=0) A=0;end

B=(A/0.607)-210;
end