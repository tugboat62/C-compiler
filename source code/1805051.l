%x commentsingle
%x commentmulti 
%x strstate
%{
    //definition section
    #include <bits/stdc++.h>
    #include <iostream>
    #include "SymbolTable.cpp"
    using namespace std;

    int numberOfLines = 1;
    int inital = 0;
    int mulcmnt = 0;
    int numberOfErrors = 0;
    FILE* yylog;
    FILE* out;
    SymbolTable symbolTable(7);
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
incop "++"|"--"
TooManyDecimalPointError {digit}*([\.]{digit}*)+([\.]{digit}*)+{exp}?
IllFormedNumber {digit}*([\.]{digit}*)*?([E][+-]?({digit}+)?([\.]{digit}*)+)+
InvalidSuffixPrefix {wholenumber}{id}{floatnum}*
MultiCharacterError '((\\[^\r\n])|[^\\'\r\n]){2,}'
UnfinishedCharacterError '[\\]'|'[^\n\']|'\\[nt\\afr"bv0]|'\\
UnrecognizedCharacterError '(\\[^nt\\afr"bv0])+'|[`@#$?:\.] 

%%

{ws}+ {}

{newline} {numberOfLines++;}

"if" {
    fprintf(out, "<IF> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <IF> Lexeme if found\n\n";
    fprintf(yylog, line.c_str());
}
"else" {
    fprintf(out, "<ELSE> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <ELSE> Lexeme else found\n\n";
    fprintf(yylog, line.c_str());
}
"for" {
    fprintf(out, "<FOR> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <FOR> Lexeme for found\n\n";
    fprintf(yylog, line.c_str());
}
"while" {
    fprintf(out, "<WHILE> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <WHILE> Lexeme while found\n\n";
    fprintf(yylog, line.c_str());
}
"do" {
    fprintf(out, "<DO> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <DO> Lexeme DO found\n\n";
    fprintf(yylog, line.c_str());
}
"break" {
    fprintf(out, "<BREAK> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <BREAK> Lexeme break found\n\n";
    fprintf(yylog, line.c_str());
}
"int" {
    fprintf(out, "<INT> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <INT> Lexeme int found\n\n";
    fprintf(yylog, line.c_str());
}
"char" {
    fprintf(out, "<CHAR> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <CHAR> Lexeme char found\n\n";
    fprintf(yylog, line.c_str());
}
"float" {
    fprintf(out, "<FLOAT> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <FLOAT> Lexeme float found\n\n";
    fprintf(yylog, line.c_str());
}
"double" {
    fprintf(out, "<DOUBLE> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <DOUBLE> Lexeme double found\n\n";
    fprintf(yylog, line.c_str());
}
"void" {
    fprintf(out, "<VOID> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <VOID> Lexeme void found\n\n";
    fprintf(yylog, line.c_str());
}
"return" {
    fprintf(out, "<RETURN> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <RETURN> Lexeme return found\n\n";
    fprintf(yylog, line.c_str());
}
"switch" {
    fprintf(out, "<SWITCH> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <SWITCH> Lexeme switch found\n\n";
    fprintf(yylog, line.c_str());
}
"case" {
    fprintf(out, "<CASE> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <CASE> Lexeme case found\n\n";
    fprintf(yylog, line.c_str());
}
"default" {
    fprintf(out, "<DEFAULT> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <DEFAULT> Lexeme default found\n\n";
    fprintf(yylog, line.c_str());
}
"continue" {
    fprintf(out, "<CONTINUE> ");
    string line = "Line no "+to_string(numberOfLines)+": Token <CONTINUE> Lexeme continue found\n\n";
    fprintf(yylog, line.c_str());
}
{integer} {
    string name(yytext);
    bool m = symbolTable.Insert(name, "CONST_INT");
    string line = "< CONST_INT, " + name + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <CONST_INT> Lexeme "+name+" found\n\n";
    fprintf(yylog, line.c_str());
    if (m) symbolTable.printModified(yylog);
}
{floatnum} {
    string name(yytext);
    bool m = symbolTable.Insert(name, "CONST_FLOAT");
    string line = "< CONST_FLOAT, " + name + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <CONST_FLOAT> Lexeme "+name+" found\n\n";
    fprintf(yylog, line.c_str());
    if (m) symbolTable.printModified(yylog);
}
{charliterals} {
    string s(yytext);
    string name(yytext);
    s.erase(s.find_last_not_of('\'')+1);
    s.erase(0, s.find_first_not_of('\''));
    bool m = symbolTable.Insert(name, "CONST_CHAR");
    string temp(yytext); 
    string line = "< CONST_CHAR, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <CONST_CHAR> Lexeme "+name+" found --> <CHAR_CONST, "+name[1]+">\n\n";
    fprintf(yylog, line.c_str());
    if (m) symbolTable.printModified(yylog);
}

'\\[tnafrbv0\\\']' {
    string name(yytext);
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
    string temp;
    temp.push_back(yytext[0]);
    bool m = symbolTable.Insert(name, "CONST_CHAR");
    string line = "< CONST_CHAR, ";
    line.push_back(yytext[0]); 
    line = line + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <CONST_CHAR> Lexeme "+name+" found --> <CHAR_CONST, "+temp+">\n\n";
    fprintf(yylog, line.c_str());
    if (m) symbolTable.printModified(yylog);
}

{addop} {
    string name(yytext);
    string line = "< ADDOP, " + name + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <ADDOP> Lexeme "+name+" found\n\n";
    fprintf(yylog, line.c_str());
}

{mulop} {
    string name(yytext);
    string line = "< MULOP, " + name + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <MULOP> Lexeme "+name+" found\n\n";
    fprintf(yylog, line.c_str());
}

{incop} {
    string name(yytext);
    string line = "< INCOP, " + name + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <INCOP> Lexeme "+name+" found\n\n";
    fprintf(yylog, line.c_str());
}

{relop} {
    string temp(yytext);
    string line = "< RELOP, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <RELOP> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

{logicop} {
    string temp(yytext);
    string line = "< LOGICOP, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <LOGICOP> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

"=" {
    string temp(yytext);
    string line = "< ASSIGNOP, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <ASSIGNOP> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

"!" {
    string temp(yytext);
    string line = "< NOT, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <NOT> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

"(" {
    string temp(yytext);
    string line = "< LPAREN, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <LPAREN> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

")" {
    string temp(yytext);
    string line = "< RPAREN, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <RPAREN> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

"[" {
    string temp(yytext);
    string line = "< LTHIRD, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <LTHIRD> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

"]" {
    string temp(yytext);
    string line = "< RTHIRD, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <RTHIRD> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

"," {
    string temp(yytext);
    string line = "< COMMA, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <COMMA> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

";" {
    string temp(yytext);
    string line = "< SEMICOLON, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <SEMICOLON> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
}

"{" {
    string temp(yytext);
    string line = "< LCURL, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <LCURL> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
    symbolTable.EnterScope();
}

"}" {
    string temp(yytext);
    string line = "< RCURL, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <RCURL> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());
    symbolTable.ExitScope();
}

{id}  {
    string temp(yytext);
    string line = "< ID, " + temp + " > ";
    fprintf(out, line.c_str());
    line = "Line no "+to_string(numberOfLines)+": Token <ID> Lexeme "+temp+" found\n\n";
    fprintf(yylog, line.c_str());           
    bool m = symbolTable.Insert(temp, "ID");
    if (m) symbolTable.printModified(yylog);
    else {
        line = temp +" already exists in current ScopeTable\n\n";
        fprintf(yylog, line.c_str());
    }
}

\" {
    original = original + yytext;
    stringDetector = stringDetector+yytext;
    BEGIN strstate;
}

<strstate>\" {
    stringDetector = stringDetector+yytext;
    original = original + yytext;
    string line = "Line no "+to_string(numberOfLines)+": Token <STRING> Lexeme "+original+" found --> <STRING, "+stringDetector+">\n\n";
    fprintf(yylog, line.c_str());
    line = "< STRING, "+stringDetector.substr(1,stringDetector.length()-2)+" > ";
    fprintf(out, line.c_str());
    stringDetector = "";
    original = "";
    BEGIN INITIAL;
}

<strstate>\n {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Unfinished string "+original+"\n\n";
    fprintf(yylog,  line.c_str());
    numberOfLines++;
    original = "";
    stringDetector = "";
    BEGIN INITIAL;
}

<strstate>\\\n {
    numberOfLines++;
    original = original+'\\'+'\n';
}

<strstate>\\[nt\\afr\"bv0\'] {
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
<strstate>[^\n"\\] {
    string name(yytext);
    stringDetector = stringDetector+name;
    original = original + name;
}
<strstate>\\ {}

"//" {
    comment = comment + yytext;
    BEGIN commentsingle;
}

<commentsingle>\n {
    numberOfLines++;
    string line = "Line no "+to_string(numberOfLines)+": Token <COMMENT> Lexeme "+comment+" found\n\n";
    fprintf(yylog, line.c_str());
    comment = "";
    BEGIN INITIAL;
}

<commentsingle>\\\n {
    numberOfLines++;
    comment = comment + '\\' + '\n';
}

<commentsingle>[^\n] {
    comment = comment + yytext;
} 

"/*" {
    inital = numberOfLines;
    comment = comment + yytext;
    original = original + yytext;
    BEGIN commentmulti;
}
<commentmulti>"*/" {
    comment = comment + yytext;
    string line = "Line no "+to_string(numberOfLines)+": Token <COMMENT> Lexeme "+comment+" found\n\n";
    fprintf(yylog, line.c_str());
    comment = "";
    original = "";
    mulcmnt = 0;
    BEGIN INITIAL;
}

<commentmulti>\n {
    numberOfLines++;
    mulcmnt = 1;
    comment = comment + yytext;
}
<commentmulti>[^\n] {
    comment = comment + yytext;
    string s = yytext;
    int i=0;
    if (mulcmnt) {
        while(i<s.size()){
            char c = s[i];
            if(c != '\t' && c != ' ' && c != '\r' && c != '\f' && c != '\v'){
                original = original + c;
                break;
            }
            i++;    
        }
    } else {
        original = original + yytext;
    }
}
<commentmulti><<EOF>> {
    string line = "Error at line no "+to_string(inital)+": Unterminated Comment "+original+"\n\n";
    fprintf(yylog, line.c_str());
    comment = "";
    original = "";
    mulcmnt = 0;
    numberOfErrors++;
    return 0;
} 

{TooManyDecimalPointError} {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Too many decimal points "+yytext+"\n\n"; 
    fprintf(yylog, line.c_str());
}

{IllFormedNumber} {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Ill formed number "+yytext+"\n\n"; 
    fprintf(yylog, line.c_str());
}

{InvalidSuffixPrefix} {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Invalid prefix on ID or invalid suffix on Number "+yytext+"\n\n"; 
    fprintf(yylog, line.c_str());
}

{UnfinishedCharacterError} {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Unterminated character "+yytext+"\n\n"; 
    fprintf(yylog, line.c_str());
}

{MultiCharacterError} {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Multi character constant error "+yytext+"\n\n"; 
    fprintf(yylog, line.c_str());
}

'' {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Empty character constant error "+yytext+"\n\n"; 
    fprintf(yylog, line.c_str());
}

{UnrecognizedCharacterError} {
    numberOfErrors++;
    string line = "Error at line no "+to_string(numberOfLines)+": Unrecognized character "+yytext+"\n\n"; 
    fprintf(yylog, line.c_str());
}

%%

int main(int argc, char *argv[]) {
    
    if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	yyin= fin;
    out = fopen("token.txt", "w");
    yylog = fopen("log.txt", "w");

    yylex();
    fprintf(yylog, "Final symbols in symbol table:\n\n");
    symbolTable.printModified(yylog);
    fprintf(yylog, "Total lines: %d\n", numberOfLines);
    fprintf(yylog, "Total errors: %d\n", numberOfErrors);
    fclose(yyin);
	fclose(out);
	fclose(yylog);
    return 0;
}