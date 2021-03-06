
_interrupt:

;SmartMotorDriver.c,10 :: 		void interrupt() iv 0x0004 ics ICS_AUTO //interrupts
;SmartMotorDriver.c,12 :: 		if (INTCON.f0 == 1 && IOCAF.f4 == 1) //interrupt on change on RA4 triggered
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt2
	BTFSS      IOCAF+0, 4
	GOTO       L_interrupt2
L__interrupt32:
;SmartMotorDriver.c,14 :: 		INTCON.f3 = 0; //disable on change interrupts
	BCF        INTCON+0, 3
;SmartMotorDriver.c,15 :: 		counter ++;  //increment counter one in one
	INCF       _counter+0, 1
;SmartMotorDriver.c,16 :: 		IOCAF.f4 = 0; //clear interrupt flags
	BCF        IOCAF+0, 4
;SmartMotorDriver.c,17 :: 		INTCON.f3 = 1; //enable on change interrupts
	BSF        INTCON+0, 3
;SmartMotorDriver.c,18 :: 		}
L_interrupt2:
;SmartMotorDriver.c,19 :: 		if(PIR1.f0 == 1) //timer1 interrupt, called every 65.536ms
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt3
;SmartMotorDriver.c,21 :: 		INTCON.f3 = 0; //disable on change interrupts
	BCF        INTCON+0, 3
;SmartMotorDriver.c,22 :: 		T1CON.f0 =  0; //stop timer1
	BCF        T1CON+0, 0
;SmartMotorDriver.c,23 :: 		rpm = (counter * 300)/gear;  //calculate rpm  (multiplied 15 interrupts in 1 second, divided 3 encoder interrupts per lap, multiplied by 60 to convert to minutes, divided by gear ratio)
	MOVF       _counter+0, 0
	MOVWF      R0
	CLRF       R1
	MOVLW      44
	MOVWF      R4
	MOVLW      1
	MOVWF      R5
	CALL       _Mul_16X16_U+0
	MOVF       _gear+0, 0
	MOVWF      R4
	MOVF       _gear+1, 0
	MOVWF      R5
	CALL       _Div_16X16_U+0
	MOVF       R0, 0
	MOVWF      _rpm+0
	MOVF       R1, 0
	MOVWF      _rpm+1
;SmartMotorDriver.c,24 :: 		counter = 0;  //clear counter
	CLRF       _counter+0
;SmartMotorDriver.c,25 :: 		if(LATA.f0 == 0)
	BTFSC      LATA+0, 0
	GOTO       L_interrupt4
;SmartMotorDriver.c,27 :: 		rpm = rpm *-1;
	MOVF       _rpm+0, 0
	MOVWF      R0
	MOVF       _rpm+1, 0
	MOVWF      R1
	MOVLW      255
	MOVWF      R4
	MOVLW      255
	MOVWF      R5
	CALL       _Mul_16X16_U+0
	MOVF       R0, 0
	MOVWF      _rpm+0
	MOVF       R1, 0
	MOVWF      _rpm+1
;SmartMotorDriver.c,28 :: 		}
L_interrupt4:
;SmartMotorDriver.c,29 :: 		INTCON.f3 = 1; //enable on change interrupts
	BSF        INTCON+0, 3
;SmartMotorDriver.c,30 :: 		PIR1.f0 = 0; //clear interrutp flag
	BCF        PIR1+0, 0
;SmartMotorDriver.c,31 :: 		T1CON.f0 =  1; //start timer1
	BSF        T1CON+0, 0
;SmartMotorDriver.c,32 :: 		}
L_interrupt3:
;SmartMotorDriver.c,33 :: 		}
L_end_interrupt:
L__interrupt34:
	RETFIE     %s
; end of _interrupt

_main:

;SmartMotorDriver.c,38 :: 		void main()
;SmartMotorDriver.c,40 :: 		OSCCON = 0b11110000; //configure internal oscilator for 32Mhz
	MOVLW      240
	MOVWF      OSCCON+0
;SmartMotorDriver.c,41 :: 		TRISA = 0b00011000;  //configure IO
	MOVLW      24
	MOVWF      TRISA+0
