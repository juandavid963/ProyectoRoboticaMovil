#INCLUDE <16F877A.h>
#FUSES NOWDT                    //No Watch Dog Timer
#FUSES HS                       //Cristal
#FUSES NOPROTECT                //Code not protected from reading
#FUSES NOBROWNOUT
#USE delay(clock=20000000)
#USE rs232(BAUD=9600,XMIT=PIN_C6,RCV=PIN_C7,BITS=8)
//#USE FAST_IO(E)
//#USE FIXED_IO (E_OUTPUTS = PIN_E2)
#INCLUDE <lcd.c>
#DEFINE xbee pin_C4

// variables recepcion serial
int i=0;                  // variable para organizar los datos
int a=0;
char dato_in[4];          // # de datos que recibo
char *p_din=&dato_in[0];  // para recibir el dato por la funcion gets()

// variable transmicion serial
char s[5];
unsigned int dato1=1;
unsigned int dato2=1;


signed int velocidad_1=0,velocidad_2=0,velocidad_3=0;
int band_recepcion=0,band_tiempo=0,band_encoder=0,band_velocidad=0;
char band_conexion=0,dato_inicial=0;   // variables para evitar las perturbaciones de recepcion
int preescaler=0;                      // aumentar la interrupcion de tmr0
signed long int counter=0;
double velocidad;
boolean direccion_1=1; // 1->sentidohorario 0->antihorario



int preescaler_2=0;  // para cuando el pic deje de recibir datos por mas de 10 segundos 



#INT_RDA // interrupcion de dato recibido por comunicacion serial
void rda()
{  
//   if(band_conexion==0){if(getc()==13) band_conexion=1;}
//   else {gets(p_din); band_recepcion=1;}  // se queda esperando hasta que llega un (\r) "retorno de carro"

//if(kbhit()) d1=getc();
//if(kbhit()) d2=getc();
//if(kbhit()) d3=getc();
//if(kbhit()) d4=getc();

while(kbhit())
{
   dato_in[a]=getc();
   if(dato_in[a]==255) {dato_in[0]=255; a=0;}
   a++;
   if(a==4) 
    { a=0; 
      if(dato_in[0]==255) band_recepcion=1;
    }
}


}
   
#INT_RTCC  // interrrupcion del tiempo timer0 cada 10 ms.
void rtcc()
   {  set_timer0(60);    
     //band_velocidad=1;   
     if(preescaler<9) // 9->100ms  99->1s
      {
         preescaler++;
      }
      else
      {           
         //output_toggle(pin_C3);                 
         //velocidad=((double)counter)/10.0;   
         //velocidad=counter;
         //velocidad=((double)counter)/8.0;          // Rev/seg
         //velocidad=(((double)counter)*60.0)/8.0;   // RPM  prescalerr 0 (10ms)
         velocidad=((double)counter/(0.1))*((double)1.0/800.0)*((double)60.0);   // RPM  prescalerr 10 (100ms)
         //printf ("%2.2f \r",velocidad);
         //putc("hrer");
         
         // codifico velocidad
         //velocidad
         
         //dato1=1;
         //dato2=1;
         //sprintf(s,"%c%c",dato1,dato2);         
         //sprintf(s,"%u %c %u %c",dato1,dato1,dato2,dato2);
         //puts(s);  
/*         if(band_conexion==1)
         {
            putc(i);
            putc(i);
            putc(i);
            i++;
            if(i==256)i=0;
         }
*/       
         output_toggle(pin_C5);
         //puts("ho");  // agraga h, o, retorno de carro (13), salto de linea (10)

         counter=0;
         preescaler=0;
         band_velocidad=1;
      }
   }
   

#INT_EXT
void ext()
{  
   if(input(pin_E2)==1) counter++;
   else counter--;
}


signed int decod(char m)
{
if(m<=254) m=m-127;
return m;  
}



int main(void)
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
    
   set_timer0(60);               // Se inicializa y empiea a contar (0-255)
   counter=0;                     // inicio el encoder
   
   while(1)
      {
      
        //printf ("Ju%c",54);
        if(band_velocidad==1)
            {  
               lcd_gotoxy (1,1);
               printf(lcd_putc,"                ");
               lcd_gotoxy (1,1);
               printf(lcd_putc,"v:%2.1fRPM",velocidad);
               band_velocidad=0;
            }
         
 
         if(band_recepcion==1)
            {                     
               output_toggle(pin_C3);
               
               //velocidad_1=decod(dato_in[1]);
               //velocidad_2=decod(dato_in[2]);
               //velocidad_3=decod(dato_in[3]);
               lcd_gotoxy (1,2);
               printf(lcd_putc,"                ");
               lcd_gotoxy (1,2);               
               //printf(lcd_putc,"%i %i %i",velocidad_1,velocidad_2,velocidad_3);
               printf(lcd_putc,"%d %d %d",decod(dato_in[1]),decod(dato_in[2]),decod(dato_in[3]));
               
               
               
                             
               if (velocidad_1<0){output_high(pin_A3); output_low(pin_A5);}
               else{output_high(pin_A5);output_low(pin_A3);} 
               set_pwm2_duty(((int)((float)(abs(velocidad_1))*2.55)));
               
               if (velocidad_2<0){output_high(pin_A1); output_low(pin_A2);}
               else{output_high(pin_A2);output_low(pin_A1);}               
               set_pwm1_duty(((int)((float)(abs(velocidad_2))*2.55)));

               if(velocidad_1==121 && velocidad_2==121 && velocidad_3==121) {delay_ms(10); reset_cpu();}    // reinicio al recibir este dato                  
               band_recepcion=0;                      
            }
            
            
            
            
            
         //PWM

         
         //if(kbhit()){dato_in=getc(); printf(lcd_putc,"%c",dato_in);} // obtener el dato dentro del ciclo
         
            //dato_out++;
              // un solo dato
             
            //puts("Juan Cerquer");  // varios datos
           //printf ("\fJuan%d",54);  // mejor funcion 
      }
}
