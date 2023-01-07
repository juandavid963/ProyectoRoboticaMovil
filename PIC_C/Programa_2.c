#INCLUDE <16F877A.h>
#FUSES NOWDT                    //No Watch Dog Timer
#FUSES HS                       //Cristal
#FUSES NOPROTECT                //Code not protected from reading
#FUSES NOBROWNOUT
#USE delay(clock=20000000)
#USE rs232(BAUD=9600,XMIT=PIN_C6,RCV=PIN_C7,BITS=8)
#INCLUDE <lcd.c>

// No. pic
int pic_1=0;

// variables recepcion serial
int a=0;                 // contador de recepcion
char dato_in[4];         // # de datos que recibo
int band_recepcion=0;    // bandera de recepcion
int band_conexion=0;     // bandera de conexion
int band_lcd_conexion=0; // bandera para escribir solo una vez desconectado

// variable transmicion serial
int i=0;
char s[5];
unsigned int dato1=1;
unsigned int dato2=1;

// variables de direccion
signed int longitudinal=0,lateral=0,orientacion=0;
double adelante_derecha=0,adelante_izquierda=0,atras_derecha=0,atras_izquierda=0;
double total_mayor=0;

// variables de tiempo
long int preescaler=0;       // aumenta la interrupcion de tmr0

// variables de encoder
signed long int counter_1=0,counter_2=0,counter_3=0,counter_4=0;
double velocidad_1,velocidad_2,velocidad_3,velocidad_4;
int band_velocidad=0;
boolean rb4=0,rb5=0,rb6=0,rb7=0;
boolean rb4_memoria=0,rb5_memoria=0,rb6_memoria=0,rb7_memoria=0;




// interrupcion de dato recibido por comunicacion serial
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
            band_lcd_conexion=0;                      // desactiva bandera de escitura en LCD "desactivado"
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
      if(band_conexion==0 && band_lcd_conexion==0)       // entra solo una vez cuando se desconecta
      {
         lcd_gotoxy(1,2); printf(lcd_putc,"                ");
         lcd_gotoxy(1,2); printf(lcd_putc,"  desconectado  ");
         band_lcd_conexion=1;
      }
      else band_conexion=0;
      
      output_toggle(pin_C5);
      
      //velocidad=counter;
      velocidad_1=counter_1;
      velocidad_2=counter_2;
      velocidad_3=counter_3;
      velocidad_4=counter_4;
      //velocidad_1=((double)counter_1/(0.1))*((double)1.0/360)*((double)60.0);   //(pulsos/seg)*(1rev/800pulsos)*(60seg/1min) RPM
      //velocidad_2=((double)counter_2/(0.1))*((double)1.0/360)*((double)60.0);   //(pulsos/seg)*(1rev/800pulsos)*(60seg/1min) RPM
      //velocidad_3=((double)counter_3/(0.1))*((double)1.0/360)*((double)60.0);   //(pulsos/seg)*(1rev/800pulsos)*(60seg/1min) RPM
      //velocidad_4=((double)counter_4/(0.1))*((double)1.0/360)*((double)60.0);   //(pulsos/seg)*(1rev/800pulsos)*(60seg/1min) RPM
      //counter_1=0;
      //counter_2=0;
      //counter_3=0;
      //counter_4=0;      
      preescaler=0;
      band_velocidad=1;
   }
}
   
// interrupcion del pin B0  
#INT_EXT
void ext()
{  
   //if(input(pin_E2)==1) counter_1++;
   //else counter_1--;
}