;SmartMotorDriver.c,42 :: 		ANSELA = 0b00000000; //analog functions of pins disabled
	CLRF       ANSELA+0
;SmartMotorDriver.c,43 :: 		WPUA = 0b00011110;   //configure weak pull-ups on input pins
	MOVLW      30
	MOVWF      WPUA+0
;SmartMotorDriver.c,44 :: 		OPTION_REG.f7 = 0;   //enable weak pull-ups
	BCF        OPTION_REG+0, 7
;SmartMotorDriver.c,45 :: 		APFCON.f0 = 1;       //select RA5 as CCP output pin
	BSF        APFCON+0, 0
;SmartMotorDriver.c,46 :: 		LATA.f0 = 0;         //put motor direction pin to low
	BCF        LATA+0, 0
;SmartMotorDriver.c,47 :: 		PWM1_init(50000);    //confifure pwm frecuency
	BCF        T2CON+0, 0
	BCF        T2CON+0, 1
	MOVLW      159
	MOVWF      PR2+0
	CALL       _PWM1_Init+0
;SmartMotorDriver.c,48 :: 		PWM1_start();        //start pwm module
	CALL       _PWM1_Start+0
;SmartMotorDriver.c,49 :: 		PWM1_set_duty(0);    //put duty of pwm to 0
	CLRF       FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;SmartMotorDriver.c,50 :: 		IOCAN.f4 = 1;        //configure interrupt on falling edge for rpm meter
	BSF        IOCAN+0, 4
;SmartMotorDriver.c,51 :: 		INTCON = 0b01001000; //enables interrupts
	MOVLW      72
	MOVWF      INTCON+0
;SmartMotorDriver.c,52 :: 		T1CON = 0b00110100;  //configure timer1 to run at 1 MHz
	MOVLW      52
	MOVWF      T1CON+0
;SmartMotorDriver.c,53 :: 		PIE1.f0 =  1;        //enable timer1 interrupt
	BSF        PIE1+0, 0
;SmartMotorDriver.c,54 :: 		T1CON.f0 =  1;       //start timer1
	BSF        T1CON+0, 0
;SmartMotorDriver.c,55 :: 		INTCON.f7 = 1;       //run interrupts
	BSF        INTCON+0, 7
;SmartMotorDriver.c,57 :: 		M_control(0);        //ensure the motor is stopped at boot, extra step just in case
	CLRF       FARG_M_control_ctr+0
	CLRF       FARG_M_control_ctr+1
	CALL       _M_control+0
;SmartMotorDriver.c,60 :: 		while(1)
L_main5:
;SmartMotorDriver.c,62 :: 		int x = 0;
	CLRF       main_x_L1+0
	CLRF       main_x_L1+1
;SmartMotorDriver.c,63 :: 		for(x=0;x<1000;x++)
	CLRF       main_x_L1+0
	CLRF       main_x_L1+1
L_main7:
	MOVLW      128
	XORWF      main_x_L1+1, 0
	MOVWF      R0
	MOVLW      128
	XORLW      3
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main36
	MOVLW      232
	SUBWF      main_x_L1+0, 0
L__main36:
	BTFSC      STATUS+0, 0
	GOTO       L_main8
;SmartMotorDriver.c,65 :: 		PID(150);
	MOVLW      150
	MOVWF      FARG_PID_ctr+0
	CLRF       FARG_PID_ctr+1
	CALL       _PID+0
;SmartMotorDriver.c,66 :: 		delay_ms(10);
	MOVLW      104
	MOVWF      R12
	MOVLW      228
	MOVWF      R13
L_main10:
	DECFSZ     R13, 1
	GOTO       L_main10
	DECFSZ     R12, 1
	GOTO       L_main10
	NOP
;SmartMotorDriver.c,63 :: 		for(x=0;x<1000;x++)
	INCF       main_x_L1+0, 1
	BTFSC      STATUS+0, 2
	INCF       main_x_L1+1, 1
;SmartMotorDriver.c,67 :: 		}
	GOTO       L_main7
