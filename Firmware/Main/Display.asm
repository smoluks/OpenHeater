process_display:
rcall writeTemperature
ret

writeTemperature:
lds r17, THigh
andi r17, 0b00001111
lds r16, TLow
andi r16, 0b11110000
or r16, r17
swap r16
;
sbrc r16, 7
rjmp wt_minus
;+
cpi r16, 100
brsh wt_over100
;-----normal-----
clr r17
wt2:
cpi r16, 10
brlo wt3
 inc r17
 subi r16, 10
 rjmp wt2
wt3:
tst r17
breq wt10
 rcall convertnumberto7segment1
 sts SEG1, r17
 rjmp wt11
wt10:
 sts SEG1, r2	
wt11:
;
mov r17, r16
rcall convertnumberto7segment1
ori r17, 0b00000100 ;DP
sts SEG2, r17
;
lds r16, TLow
andi r16, 0b00001111
clr r17
wt1:
tst r16
breq wt0
 dec r16
 add r17, r3
 rjmp wt1
wt0:
lsr r17
lsr r17
lsr r17
lsr r17
rcall convertnumberto7segment2
sts SEG3, r17
rjmp wt_exit
;----->100-----
wt_over100:
clr r17
wt4:
cpi r16, 100
brlo wt5
 inc r17
 subi r16, 100
 rjmp wt4
wt5:
rcall convertnumberto7segment1
sts SEG1, r17
;
clr r17
wt6:
cpi r16, 10
brlo wt7
 inc r17
 subi r16, 10
 rjmp wt6
wt7:
rcall convertnumberto7segment1
sts SEG2, r17
;
mov r17, r16
rcall convertnumberto7segment2
sts SEG3, r17
rjmp wt_exit
;-----<0-----
wt_minus:
;
ldi r17, 0b01000000
sts SEG1, r17
clr r17
sub r17, r16
mov r16, r17
;
clr r17
wt8:
cpi r16, 10
brlo wt9
 inc r17
 subi r16, 10
 rjmp wt8
wt9:
rcall convertnumberto7segment1
sts SEG2, r17
;
mov r17, r16
rcall convertnumberto7segment2
sts SEG3, r17
;
wt_exit:
ldi r17, 0b10110001
sts SEG4, r17
ret

;IN r16 - errorcode
writeError:
ldi r17, 0b01110011
sts SEG1, r17
;
clr r17
we0:
cpi r16, 100
brlo we1
 inc r17
 subi r16, 100
 rjmp we0
we1:
rcall convertnumberto7segment1
sts SEG2, r17
;
clr r17
we2:
cpi r16, 10
brlo we3
 inc r17
 subi r16, 10
 rjmp we2
we3:
rcall convertnumberto7segment2
sts SEG3, r17
;
mov r17, r16
rcall convertnumberto7segment2
sts SEG4, r17
;
we_exit:
rjmp we_exit

convertnumberto7segment1:
cpi r17, 0
brne c1
 ldi r17, 0b10111011
 ret
c1:
cpi r17, 1
brne c2
 ldi r17, 0b10001000
 ret
c2:
cpi r17, 2
brne c3
 ldi r17, 0b11010011
 ret
c3:
cpi r17, 3
brne c4
 ldi r17, 0b11011001
 ret
c4:
cpi r17, 4
brne c5
 ldi r17, 0b11101000
 ret
c5:
cpi r17, 5
brne c6
 ldi r17, 0b01111001
 ret
c6:
cpi r17, 6
brne c7
 ldi r17, 0b01111011
 ret
c7:
cpi r17, 7
brne c8
 ldi r17, 0b10011000
 ret
c8:
cpi r17, 8
brne c9
 ldi r17, 0b11111011
 ret
c9:
cpi r17, 9
brne c10
 ldi r17, 0b11111001
 ret
c10:
ret

convertnumberto7segment2:
cpi r17, 0
brne cc1
 ldi r17, 0b00111111
 ret
cc1:
cpi r17, 1
brne cc2
 ldi r17, 0b00101000
 ret
cc2:
cpi r17, 2
brne cc3
 ldi r17, 0b10110110
 ret
cc3:
cpi r17, 3
brne cc4
 ldi r17, 0b10111010
 ret
cc4:
cpi r17, 4
brne cc5
 ldi r17, 0b10101001
 ret
cc5:
cpi r17, 5
brne cc6
 ldi r17, 0b10011011
 ret
cc6:
cpi r17, 6
brne cc7
 ldi r17, 0b10011111
 ret
cc7:
cpi r17, 7
brne cc8
 ldi r17, 0b00111000
 ret
cc8:
cpi r17, 8
brne cc9
 ldi r17, 0b10111111
 ret
cc9:
cpi r17, 9
brne cc10
 ldi r17, 0b10111011
 ret
cc10:
ret