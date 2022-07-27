%x commentsingle
%x commentmulti 
%x strstate
%{
    //definition section
    #include <bits/stdc++.h>
    #include <iostream>
    #include "SymbolTable.cpp"
    #include "y.tab.h"

    extern YYSTYPE yylval;

    using namespace std;


    extern int numLine;
    int initial = 0;
    int mulcmnt = 0;
    int mulstr = 0;
    extern int numError;
    extern FILE* log_file;
    extern FILE* error_file;
    extern SymbolTable* table;
    string stringDetector = "";
    string original = "";
    string comment = "";

%}

%option noyywrap 

/* macros */
ws [ \t\r\f\v]
newline \n
alphabets [A-Za-z]
digit [0-9]
exp [E][+-]?[0-9]+
wholenumber {digit}+
integer {wholenumber}
floatnum ({digit}*([\.]{digit}+)){exp}?|{digit}+{exp}?
charliterals '[^\n\\]'
id [_a-zA-Z][a-zA-Z0-9_]*
relop "<"|">"|">="|"<="|"=="|"!="
logicop "||"|"&&"
addop "+"|"-"
mulop "*"|"/"|"%"
incop "++"
decop "--"
TooManyDecimalPointError {digit}*([\.]{digit}*)+([\.]{digit}*)+{exp}?
IllFormedNumber {digit}*([\.]{digit}*)*?([E][+-]?({digit}+)?([\.]{digit}*)+)+
InvalidSuffixPrefix {wholenumber}{id}{floatnum}*
MultiCharacterError '((\\[^\r\n])|[^\\'\r\n]){2,}'
UnfinishedCharacterError '[\\]'|'[^\n\']|'\\[nt\\afr"bv0]|'\\|'
UnrecognizedCharacterError '(\\[^nt\\afr"bv0])+'|[`@#$?:\.] 

%%

{ws}+ {}

{newline} {numLine++;}

"if" {
    return IF;
}
"else" {
    return ELSE;
}
"for" {
    return FOR;
}
"while" {
    return WHILE;
}
"do" {
    return DO;
}
"break" {
    return BREAK;
}
"int" {
    return INT;
}
"char" {
    return CHAR;
}
"float" {
    return FLOAT;
}
"double" {
    return DOUBLE;
}
"void" {
    return VOID;
}
"return" {
    return RETURN;
}
"switch" {
    return SWITCH;
}
"case" {
    return CASE;
}
"default" {
    return DEFAULT;
}
"continue" {
    return CONTINUE;
}

"printf" {
    return PRINTLN;
}

{integer} {
    SymbolInfo *s = new SymbolInfo(yytext, "CONST_INT");
    yylval.symbol = s;
    return CONST_INT;
}
{floatnum} {
    SymbolInfo *s = new SymbolInfo(yytext, "CONST_FLOAT");
    yylval.symbol = s;
    return CONST_FLOAT;
}
{charliterals} {
    SymbolInfo *s= new  SymbolInfo(yytext,"CONST_CHAR");
	yylval.symbol = s;
	return CONST_CHAR;
}

'\\[tnafrbv0\\\']' {
    char c = yytext[2];
    if (c == 't') yytext[0] = '\t';
    else if (c == 'n') yytext[0] = '\n';
    else if (c == 'a') yytext[0] = '\a';
    else if (c == 'f') yytext[0] = '\f';
    else if (c == 'r') yytext[0] = '\r';
    else if (c == 'v') yytext[0] = '\v';
    else if (c == 'b') yytext[0] = '\b';
    else if (c == '\\') yytext[0] = '\\';
    else if (c == '\'') yytext[0] = '\'';
    else yytext[0] = '\0';
    yytext[1] = '\0';
    SymbolInfo *s= new  SymbolInfo(yytext,"CONST_CHAR");
	yylval.symbol = s;
	return CONST_CHAR;
}

{addop} {
    SymbolInfo *s= new  SymbolInfo(yytext, "ADDOP");
	yylval.symbol = s;
	return ADDOP;
}

{mulop} {
    SymbolInfo *s= new  SymbolInfo(yytext, "MULOP");
	yylval.symbol = s;
	return MULOP;
}

{incop} {
    SymbolInfo *s= new  SymbolInfo(yytext, "INCOP");
	yylval.symbol = s;
    return INCOP;
}

{decop} {
    SymbolInfo *s= new  SymbolInfo(yytext, "DECOP");
	yylval.symbol = s;
    return DECOP;
}

{relop} {
    SymbolInfo *s= new  SymbolInfo(yytext, "RELOP");
	yylval.symbol = s;
	return RELOP;
}

{logicop} {
    SymbolInfo *s= new  SymbolInfo(yytext, "LOGICOP");
	yylval.symbol = s;
	return LOGICOP;
}

"=" {
    return ASSIGNOP;
}

"!" {
    return NOT;
}

"(" {
    return LPAREN;
}

")" {
    return RPAREN;
}

"[" {
    return LTHIRD;
}

"]" {
    return RTHIRD;
}

"," {
    return COMMA;
}

";" {
    return SEMICOLON;
}

"{" {
    return LCURL;
}

"}" {
    return RCURL;
}

{id}  {
    SymbolInfo *s= new  SymbolInfo(yytext,"ID");
    yylval.symbol = s;
    return ID;
}

\" {
    original = original + yytext;
    stringDetector = stringDetector+yytext;
    initial = numLine;
    BEGIN strstate;
}

<strstate>\" {
    stringDetector = "";
    original = "";
    mulstr = 0;
    initial = 0;
    BEGIN INITIAL;
}

<strstate>\n {
    numError++;
    string line = "Error at line no "+to_string(initial)+": Unfinished string "+original+"\n\n";
    fprintf(log_file,  line.c_str());
    numLine++;
    original = "";
    stringDetector = "";
    mulstr = 0;
    initial = 0;
    BEGIN INITIAL;
}

<strstate>\\\n {
    numLine++;
    original = original+'\\'+'\n';
    mulstr = 1;
}
<strstate>\\[nt\\afr\"bv0'] {
    original = original + yytext;
    char c = yytext[1]; 
    if (c == 'n') stringDetector = stringDetector + '\n';
    else if (c == 't') stringDetector = stringDetector + '\t';
    else if (c == '\\') stringDetector = stringDetector + '\\';
    else if (c == 'a') stringDetector = stringDetector + '\a';
    else if (c == 'f') stringDetector = stringDetector + '\f';
    else if (c == 'r') stringDetector = stringDetector + '\r';
    else if (c == '\"') stringDetector = stringDetector + '\"';
    else if (c == 'b') stringDetector = stringDetector + '\b';
    else if (c == 'v') stringDetector = stringDetector + '\v';
    else if (c == '0') stringDetector = stringDetector + '\0';
    else if (c == '\'') stringDetector = stringDetector + '\'';
}

<strstate>[^\n\"\\] {
    stringDetector = stringDetector + yytext;
    original = original + yytext;
}

<strstate>\\ {}

"//" {
    comment = comment + yytext;
    BEGIN commentsingle;
    initial = numLine;
}

<commentsingle>\n {
    numLine++;
    comment = "";
    mulcmnt = 0;
    initial = 0;
    BEGIN INITIAL;
}

<commentsingle>\\\n {
    numLine++;
    mulcmnt = 1;
    comment = comment + yytext;
}

<commentsingle>[^\n] {
    char c = yytext[0];
    if (mulcmnt) {
        if(c != '\t' && c != ' ' && c != '\r' && c != '\f' && c != '\v'){
            comment =  comment + c;
            mulcmnt = 0;
        }   
    }
    else {
        comment = comment + c;
    }
} 

"/*" {
    initial = numLine;
    comment = comment + yytext;
    original = original + yytext;
    BEGIN commentmulti;
}
<commentmulti>"*/" {
    comment = "";
    original = "";
    mulcmnt = 0;
    initial = 0;
    BEGIN INITIAL;
}

<commentmulti>\n {
    numLine++;
    mulcmnt = 1;
    comment = comment + yytext;
    original = original + yytext;
}
<commentmulti>[^\n] {
    char c = yytext[0];
    if (mulcmnt) {
        if(c != '\t' && c != ' ' && c != '\r' && c != '\f' && c != '\v'){
            original = original + c;
            comment =  comment + c;
            mulcmnt = 0;
        }   
    }
    else {
        original = original + c;
        comment = comment + c;
    }
}
<commentmulti><<EOF>> {
    string line = "Error at line no "+to_string(initial)+": Unterminated Comment "+original+"\n\n";
    fprintf(log_file, line.c_str());
    comment = "";
    original = "";
    mulcmnt = 0;
    initial = 0;
    numError++;
    return 0;
} 

{TooManyDecimalPointError} {
    numError++;
    string line = "Error at line no "+to_string(numLine)+": Too many decimal points "+yytext+"\n\n"; 
    fprintf(log_file, line.c_str());
}

{IllFormedNumber} {
    numError++;
    string line = "Error at line no "+to_string(numLine)+": Ill formed number "+yytext+"\n\n"; 
    fprintf(log_file, line.c_str());
}

{InvalidSuffixPrefix} {
    numError++;
    string line = "Error at line no "+to_string(numLine)+": Invalid prefix on ID or invalid suffix on Number "+yytext+"\n\n"; 
    fprintf(log_file, line.c_str());
}

{UnfinishedCharacterError} {
    numError++;
    string line = "Error at line no "+to_string(numLine)+": Unterminated character "+yytext+"\n\n"; 
    fprintf(log_file, line.c_str());
}

{MultiCharacterError} {
    numError++;
    string line = "Error at line no "+to_string(numLine)+": Multi character constant error "+yytext+"\n\n"; 
    fprintf(log_file, line.c_str());
}

'' {
    numError++;
    string line = "Error at line no "+to_string(numLine)+": Empty character constant error "+yytext+"\n\n"; 
    fprintf(log_file, line.c_str());
}

{UnrecognizedCharacterError} {
    numError++;
    string line = "Error at line no "+to_string(numLine)+": Unrecognized character "+yytext+"\n\n"; 
    fprintf(log_file, line.c_str());
}

%%