L_main8:
;SmartMotorDriver.c,68 :: 		for(x=0;x<500;x++)
	CLRF       main_x_L1+0
	CLRF       main_x_L1+1
L_main11:
	MOVLW      128
	XORWF      main_x_L1+1, 0
	MOVWF      R0
	MOVLW      128
	XORLW      1
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main37
	MOVLW      244
	SUBWF      main_x_L1+0, 0
L__main37:
	BTFSC      STATUS+0, 0
	GOTO       L_main12
;SmartMotorDriver.c,70 :: 		PID(0);
	CLRF       FARG_PID_ctr+0
	CLRF       FARG_PID_ctr+1
	CALL       _PID+0
;SmartMotorDriver.c,71 :: 		delay_ms(10);
	MOVLW      104
	MOVWF      R12
	MOVLW      228
	MOVWF      R13
L_main14:
	DECFSZ     R13, 1
	GOTO       L_main14
	DECFSZ     R12, 1
	GOTO       L_main14
	NOP
;SmartMotorDriver.c,68 :: 		for(x=0;x<500;x++)
	INCF       main_x_L1+0, 1
	BTFSC      STATUS+0, 2
	INCF       main_x_L1+1, 1
;SmartMotorDriver.c,72 :: 		}
	GOTO       L_main11
L_main12:
;SmartMotorDriver.c,73 :: 		for(x=0;x<1000;x++)
	CLRF       main_x_L1+0
	CLRF       main_x_L1+1
L_main15:
	MOVLW      128
	XORWF      main_x_L1+1, 0
	MOVWF      R0
	MOVLW      128
	XORLW      3
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main38
	MOVLW      232
	SUBWF      main_x_L1+0, 0
L__main38:
	BTFSC      STATUS+0, 0
	GOTO       L_main16
;SmartMotorDriver.c,75 :: 		PID(-150);
	MOVLW      106
	MOVWF      FARG_PID_ctr+0
	MOVLW      255
	MOVWF      FARG_PID_ctr+1
	CALL       _PID+0
;SmartMotorDriver.c,76 :: 		delay_ms(10);
	MOVLW      104
	MOVWF      R12
	MOVLW      228
	MOVWF      R13
L_main18:
	DECFSZ     R13, 1
	GOTO       L_main18
	DECFSZ     R12, 1
	GOTO       L_main18
	NOP
;SmartMotorDriver.c,73 :: 		for(x=0;x<1000;x++)
	INCF       main_x_L1+0, 1
	BTFSC      STATUS+0, 2
	INCF       main_x_L1+1, 1
;SmartMotorDriver.c,77 :: 		}
	GOTO       L_main15
L_main16:
;SmartMotorDriver.c,78 :: 		for(x=0;x<500;x++)
	CLRF       main_x_L1+0
	CLRF       main_x_L1+1
L_main19:
	MOVLW      128
	XORWF      main_x_L1+1, 0
	MOVWF      R0
	MOVLW      128
	XORLW      1
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main39
	MOVLW      244
	SUBWF      main_x_L1+0, 0
L__main39:
	BTFSC      STATUS+0, 0
	GOTO       L_main20
;SmartMotorDriver.c,80 :: 		PID(0);
	CLRF       FARG_PID_ctr+0
	CLRF       FARG_PID_ctr+1
	CALL       _PID+0
;SmartMotorDriver.c,81 :: 		delay_ms(10);
	MOVLW      104
	MOVWF      R12
	MOVLW      228
	MOVWF      R13
L_main22:
	DECFSZ     R13, 1
	GOTO       L_main22
	DECFSZ     R12, 1
	GOTO       L_main22
	NOP
;SmartMotorDriver.c,78 :: 		for(x=0;x<500;x++)
	INCF       main_x_L1+0, 1
	BTFSC      STATUS+0, 2
	INCF       main_x_L1+1, 1
;SmartMotorDriver.c,82 :: 		}
	GOTO       L_main19
L_main20:
;SmartMotorDriver.c,83 :: 		}
	GOTO       L_main5
;SmartMotorDriver.c,86 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_PID:

