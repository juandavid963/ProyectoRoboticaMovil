#INCLUDE <16F877A.h>
#FUSES NOWDT                    //No Watch Dog Timer
#FUSES HS                       //Cristal
#FUSES NOPROTECT                //Code not protected from reading
#FUSES NOBROWNOUT
#USE delay(clock=20000000)
#USE rs232(BAUD=9600,XMIT=PIN_C6,RCV=PIN_C7,BITS=8)

// variables recepcion serial
int a=0;                 // contador de recepcion
char dato_in[4];         // # de datos que recibo
int band_recepcion=0;    // bandera de recepcion
int band_conexion=0;     // bandera de conexion

// variable transmicion serial
int i=0;
char s[5];
unsigned int dato1=1;
unsigned int dato2=1;

// variables de direccion
signed int longitudinal=0,lateral=0,orientacion=0;
double adelante_derecha=0,adelante_izquierda=0,atras_derecha=0,atras_izquierda=0;

// variables de tiempo
long int preescaler=0;       // aumenta la interrupcion de tmr0


// interrupcion dato recibido por comunicacion serial
#INT_RDA 
void rda()
{    
   while(kbhit())
   {  dato_in[a]=getc();                              // obtener dato serial
      if(dato_in[a]==255) {dato_in[0]=255; a=0;}      // si el dato leido es 255, ordene la cadena empezando en 0  
      a++;                                            // aumente el contador de la cadena
      if(a==4)                                        // si ha llegado al maximo empieze nuevamente
       { a=0;                                         // reinicie el contador
         if(dato_in[0]==255) 
         {
            band_recepcion=1;                         // y active bandera de recepcion   
            band_conexion=1;                          // y active bandera de conexion
         }
       }
   }
}
   
// interrrupcion del tiempo timer0 cada 10 ms.   
#INT_RTCC  
void rtcc()
{  
   set_timer0(60);
   if(preescaler<9) preescaler++;     // 9->100ms  99->1s 999->10s
   else
   {
      if(band_conexion==0)
         {
            output_low(pin_A1);  // apago el motor igualando
            output_low(pin_A2);  // la direccion
            output_low(pin_A3);  // apago el motor igualando
            output_low(pin_A5);  // la direccion           
         }
      else band_conexion=0;
      preescaler=0;
   }
}

// funcion decodificar
signed int decod(char m)
{
   if(m<=254) m=m-127;
   return m;  
}

// funcion codificar
int codifica(double n)
{
return (int)((n+210)*0.607);
}


void main(void)
{  output_low(pin_C4);             // apago xbee
      
   disable_interrupts(INT_RDA);    // recepcion serial - xbee 
   disable_interrupts(INT_RTCC);   // interrupciones timer0 
   disable_interrupts(GLOBAL);     // interrupciones globales
   
   Port_B_Pullups(FALSE);          // resistencias Pullups desactivadas

   output_low(pin_A1);  // apago el motor igualando
   output_low(pin_A2);  // la direccion
   output_low(pin_A3);  // apago el motor igualando
   output_low(pin_A5);  // la direccion
      
   // Configuracion PWM
   setup_timer_2 (T2_DIV_BY_16,240,1); // Configuracion PWM - T2_DISABLED, T2_DIV_BY_1, T2_DIV_BY_4, T2_DIV_BY_16  5(NO) 50(mejoro) 240()
   setup_ccp2(CCP_PWM);                // CCP_PWM CCP_PWM_PLUS_1 CCP_PWM_PLUS_2  CCP_PWM_PLUS_3
   setup_ccp1(CCP_PWM);                // CCP_PWM CCP_PWM_PLUS_1 CCP_PWM_PLUS_2  CCP_PWM_PLUS_3
   set_pwm1_duty(0);                   // inicializo en 0
   set_pwm2_duty(0);                   // inicializo en 0

   setup_timer_0(RTCC_DIV_256);        // Configuracion Timer0 RTCC_DIV_2, RTCC_DIV_4, RTCC_DIV_8, RTCC_DIV_16, RTCC_DIV_32, RTCC_DIV_64, RTCC_DIV_128, RTCC_DIV_256
   
   enable_interrupts(INT_RTCC);     // habilito interrupcione timer0
   enable_interrupts(INT_RDA);      // recepcion serial - xbee
   enable_interrupts(GLOBAL);       // interrupciones globales
   delay_ms(100);
   output_high(pin_C4);             // enciendo xbee
   set_timer0(60);                  // Se inicializa y empiea a contar (0-255)
   
   while(1)
      {
               
         if(band_recepcion==1)
            {                 
               output_toggle(pin_C5);
               
               longitudinal=decod(dato_in[1]);
               lateral=decod(dato_in[2]);
               orientacion=decod(dato_in[3]);
               
               //movimientos llantas               
               adelante_derecha=((double)longitudinal-(double)lateral-(double)orientacion);
               adelante_izquierda=((double)longitudinal+(double)lateral+(double)orientacion);
               atras_derecha=((double)longitudinal+(double)lateral-(double)orientacion);
               atras_izquierda=((double)longitudinal-(double)lateral+(double)orientacion);


               if (longitudinal==124 && lateral==124 && orientacion==124)
                  {
                     output_low(pin_A1);  // apago el motor igualando
                     output_low(pin_A2);  // la direccion
                     output_low(pin_A3);  // apago el motor igualando
                     output_low(pin_A5);  // la direccion                                  
                  }
               else if (longitudinal==123 && lateral==123 && orientacion==123)
                  {
                     output_low(pin_A1);  // apago el motor igualando
                     output_low(pin_A2);  // la direccion
                     output_low(pin_A3);  // apago el motor igualando
                     output_low(pin_A5);  // la direccion  
                  }
               else
                  {                                                                  
                     //velocidad del motor 1
                     if (atras_izquierda<0) {output_high(pin_A3); output_low(pin_A5);}
                     else                   {output_high(pin_A5); output_low(pin_A3);}  
                     if (abs(atras_izquierda)>127) atras_izquierda=127;
                     set_pwm1_duty(((int)(((float)(abs(atras_izquierda))*2.00))));
                     
                     // velocidad del motor 2                             
                     if (adelante_izquierda<0)   {output_high(pin_A2); output_low(pin_A1);}
                     else                        {output_high(pin_A1); output_low(pin_A2);}
                     if (abs(adelante_izquierda)>127) adelante_izquierda=127;
                     set_pwm2_duty(((int)(((float)(abs(adelante_izquierda))*2.00)))); 
               }
                
               band_recepcion=0;                      
            }                                
      }
}
