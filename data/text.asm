.const page_no = 4  //la tabella degli indirizzi sta su text_writer.asm linea 159

//La regola è: se ci sono 16 caratteri in una riga non va messo halt.

//.align 108
page_0:
.text "onslaught is" :halt()
.text "proud to present"
.text "an intro which":halt()
.text "resembles some":ch('-') :halt()
.text "thing legend did"
.text "a while back" :ch('.') :ch('.') :ch('.')
.byte 0

//.align 108
page_1:
.text "credits":halt()
:filled_line()
.text "msx":ch(':') .text " conrad":halt()
:blank_line()
.text "gfx":ch(':') .text " mirage"
.byte 0

//.align 108
page_2:
.text "credits":halt()
:filled_line()
.text "code":ch(':'):halt()
:blank_line()
.text "elder":ch('0'):ch('0'):ch('1'):ch('0'):halt()
.text "freshness"
.byte 0

page_3:
.text "it is never wise"
.text "to play games if"
.text "you are not" :halt()
.text "willing to pay":halt()
.text "the price":ch('.')
.byte 0

page_4:
.byte 0


.macro ch(char){
    .if (char=='.'){
        .byte 27
    }
    .if(char==','){
        .byte 28
    }
    .if(char==':'){
        .byte 35
    }
    .if(char=='('){
        .byte 33
    }
    .if(char==')'){
        .byte 34
    }
    .if(char=='+'){
        .byte 38
    }
    .if(char=='_'){
        .byte 37
    }
    .if(char=='!'){
        .byte 29
    }
    .if(char=='?'){
        .byte 30
    }
    .if(char=='1'){
        .byte 40
    }

    .if(char=='2'){
        .byte 41
    }

    .if(char=='3'){
        .byte 42
    }

    .if(char=='4'){
        .byte 43
    }

    .if(char=='5'){
        .byte 44
    }

    .if(char=='6'){
        .byte 45
    }

    .if(char=='7'){
        .byte 46
    }

    .if(char=='8'){
        .byte 47
    }

    .if(char=='9'){
        .byte 48
    }

    .if(char=='0'){
        .byte 39
    }

    .if(char=='-'){
        .byte 31
    }
}

.macro halt(){
    .byte $ff
}

.macro blank_line(){
    .text "":halt()
}

.macro dashed_line(){
    .for(var x=0;x<16;x++){
        :ch('-')
    }
}

.macro filled_line(){
    .for(var x=0;x<16;x++){
        :ch('_')
    }
}
/*

.text "onslaught is proud"
.text "to present a bla  "
.text "another intro blax"
.text "this time a remake"
.text "of the almighty   "
.text "legend intro      "
.byte 0

*/