;SmartMotorDriver.c,88 :: 		void PID(int set) //PID calculation function
;SmartMotorDriver.c,90 :: 		float error = 0;
;SmartMotorDriver.c,91 :: 		float PID = 0;
	CLRF       PID_PID_L0+0
	CLRF       PID_PID_L0+1
	CLRF       PID_PID_L0+2
	CLRF       PID_PID_L0+3
;SmartMotorDriver.c,92 :: 		int rpm2 = rpm + 600;
	MOVLW      88
	ADDWF      _rpm+0, 0
	MOVWF      R2
	MOVLW      2
	ADDWFC     _rpm+1, 0
	MOVWF      R3
	MOVF       R2, 0
	MOVWF      PID_rpm2_L0+0
	MOVF       R3, 0
	MOVWF      PID_rpm2_L0+1
;SmartMotorDriver.c,93 :: 		set = set + 600;
	MOVLW      88
	ADDWF      FARG_PID_set+0, 0
	MOVWF      R0
	MOVLW      2
	ADDWFC     FARG_PID_set+1, 0
	MOVWF      R1
	MOVF       R0, 0
	MOVWF      FARG_PID_set+0
	MOVF       R1, 0
	MOVWF      FARG_PID_set+1
;SmartMotorDriver.c,94 :: 		error = set-rpm2; //calculate actual error
	MOVF       R2, 0
	SUBWF      R0, 1
	MOVF       R3, 0
	SUBWFB     R1, 1
	CALL       _int2double+0
	MOVF       R0, 0
	MOVWF      FLOC__PID+4
	MOVF       R1, 0
	MOVWF      FLOC__PID+5
	MOVF       R2, 0
	MOVWF      FLOC__PID+6
	MOVF       R3, 0
	MOVWF      FLOC__PID+7
	MOVF       FLOC__PID+4, 0
	MOVWF      R0
	MOVF       FLOC__PID+5, 0
	MOVWF      R1
	MOVF       FLOC__PID+6, 0
	MOVWF      R2
	MOVF       FLOC__PID+7, 0
	MOVWF      R3
	MOVF       _kp+0, 0
	MOVWF      R4
	MOVF       _kp+1, 0
	MOVWF      R5
	MOVF       _kp+2, 0
	MOVWF      R6
	MOVF       _kp+3, 0
	MOVWF      R7
	CALL       _Mul_32x32_FP+0
	MOVF       R0, 0
	MOVWF      FLOC__PID+0
	MOVF       R1, 0
	MOVWF      FLOC__PID+1
	MOVF       R2, 0
	MOVWF      FLOC__PID+2
	MOVF       R3, 0
	MOVWF      FLOC__PID+3
	MOVF       FLOC__PID+0, 0
	MOVWF      PID_PID_L0+0
	MOVF       FLOC__PID+1, 0
	MOVWF      PID_PID_L0+1
	MOVF       FLOC__PID+2, 0
	MOVWF      PID_PID_L0+2
	MOVF       FLOC__PID+3, 0
	MOVWF      PID_PID_L0+3
;SmartMotorDriver.c,96 :: 		accumulator += error;  // calculate accumulator, is sum of errors
	MOVF       _accumulator+0, 0
	MOVWF      R0
	MOVF       _accumulator+1, 0
	MOVWF      R1
	MOVF       _accumulator+2, 0
	MOVWF      R2
	MOVF       _accumulator+3, 0
	MOVWF      R3
	MOVF       FLOC__PID+4, 0
	MOVWF      R4
	MOVF       FLOC__PID+5, 0
	MOVWF      R5
	MOVF       FLOC__PID+6, 0
	MOVWF      R6
	MOVF       FLOC__PID+7, 0
	MOVWF      R7
	CALL       _Add_32x32_FP+0
	MOVF       R0, 0
	MOVWF      _accumulator+0
	MOVF       R1, 0
	MOVWF      _accumulator+1
	MOVF       R2, 0
	MOVWF      _accumulator+2
	MOVF       R3, 0
	MOVWF      _accumulator+3
