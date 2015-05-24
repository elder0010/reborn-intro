.const page_no = 4

//.align 108
page_0:
.text "onslaught" :halt()
.text "proudly presents"
:blank_line()
.text "outrage prv " :ch('+') :ch('3') :halt()
 :ch('(') .text "c" :ch(')') .text " cosmos" :halt()
.text "designs" :ch('.')
.byte 0

//.align 108
page_1:
.text "call" :ch(':') :halt()
:filled_line()
.text "antidote":halt()
.text "via telnet bbs":halt()
.text "antidote" :ch('.') .text "triad":halt()
:ch('.') .text "se port" :ch(':') :ch('2') :ch('3')
.byte 0

//.align 108
page_2:
.text "we welcome n":ch('3') .text"xu":ch('5')
.text "our new member" :halt()
:blank_line()
.text "some old faces" :halt()
.text "will soon be" :halt()
.text "back as well" :ch('!')
.byte 0

page_3:
.text "it is never wise"
.text "to play games if"
.text "you are not" :halt()
.text "willing to pay":halt()
.text "the price":ch('.')
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
        .byte 49
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