#INT_RB
void RB()
{
   rb4=input(pin_B4);
   rb5=input(pin_B5);
   rb6=input(pin_B6);
   rb7=input(pin_B7);
   
   if(rb4!=rb4_memoria && rb4==true) 
   {
      if(input(pin_B0)==true) counter_1++;
      else counter_1--;
   }

   if(rb5!=rb5_memoria && rb5==true) 
   {
      if(input(pin_B1)==true) counter_2++;
      else counter_2--;
   }

   if(rb6!=rb6_memoria && rb6==true) 
   {
      if(input(pin_B2)==true) counter_3++;
      else counter_3--;
   }
   
   if(rb7!=rb7_memoria && rb7==true) 
   {
      if(input(pin_B3)==true) counter_4++;
      else counter_4--;
   }
   
//   
   rb4_memoria=rb4;
   rb5_memoria=rb5;
   rb6_memoria=rb6;
   rb7_memoria=rb7;
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
{  output_low(pin_C4);             // apago xbee
   delay_ms(100);
   
   disable_interrupts(INT_RDA);    // recepcion serial - xbee
   disable_interrupts(GLOBAL);     // interrupciones globales 
   //enable_interrupts(INT_EXT);   // habilito interrupcion
   //ext_int_edge (H_TO_L);        // externa flanco de bajada
   disable_interrupts(INT_EXT);    // desactivo las interrupciones
   enable_interrupts(INT_RB);      // interrupcion puerto b RB<4:7>
   enable_interrupts(INT_RTCC);    // habilito interrupcione timer0 

   lcd_init();        // inicializo LCD
   
   Port_B_Pullups(FALSE);          // resistencias Pullups desactivadas

   output_low(pin_A1);  // apago el motor igualando
   output_low(pin_A2);  // la direccion
   output_low(pin_A3);  // apago el motor igualando
   output_low(pin_A5);  // la direccion
   output_low(pin_E1);  // apago el motor igualando
   output_low(pin_E2);  // la direccion
      
   setup_timer_2 (T2_DIV_BY_16,240,1); // Configuracion PWM - T2_DISABLED, T2_DIV_BY_1, T2_DIV_BY_4, T2_DIV_BY_16  5(NO) 50(mejoro) 240()
   setup_ccp2(CCP_PWM);                // CCP_PWM CCP_PWM_PLUS_1 CCP_PWM_PLUS_2  CCP_PWM_PLUS_3
   setup_ccp1(CCP_PWM);                // CCP_PWM CCP_PWM_PLUS_1 CCP_PWM_PLUS_2  CCP_PWM_PLUS_3
   set_pwm1_duty(0);                   // inicializo en 0
   set_pwm2_duty(0);                   // inicializo en 0

   setup_timer_0(RTCC_DIV_256);     // Configuracion Timer0 RTCC_DIV_2, RTCC_DIV_4, RTCC_DIV_8, RTCC_DIV_16, RTCC_DIV_32, RTCC_DIV_64, RTCC_DIV_128, RTCC_DIV_256
   
   printf(lcd_putc,"\f MONTACARGA-BOT \n  desconectado  ");   // mensaje de Bienbenida  
    
   set_timer0(60);                  // Se inicializa y empiea a contar (0-255)

   delay_ms(10);
   enable_interrupts(INT_RDA);     // recepcion serial - xbee 
   enable_interrupts(GLOBAL);      // interrupciones globales
   delay_ms(100);
   output_high(pin_C4); // enciendo xbee
   
   while(1)
      {
      
        if(band_velocidad==1)
            {  
               //lcd_gotoxy(1,1); printf(lcd_putc,"                ");
               //lcd_gotoxy(1,1); printf(lcd_putc,"v1:%2fRPM v2:%2fRPM v3:%2fRPM v4:%2fRPM",velocidad_1,velocidad_2,velocidad_3,velocidad_4);
               //lcd_gotoxy(1,1); printf(lcd_putc,"\fv1:%2.1f v2:%2.1f \nv3:%2.1f v4:%2.1f",velocidad_1,velocidad_2,velocidad_3,velocidad_4);
               band_velocidad=0;
            }
         
 
         if(band_recepcion==1)
            {  
               // enviar dato
               //putc(codifica(velocidad_1));
               //putc(codifica(velocidad_1));
               //putc(codifica(velocidad_1));
               //i++;
               //if(i==256)i=0;
               
               //output_toggle(pin_C3);
               
               longitudinal=decod(dato_in[1]);
               lateral=decod(dato_in[2]);
               orientacion=decod(dato_in[3]);
               lcd_gotoxy(1,2); printf(lcd_putc,"                ");
               lcd_gotoxy(1,2); printf(lcd_putc,"%04i  %04i  %04i",longitudinal,lateral,orientacion);
               
               //movimientos llantas               
               adelante_derecha=((double)longitudinal-(double)lateral-(double)orientacion);
               adelante_izquierda=((double)longitudinal+(double)lateral+(double)orientacion);
               atras_derecha=((double)longitudinal+(double)lateral-(double)orientacion);
               atras_izquierda=((double)longitudinal-(double)lateral+(double)orientacion);
               
               // encuentra el mayor
               /*total_mayor=abs(adelante_derecha);
               if(total_mayor<abs(adelante_izquierda)) total_mayor=abs(adelante_izquierda);
               if(total_mayor<abs(atras_derecha)) total_mayor=abs(atras_derecha);
               if(total_mayor<abs(atras_izquierda)) total_mayor=abs(atras_izquierda);

               if (abs(adelante_derecha)>254 || abs(adelante_izquierda)>254 || abs(atras_derecha)>254 || abs(atras_izquierda)>254)
               {
                  adelante_derecha=(adelante_derecha/total_mayor)*254;
                  adelante_izquierda=(adelante_izquierda/total_mayor)*254;
                  atras_derecha=(atras_derecha/total_mayor)*254;
                  atras_izquierda=(atras_izquierda/total_mayor)*254;
               }*/


               if (longitudinal==124 && lateral==124 && orientacion==124)
                  {
                     output_low(pin_A1);  // apago el motor igualando
                     output_low(pin_A2);  // la direccion
                     output_low(pin_A3);  // apago el motor igualando
                     output_low(pin_A5);  // la direccion

                     set_pwm2_duty(150);    // apago los 4 motores
                     output_high(pin_E1);  // apago el motor igualando
                     output_low(pin_E2);   // la direccion                                         
                  }
               else if (longitudinal==123 && lateral==123 && orientacion==123)
                  {
                     output_low(pin_A1);  // apago el motor igualando
                     output_low(pin_A2);  // la direccion
                     output_low(pin_A3);  // apago el motor igualando
                     output_low(pin_A5);  // la direccion

                     set_pwm2_duty(150);    // apago los 4 motores
                     output_low(pin_E1);   // apago el motor igualando
                     output_high(pin_E2);  // la direccion   
                  }
               else
                  {                         
                     output_low(pin_E1);  // apago el motor igualando
                     output_low(pin_E2);  // la direccion
                                          
                     if(pic_1==1)
                     {
                        //velocidad del motor 1
                        if (atras_izquierda<0) {output_high(pin_A1); output_low(pin_A2);}
                        else                   {output_high(pin_A2); output_low(pin_A1);}  
                        if (abs(atras_izquierda)>127) atras_izquierda=127;
                        set_pwm1_duty(((int)(((float)(abs(atras_izquierda))*2.00))));
                        
                        // velocidad del motor 2                             
                        if (adelante_izquierda<0)   {output_high(pin_A5); output_low(pin_A3);}
                        else                        {output_high(pin_A3); output_low(pin_A5);}
                        if (abs(adelante_izquierda)>127) adelante_izquierda=127;
                        set_pwm2_duty(((int)(((float)(abs(adelante_izquierda))*2.00)))); 
                     }
                     else
                     {
                        //velocidad del motor 3
                        if (atras_derecha<0)   {output_high(pin_A1); output_low(pin_A2);}
                        else                   {output_high(pin_A2); output_low(pin_A1);}  
                        if (abs(atras_derecha)>127) atras_derecha=127;
                        set_pwm1_duty(((int)(((float)(abs(atras_derecha))*2.00))));
                        
                        // velocidad del motor 4                             
                        if (adelante_derecha<0)   {output_high(pin_A5); output_low(pin_A3);}
                        else                      {output_high(pin_A3); output_low(pin_A5);}
                        if (abs(adelante_derecha)>127) adelante_derecha=127;
                        set_pwm2_duty(((int)(((float)(abs(adelante_derecha))*2.00)))); 
                     }                     
                  }
                
               band_recepcion=0;                      
            }                                
      }
}