;SmartMotorDriver.c,97 :: 		PID += ki*accumulator; // add integral gain and error accumulator
	MOVF       _ki+0, 0
	MOVWF      R4
	MOVF       _ki+1, 0
	MOVWF      R5
	MOVF       _ki+2, 0
	MOVWF      R6
	MOVF       _ki+3, 0
	MOVWF      R7
	CALL       _Mul_32x32_FP+0
	MOVF       FLOC__PID+0, 0
	MOVWF      R4
	MOVF       FLOC__PID+1, 0
	MOVWF      R5
	MOVF       FLOC__PID+2, 0
	MOVWF      R6
	MOVF       FLOC__PID+3, 0
	MOVWF      R7
	CALL       _Add_32x32_FP+0
	MOVF       R0, 0
	MOVWF      FLOC__PID+0
	MOVF       R1, 0
	MOVWF      FLOC__PID+1
	MOVF       R2, 0
	MOVWF      FLOC__PID+2
	MOVF       R3, 0
	MOVWF      FLOC__PID+3
	MOVF       FLOC__PID+0, 0
	MOVWF      PID_PID_L0+0
	MOVF       FLOC__PID+1, 0
	MOVWF      PID_PID_L0+1
	MOVF       FLOC__PID+2, 0
	MOVWF      PID_PID_L0+2
	MOVF       FLOC__PID+3, 0
	MOVWF      PID_PID_L0+3
;SmartMotorDriver.c,98 :: 		PID += kd*(error-lasterror); //add differential gain
	MOVF       _lasterror+0, 0
	MOVWF      R4
	MOVF       _lasterror+1, 0
	MOVWF      R5
	MOVF       _lasterror+2, 0
	MOVWF      R6
	MOVF       _lasterror+3, 0
	MOVWF      R7
	MOVF       FLOC__PID+4, 0
	MOVWF      R0
	MOVF       FLOC__PID+5, 0
	MOVWF      R1
	MOVF       FLOC__PID+6, 0
	MOVWF      R2
	MOVF       FLOC__PID+7, 0
	MOVWF      R3
	CALL       _Sub_32x32_FP+0
	MOVF       _kd+0, 0
	MOVWF      R4
	MOVF       _kd+1, 0
	MOVWF      R5
	MOVF       _kd+2, 0
	MOVWF      R6
	MOVF       _kd+3, 0
	MOVWF      R7
	CALL       _Mul_32x32_FP+0
	MOVF       FLOC__PID+0, 0
	MOVWF      R4
	MOVF       FLOC__PID+1, 0
	MOVWF      R5
	MOVF       FLOC__PID+2, 0
	MOVWF      R6
	MOVF       FLOC__PID+3, 0
	MOVWF      R7
	CALL       _Add_32x32_FP+0
	MOVF       R0, 0
	MOVWF      PID_PID_L0+0
	MOVF       R1, 0
	MOVWF      PID_PID_L0+1
	MOVF       R2, 0
	MOVWF      PID_PID_L0+2
	MOVF       R3, 0
	MOVWF      PID_PID_L0+3
;SmartMotorDriver.c,99 :: 		lasterror = error; //save the error to the next iteration
	MOVF       FLOC__PID+4, 0
	MOVWF      _lasterror+0
	MOVF       FLOC__PID+5, 0
	MOVWF      _lasterror+1
	MOVF       FLOC__PID+6, 0
	MOVWF      _lasterror+2
	MOVF       FLOC__PID+7, 0
	MOVWF      _lasterror+3
;SmartMotorDriver.c,100 :: 		if(PID >= 511)   //next we guarantee that the PID value is in range
	MOVLW      0
	MOVWF      R4
	MOVLW      128
	MOVWF      R5
	MOVLW      127
	MOVWF      R6
	MOVLW      135
	MOVWF      R7
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSS      STATUS+0, 0
	MOVLW      0
	MOVWF      R0
	MOVF       R0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_PID23
;SmartMotorDriver.c,102 :: 		PID = 511;
	MOVLW      0
	MOVWF      PID_PID_L0+0
	MOVLW      128
	MOVWF      PID_PID_L0+1
	MOVLW      127
	MOVWF      PID_PID_L0+2
	MOVLW      135
	MOVWF      PID_PID_L0+3
