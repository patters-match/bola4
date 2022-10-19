# Bolalela 4 by Beyker Soft
# 
# https://bunsen.itch.io/bolalela-4-by-beyker-soft
#
# comments by patters
#
@gameover:
        beep 3,-15
        restore
#                                                          screen attributes: INK 7, PAPER 1, BRIGHT 1 (sysvar ATTR P)
        poke 23693,79
        border 0
#                                                          remove one line from the second part of the screen, which has an odd side-effect of painting vertical lines
        poke 23659,1
        cls
#                                                          variables setup:
#                                                              c = unused?!
#                                                              d = Bolalela's vertical direction (d=1 rising or d=0 falling)
#                                                              e = vertical bounce counter
#                                                              q = memory address
#                                                              t = score
#                                                          let c,d,e,t = 0   let q=58884
        read c,d,e,q,t
        print at 10,12;"GAME OVER"
        pause 200
        cls
#                                                          print Bolalela graphic
        print at 12,16;"\*";chr$ 8; over 1;">"
        print #1;tab 10;"Score"
#                                                          DEFADD trick to copy memory fast in BASIC
#                                                          http://blog.jafma.net/2020/03/16/efficient-basic-coding-for-the-zx-spectrum-iv/#en_5
#                                                          writes the following bytes (a fake DEF FN statement with 2 string input variables) to address q-4 (58880):
#                                                              97,36,14,0,0,88,160,2,44,98,36,14,0,1,88,160,2,41
#                                                          which translates to:
#                                                              a$ = address 22528 (start of screen attributes) length 672 bytes (20 charcter rows)
#                                                              b$ = address 22529 (start of screen attributes+1)length 672 bytes
#                                                          so "a$=b$" has the effect of pulling all attributes on screen to the left (hence why no characters used)
#                                                          line wrapping means that existing items exiting at the left of the screen will re-appear at the right
#                                                          consequently as the game progresses the screen will get more and more crowded
        for n=q-4 to 58897
            read a
            poke n,a
        next n
#                                                          since 23563 defaults to 0x00 and now 23564=0xE6, the sysvar DEFADD = 0xE600 = 58880 
        poke 23564,230
@mainloop:
#                                                          halfway through Bolalela's bounce either print a new hazard or a token
#                                                          new objects arrive in the last column of the screen only
        if e=4 then \
            let r=rnd: \
            print at 6+rnd*8,31; paper 5+r; ink 2; flash r;" ";
#                                                          if Bolalela is rising print a row of black characters at row 0
#                                                          if Bolalela is falling print a row of black characters at row 21
        print at 21*not d,0; paper 0; bright d,,
#                                                          if Bolalela is rising modify a$ to start one line lower down the screen
#                                                          this would have been better expressed as 'poke q,32*d'                                            
        poke 58884,32*d
#                                                          if Bolalela is falling modify b$ to start one line lower down the screen                                            
        poke 58893,32*not d
#                                                          increment b$ address if P key is pressed, pulling the screen attributes one more character to the left 
        poke 58893,peek 58893+(inkey$="p")
#                                                          Bolalela's bounce is 7 rows
        let e=e+d
        if e=7 then \
            let d=0: \
            let e=0
#                                                          increment a$ address if O key is pressed, the screen attributes will not move horizontally
        poke q,peek q+(inkey$="o")
#                                                          increment b$ address, pulling the screen attributes one characters to the left
        poke 58893,peek 58893+1
#                                                          screen attributes memory copy
        let a$=b$
#                                                          collision detection
        let h=attr (12,16)
#                                                          if Bolalela is not on a bright blue square then bounce
#                                                          if she hit a token, paint that square blue, mini-bounce of one row only, score +50
        if h<>79 then \
            let d=1: \
            beep .01,h/5: \
            if h=106 then \
                poke 22928,79: \
                let e=6: \
                let t=t+50
#                                                          decrement a positive score if O key is held, increment if not
        let t=t-(inkey$= "o" and t)+(inkey$<>"o")
#                                                          print score
        print #1;at 1,16;t;" ";
#                                                          loop unless Bolalela's attribute is FLASHing
        if h<128 then \
            goto @mainloop
        goto @gameover
        data 0,0,0,58884,0,\
             97,36,14,0,0,88,160,2,44,\
             98,36,14,0,1,88,160,2,41
