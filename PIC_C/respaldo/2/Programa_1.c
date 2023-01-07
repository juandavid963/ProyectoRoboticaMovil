#INCLUDE <16F877A.h>
#FUSES NOWDT                    //No Watch Dog Timer
#FUSES HS                       //Cristal
#FUSES NOPROTECT                //Code not protected from reading
#FUSES NOBROWNOUT
#USE delay(clock=20000000)
#USE rs232(BAUD=9600,XMIT=PIN_C6,RCV=PIN_C7,BITS=8)
#INCLUDE <lcd.c>
#DEFINE xbee pin_C4

// variables recepcion serial
int a=0;                // contador de recepcion
char dato_in[4];        // # de datos que recibo
int band_recepcion=0;   // bandera de recepcion 

// variable transmicion serial
int i=0;
char s[5];
unsigned int dato1=1;
unsigned int dato2=1;

// variables de direccion
signed int longitudinal=0,lateral=0,orientacion=0;

// variables de tiempo
long int preescaler=0;       // aumenta la interrupcion de tmr0

// variables de encoder
signed long int counter=0;
double velocidad;
int band_velocidad=0;



// interrupcion de dato recibido por comunicacion serial
#INT_RDA 
void rda()
{  
   while(kbhit())
   {  dato_in[a]=getc();
      if(dato_in[a]==255) {dato_in[0]=255; a=0;}
      a++;
      if(a==4) 
       { a=0; 
         if(dato_in[0]==255) band_recepcion=1; 
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
      output_toggle(pin_C5);
      //velocidad=counter;
      velocidad=((double)counter/(0.1))*((double)1.0/800.0)*((double)60.0);   //(pulsos/seg)*(1rev/800pulsos)*(60seg/1min) RPM                         
      counter=0;
      preescaler=0;
      band_velocidad=1;
   }
}
   
// interrupcion del pin B0  
#INT_EXT
void ext()
{  
   if(input(pin_E2)==1) counter++;
   else counter--;
}

// funcion que decodifica
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
{ 
   output_low(xbee);    // apago el xbee
   output_low(pin_A3);  // apago el motor igualando
   output_low(pin_A5);  // la direccion
   set_tris_E(0b00000100);

   disable_interrupts(INT_EXT);     // desactivo las interrupciones
   disable_interrupts(INT_RTCC);    // externas B0, timer0
   disable_interrupts(INT_RDA);     // comunicacion serial
   disable_interrupts(GLOBAL);      // y Globales
   Port_B_Pullups(FALSE);          // resistencias Pullups desactivadas
   
   lcd_init();    // inicializo LCD      
      
   setup_timer_2 (T2_DIV_BY_16,240,1);  // Configuracion PWM - T2_DISABLED, T2_DIV_BY_1, T2_DIV_BY_4, T2_DIV_BY_16  5(NO) 50(mejoro) 240()
   setup_ccp2(CCP_PWM);                // CCP_PWM CCP_PWM_PLUS_1 CCP_PWM_PLUS_2  CCP_PWM_PLUS_3
   setup_ccp1(CCP_PWM);                // CCP_PWM CCP_PWM_PLUS_1 CCP_PWM_PLUS_2  CCP_PWM_PLUS_3
   set_pwm1_duty(0);                   // inicializo en 0
   set_pwm2_duty(0);                   // inicializo en 0

   setup_timer_0(RTCC_DIV_256);     // Configuracion Timer0 RTCC_DIV_2, RTCC_DIV_4, RTCC_DIV_8, RTCC_DIV_16, RTCC_DIV_32, RTCC_DIV_64, RTCC_DIV_128, RTCC_DIV_256

   printf(lcd_putc,"\f    Proyecto\n    Robotica");   // mensaje de Bienbenida
   delay_ms(1500); printf(lcd_putc,"\fEsperando\nConexion...");

   enable_interrupts(INT_EXT);     // habilito interrupcion
   ext_int_edge (H_TO_L);          // externa flanco de bajada
   enable_interrupts(INT_RTCC);    // habilito interrupcione timer0 
   enable_interrupts(INT_RDA);     // enciendo el xbee 
   enable_interrupts(GLOBAL);      // la primera conexion se 
   delay_ms(100);
   output_high(xbee);              // enciendo el Xbee
    
   set_timer0(60);                 // Se inicializa y empiea a contar (0-255)
   counter=0;                      // inicio el encoder
   
   while(1)
      {
      
        if(band_velocidad==1)
            {  
               lcd_gotoxy(1,1); printf(lcd_putc,"                ");
               lcd_gotoxy(1,1); printf(lcd_putc,"v:%2.1fRPM",velocidad);
               band_velocidad=0;
            }
         
 
         if(band_recepcion==1)
            {  
               // enviar dato
               putc(codifica(velocidad));
               putc(codifica(velocidad));
               putc(codifica(velocidad));
               //i++;
               //if(i==256)i=0;
               
               output_toggle(pin_C3);
               
               longitudinal=decod(dato_in[1]);
               lateral=decod(dato_in[2]);
               orientacion=decod(dato_in[3]);
               lcd_gotoxy(1,2); printf(lcd_putc,"                ");
               lcd_gotoxy(1,2); printf(lcd_putc,"%i %i %i",longitudinal,lateral,orientacion);
                                             
               // velocidad del motor 1                             
               if (longitudinal<0)  {output_high(pin_A5); output_low(pin_A3);}
               else                 {output_high(pin_A3); output_low(pin_A5);} 
               set_pwm2_duty(((int)((float)(abs(longitudinal))*2.0078)));
               
               //velocidad del motor 2
               if (lateral<0)       {output_high(pin_A1); output_low(pin_A2);}
               else                 {output_high(pin_A2); output_low(pin_A1);}               
               set_pwm1_duty(((int)((float)(abs(lateral))*2.0078)));
                 
               band_recepcion=0;                      
            }                                
      }
}