;SmartMotorDriver.c,103 :: 		}
L_PID23:
;SmartMotorDriver.c,104 :: 		if(PID <= 0)
	MOVF       PID_PID_L0+0, 0
	MOVWF      R4
	MOVF       PID_PID_L0+1, 0
	MOVWF      R5
	MOVF       PID_PID_L0+2, 0
	MOVWF      R6
	MOVF       PID_PID_L0+3, 0
	MOVWF      R7
	CLRF       R0
	CLRF       R1
	CLRF       R2
	CLRF       R3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSS      STATUS+0, 0
	MOVLW      0
	MOVWF      R0
	MOVF       R0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_PID24
;SmartMotorDriver.c,106 :: 		PID = 0;
	CLRF       PID_PID_L0+0
	CLRF       PID_PID_L0+1
	CLRF       PID_PID_L0+2
	CLRF       PID_PID_L0+3
;SmartMotorDriver.c,107 :: 		}
L_PID24:
;SmartMotorDriver.c,108 :: 		PID = (-255+((510)*((PID)/(511)))); //scale PID result from 0,511 to -255,255
	MOVLW      0
	MOVWF      R4
	MOVLW      128
	MOVWF      R5
	MOVLW      127
	MOVWF      R6
	MOVLW      135
	MOVWF      R7
	MOVF       PID_PID_L0+0, 0
	MOVWF      R0
	MOVF       PID_PID_L0+1, 0
	MOVWF      R1
	MOVF       PID_PID_L0+2, 0
	MOVWF      R2
	MOVF       PID_PID_L0+3, 0
	MOVWF      R3
	CALL       _Div_32x32_FP+0
	MOVLW      0
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	MOVLW      127
	MOVWF      R6
	MOVLW      135
	MOVWF      R7
	CALL       _Mul_32x32_FP+0
	MOVLW      0
	MOVWF      R4
	MOVLW      0
	MOVWF      R5
	MOVLW      255
	MOVWF      R6
	MOVLW      134
	MOVWF      R7
	CALL       _Add_32x32_FP+0
	MOVF       R0, 0
	MOVWF      PID_PID_L0+0
	MOVF       R1, 0
	MOVWF      PID_PID_L0+1
	MOVF       R2, 0
	MOVWF      PID_PID_L0+2
	MOVF       R3, 0
	MOVWF      PID_PID_L0+3
;SmartMotorDriver.c,109 :: 		if(set < 600)
	MOVLW      128
	XORWF      FARG_PID_set+1, 0
	MOVWF      R0
	MOVLW      128
	XORLW      2
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__PID41
	MOVLW      88
	SUBWF      FARG_PID_set+0, 0
L__PID41:
	BTFSC      STATUS+0, 0
	GOTO       L_PID25
;SmartMotorDriver.c,111 :: 		if(PID > 0)
	MOVF       PID_PID_L0+0, 0
	MOVWF      R4
	MOVF       PID_PID_L0+1, 0
	MOVWF      R5
	MOVF       PID_PID_L0+2, 0
	MOVWF      R6
	MOVF       PID_PID_L0+3, 0
	MOVWF      R7
	CLRF       R0
	CLRF       R1
	CLRF       R2
	CLRF       R3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0
	MOVF       R0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_PID26
;SmartMotorDriver.c,113 :: 		PID = 0;
	CLRF       PID_PID_L0+0
	CLRF       PID_PID_L0+1
	CLRF       PID_PID_L0+2
	CLRF       PID_PID_L0+3
;SmartMotorDriver.c,114 :: 		}
L_PID26:
;SmartMotorDriver.c,115 :: 		}
L_PID25:
;SmartMotorDriver.c,116 :: 		if(set > 600)
	MOVLW      128
	XORLW      2
	MOVWF      R0
	MOVLW      128
	XORWF      FARG_PID_set+1, 0
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__PID42
	MOVF       FARG_PID_set+0, 0
	SUBLW      88
L__PID42:
	BTFSC      STATUS+0, 0
	GOTO       L_PID27
