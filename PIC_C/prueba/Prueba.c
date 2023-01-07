#INCLUDE <16F877A.h>
#FUSES NOWDT                    //No Watch Dog Timer
#FUSES HS                       //Cristal
#FUSES NOPROTECT                //Code not protected from reading
#FUSES NOBROWNOUT
#USE delay(clock=20000000)
#DEFINE ledd pin_D2


void main(void)
{  
   while(1)
      {
          output_high(ledd);    // apago el xbee
          delay_ms(1000);
          output_low(ledd);    // apago el xbee
          delay_ms(1000);        
      }
}