;SmartMotorDriver.c,118 :: 		if(PID < 0)
	CLRF       R4
	CLRF       R5
	CLRF       R6
	CLRF       R7
	MOVF       PID_PID_L0+0, 0
	MOVWF      R0
	MOVF       PID_PID_L0+1, 0
	MOVWF      R1
	MOVF       PID_PID_L0+2, 0
	MOVWF      R2
	MOVF       PID_PID_L0+3, 0
	MOVWF      R3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0
	MOVF       R0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_PID28
;SmartMotorDriver.c,120 :: 		PID = 0;
	CLRF       PID_PID_L0+0
	CLRF       PID_PID_L0+1
	CLRF       PID_PID_L0+2
	CLRF       PID_PID_L0+3
;SmartMotorDriver.c,121 :: 		}
L_PID28:
;SmartMotorDriver.c,122 :: 		}
L_PID27:
;SmartMotorDriver.c,123 :: 		M_control((int)PID);
	MOVF       PID_PID_L0+0, 0
	MOVWF      R0
	MOVF       PID_PID_L0+1, 0
	MOVWF      R1
	MOVF       PID_PID_L0+2, 0
	MOVWF      R2
	MOVF       PID_PID_L0+3, 0
	MOVWF      R3
	CALL       _double2int+0
	MOVF       R0, 0
	MOVWF      FARG_M_control_ctr+0
	MOVF       R1, 0
	MOVWF      FARG_M_control_ctr+1
	CALL       _M_control+0
;SmartMotorDriver.c,125 :: 		Ow_reset(&PORTA, 1); //debug over onewire protocol
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Reset_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Reset_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Reset_pin+0
	CALL       _Ow_Reset+0
;SmartMotorDriver.c,126 :: 		Ow_Write(&PORTA, 1, 0xCC);
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Write_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Write_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Write_pin+0
	MOVLW      204
	MOVWF      FARG_Ow_Write_data_+0
	CALL       _Ow_Write+0
;SmartMotorDriver.c,127 :: 		Ow_Write(&PORTA, 1, (((int)set) >>8));
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Write_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Write_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Write_pin+0
	MOVF       FARG_PID_set+1, 0
	MOVWF      R0
	MOVLW      0
	BTFSC      FARG_PID_set+1, 7
	MOVLW      255
	MOVWF      R1
	MOVF       R0, 0
	MOVWF      FARG_Ow_Write_data_+0
	CALL       _Ow_Write+0
;SmartMotorDriver.c,128 :: 		Ow_Write(&PORTA, 1, (((int)set)&0xFF));
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Write_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Write_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Write_pin+0
	MOVLW      255
	ANDWF      FARG_PID_set+0, 0
	MOVWF      FARG_Ow_Write_data_+0
	CALL       _Ow_Write+0
;SmartMotorDriver.c,129 :: 		Ow_Write(&PORTA, 1, (((int)rpm2) >>8));
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Write_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Write_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Write_pin+0
	MOVF       PID_rpm2_L0+1, 0
	MOVWF      R0
	MOVLW      0
	BTFSC      PID_rpm2_L0+1, 7
	MOVLW      255
	MOVWF      R1
	MOVF       R0, 0
	MOVWF      FARG_Ow_Write_data_+0
	CALL       _Ow_Write+0
;SmartMotorDriver.c,130 :: 		Ow_Write(&PORTA, 1, (((int)rpm2)&0xFF));
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Write_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Write_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Write_pin+0
	MOVLW      255
	ANDWF      PID_rpm2_L0+0, 0
	MOVWF      FARG_Ow_Write_data_+0
	CALL       _Ow_Write+0
;SmartMotorDriver.c,131 :: 		Ow_Write(&PORTA, 1, (((int)PID) >>8));
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Write_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Write_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Write_pin+0
	MOVF       PID_PID_L0+0, 0
	MOVWF      R0
	MOVF       PID_PID_L0+1, 0
	MOVWF      R1
	MOVF       PID_PID_L0+2, 0
	MOVWF      R2
	MOVF       PID_PID_L0+3, 0
	MOVWF      R3
	CALL       _double2int+0
	MOVF       R1, 0
	MOVWF      R2
	MOVLW      0
	BTFSC      R1, 7
	MOVLW      255
	MOVWF      R3
	MOVF       R2, 0
	MOVWF      FARG_Ow_Write_data_+0
	CALL       _Ow_Write+0
;SmartMotorDriver.c,132 :: 		Ow_Write(&PORTA, 1, (((int)PID)&0xFF));
	MOVLW      PORTA+0
	MOVWF      FARG_Ow_Write_port+0
	MOVLW      hi_addr(PORTA+0)
	MOVWF      FARG_Ow_Write_port+1
	MOVLW      1
	MOVWF      FARG_Ow_Write_pin+0
	MOVF       PID_PID_L0+0, 0
	MOVWF      R0
	MOVF       PID_PID_L0+1, 0
	MOVWF      R1
	MOVF       PID_PID_L0+2, 0
	MOVWF      R2
	MOVF       PID_PID_L0+3, 0
	MOVWF      R3
	CALL       _double2int+0
	MOVLW      255
	ANDWF      R0, 0
	MOVWF      FARG_Ow_Write_data_+0
	CALL       _Ow_Write+0
;SmartMotorDriver.c,133 :: 		}
L_end_PID:
	RETURN
; end of _PID

_M_control:

;SmartMotorDriver.c,135 :: 		void M_control(int ctr) //motor control function
;SmartMotorDriver.c,137 :: 		if (ctr == 0) //stop the motor
	MOVLW      0
	XORWF      FARG_M_control_ctr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__M_control44
	MOVLW      0
	XORWF      FARG_M_control_ctr+0, 0
L__M_control44:
	BTFSS      STATUS+0, 2
	GOTO       L_M_control29
;SmartMotorDriver.c,139 :: 		PWM1_set_duty(ctr);
	MOVF       FARG_M_control_ctr+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;SmartMotorDriver.c,140 :: 		}
L_M_control29:
;SmartMotorDriver.c,141 :: 		if (ctr > 0)  //clockwise turn set and set the pwm duty
	MOVLW      128
	MOVWF      R0
	MOVLW      128
	XORWF      FARG_M_control_ctr+1, 0
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__M_control45
	MOVF       FARG_M_control_ctr+0, 0
	SUBLW      0
L__M_control45:
	BTFSC      STATUS+0, 0
	GOTO       L_M_control30
;SmartMotorDriver.c,143 :: 		LATA.f0 = 1;
	BSF        LATA+0, 0
;SmartMotorDriver.c,144 :: 		PWM1_set_duty(ctr);
	MOVF       FARG_M_control_ctr+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;SmartMotorDriver.c,145 :: 		}
L_M_control30:
;SmartMotorDriver.c,146 :: 		if (ctr < 0)  //counter clockwise turn set and set the pwm duty
	MOVLW      128
	XORWF      FARG_M_control_ctr+1, 0
	MOVWF      R0
	MOVLW      128
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__M_control46
	MOVLW      0
	SUBWF      FARG_M_control_ctr+0, 0
L__M_control46:
	BTFSC      STATUS+0, 0
	GOTO       L_M_control31
;SmartMotorDriver.c,148 :: 		LATA.f0 = 0;
	BCF        LATA+0, 0
;SmartMotorDriver.c,149 :: 		ctr = ctr * -1; //turn value positive before send in to PWM
	MOVF       FARG_M_control_ctr+0, 0
	MOVWF      R0
	MOVF       FARG_M_control_ctr+1, 0
	MOVWF      R1
	MOVLW      255
	MOVWF      R4
	MOVLW      255
	MOVWF      R5
	CALL       _Mul_16X16_U+0
	MOVF       R0, 0
	MOVWF      FARG_M_control_ctr+0
	MOVF       R1, 0
	MOVWF      FARG_M_control_ctr+1
;SmartMotorDriver.c,150 :: 		PWM1_set_duty(ctr);
	MOVF       R0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;SmartMotorDriver.c,151 :: 		}
L_M_control31:
;SmartMotorDriver.c,152 :: 		}
L_end_M_control:
	RETURN
; end of _M_control
