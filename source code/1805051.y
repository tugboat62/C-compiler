%{
#include<bits/stdc++.h>
#include "SymbolTable.cpp"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable* table = new SymbolTable(30);

int numLine = 1;
int numError = 0;

string symbolName;
string symbolType;
string calledFunction;
string currentFunction;
string currentDataType = "void";
vector<SymbolInfo> parameterList;
vector<string> completedFunc;

void yyerror(char *s)
{
	//write your code
}

FILE* log_file = fopen("1805051_log.txt", "w");
FILE* error_file = fopen("1805051_error.txt", "w");

void printInLogFile(string grammar, int line) {
	string l = "Line " + to_string(line) + ": " + grammar + "\n\n";
	fprintf(log_file, l.c_str());
}

void printToken(string token){
	string l = token + "\n\n";
	fprintf(log_file, l.c_str());
}

void printError(string error, int line){
	string l = "Error at line " + to_string(line) + ": " + error + "\n\n";
	fprintf(log_file, l.c_str());
	fprintf(error_file, l.c_str());
	++numError;
}



%}



%union {
     SymbolInfo *symbol;
}

%token ELSE IF FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE PRINTLN
%token VOID RETURN SWITCH CASE DEFAULT CONTINUE
%token ASSIGNOP NOT LPAREN RPAREN LTHIRD RTHIRD COMMA SEMICOLON LCURL RCURL
%token<symbol>CONST_INT
%token<symbol>CONST_FLOAT
%token<symbol>CONST_CHAR
%token<symbol>ADDOP
%token<symbol>MULOP
%token<symbol>INCOP
%token<symbol>DECOP
%token<symbol>RELOP
%token<symbol>LOGICOP
%token<symbol>ID

%type<symbol> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program 
			{
				printInLogFile("start : program", numLine);
				symbolName = $1->getName();
				symbolType = $1->getType();
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				table->printModified(log_file);
				string l;
				l = "Total Lines: " + to_string(numLine) + "\n";
				fprintf(log_file, l.c_str());
				l = "Total Errors: " + to_string(numError) + "\n";
				fprintf(log_file, l.c_str());
			}
;


program : program unit 
			{
				printInLogFile("program : program unit", numLine);
				symbolName = $1->getName() + $2->getName();
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| unit
			{
				printInLogFile("program : unit", numLine);
				symbolName = $1->getName();
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


unit : var_declaration
			{
				printInLogFile("unit : var_declaration", numLine);
				symbolName = $1->getName() + "\n";
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| func_declaration
			{
				printInLogFile("unit : func_declaration", numLine);
				symbolName = $1->getName();
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| func_definition
			{
				printInLogFile("unit : func_definition", numLine);
				symbolName = $1->getName();
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


func_declaration : type_specifier ID LPAREN parameter_list RPAREN 
			{
				currentFunction = $2->getName();
				if(table->LookUp(currentFunction) == NULL) {
					SymbolInfo* symbol = new SymbolInfo(currentFunction, "ID");
					symbol->setDataType($1->getName());
					symbol->setKeyType("function");
					for (int i=0; i<parameterList.size(); i++) {
						symbol->addParam(parameterList[i]);
					}
					parameterList.clear();
					table->Insert(*symbol);
				}
				else {
					string error = "Function " + '\"' + currentFunction + '\"' + " declared multiple times\n";
					printError(error, numLine);
				}
			}
SEMICOLON
			{
				printInLogFile("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", numLine);
				symbolName = $1->getName()+" "+$2->getName()+" "+"("+" "+$4->getName()+" "+")"+" "+";"+"\n";
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| type_specifier ID LPAREN RPAREN 
			{
				currentFunction = $2->getName();
				if(table->LookUp(currentFunction) == NULL) {
					SymbolInfo* symbol = new SymbolInfo(currentFunction, "ID");
					symbol->setDataType($1->getName());
					symbol->setKeyType("function");
					table->Insert(*symbol);
				}
				else {
					string error = "Function " + '\"' + currentFunction + '\"' + " declared multiple times\n";
					printError(error, numLine);
				}
			}
SEMICOLON
			{
				printInLogFile("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON", numLine);
				symbolName = $1->getName()+" "+$2->getName()+" "+"( );"+"\n";
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


func_definition : type_specifier ID LPAREN parameter_list RPAREN
			{
				currentFunction = $2->getName();
				SymbolInfo* s = table->LookUp(currentFunction);
				if(s == NULL) {
					SymbolInfo* symbol = new SymbolInfo(currentFunction, "ID");
					symbol->setDataType($1->getName());
					symbol->setKeyType("function");
					symbol->setParams(parameterList);
					table->Insert(*symbol);
				} 
				else {
					for(int i=0; i<completedFunc.size(); i++) {
						if(currentFunction == completedFunc[i]) {
							string l = "Multiple declaration of " + currentFunction;
							printError(l, numLine);
						}
					}
					if(s->getKeyType() != "function"){
						string l = "Multiple declaration of "+currentFunction;
						printError(l, numLine);
					}
					else {
						if ($1->getName() != s->getDataType()){
							string l = "Return type mismatch with function declaration in function "+s->getName();
							printError(l, numLine);
						}
						if (s->getParamsNum() != parameterList.size()) {
							string l = "Total number of arguments mismatch with declaration in function "+currentFunction;
							printError(l, numLine);
						}
						vector<SymbolInfo> parameters = s->getParams();
						int min = parameters.size();
						if (parameterList.size() < min) {
							min = parameterList.size();
						}
						for (int i=0; i<min; i++) {
							if(parameterList[i].getDataType() != parameters[i].getDataType()){
								string l = currentFunction + " parameter type error";
								printError(l, numLine);	
							}
						}
					}
				}
			}
compound_statement
			{
				printInLogFile("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement", numLine);
				symbolName = $1->getName()+" "+$2->getName()+" ("+" "+$4->getName()+" )\n"+$7->getName();
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");	
				completedFunc.push_back(currentFunction);
			}	
| type_specifier ID LPAREN RPAREN 
			{
				currentFunction = $2->getName();
				if(table->LookUp(currentFunction) == NULL) {
					SymbolInfo* symbol = new SymbolInfo(currentFunction, "ID");
					symbol->setKeyType("function");
					symbol->setDataType($1->getName());
					table->Insert(*symbol);
				}
				else {
					SymbolInfo* symbol = table->LookUp(currentFunction);
					if(symbol->getKeyType() != "function"){
						string l = "Multiple declaration of "+currentFunction;
						printError(l, numLine);
					}
				}
			}
compound_statement
			{
				printInLogFile("func_definition : type_specifier ID LPAREN RPAREN compound_statement", numLine);
				symbolName = $1->getName()+" "+$2->getName()+" ("+")\n"+$6->getName();
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				completedFunc.push_back(currentFunction);
			}
;


parameter_list : parameter_list COMMA type_specifier ID
			{
				symbolName = $1->getName() + " , " + $3->getName() + " " + $4->getName();
				printInLogFile("parameter_list : parameter_list COMMA type_specifier ID", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				SymbolInfo* s = new SymbolInfo($4->getName(), $4->getType());
				s->setKeyType("variable");
				s->setDataType($3->getName());

				int i=0;

				for (; i<parameterList.size(); i++) {
					if(parameterList[i].getName() == s->getName()){
						string l = "Multiple declaration of " + parameterList[i].getName() + " in parameter";
						printError(l, numLine);
						break;
					}
				}
				if(i == parameterList.size()) {
					parameterList.push_back(*s);
				}
			}
| parameter_list COMMA type_specifier
			{
				symbolName = $1->getName()+" , "+$3->getName();
				printInLogFile("parameter_list  : parameter_list COMMA type_specifier", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| type_specifier ID
			{
				symbolName = $1->getName()+" "+$2->getName();
				printInLogFile("parameter_list  : type_specifier ID", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				SymbolInfo* s = new SymbolInfo($2->getName(), $2->getType());
				s->setKeyType("variable");
				s->setDataType($1->getName());
				parameterList.push_back(*s);
			}
| type_specifier
			{
				symbolName = $1->getName();
				printInLogFile("parameter_list  : type_specifier", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


compound_statement : LCURL 
			{	
				table->EnterScope();
				for (int i=0; i<parameterList.size(); i++) {
					table->Insert(parameterList[i]);
				}
			}
statements RCURL
			{
				symbolName = "{\n" + $3->getName() + "}\n";
				printInLogFile("compound_statement : LCURL statements RCURL", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				table->printModified(log_file);
				parameterList.clear();
				table->ExitScope();
			}
| LCURL RCURL
			{
				symbolName = "{\n}\n";
				printInLogFile("compound_statement : LCURL statements RCURL", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				table->printModified(log_file);
				parameterList.clear();
			}
;


var_declaration : type_specifier declaration_list SEMICOLON
			{
				symbolName = $1->getName() + " " + $2->getName() + " ;";
				printInLogFile("var_declaration : type_specifier declaration_list SEMICOLON", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				if($1->getName() == "void") {
					printError("Variable type cannot be void", numLine);
				}
			}
;

type_specifier : INT
			{
				symbolName = "int";
				printInLogFile("type_specifier : INT", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				currentDataType = symbolName;
			}
| FLOAT
			{
				symbolName = "float";
				printInLogFile("type_specifier : FLOAT", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				currentDataType = symbolName;
			}
| VOID
			{
				symbolName = "void";
				printInLogFile("type_specifier : VOID", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				currentDataType = symbolName;
			}
;


declaration_list : declaration_list COMMA ID
			{
				symbolName = $1->getName() + " , " + $3->getName();
				printInLogFile("declaration_list : declaration_list COMMA ID", numLine);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				
				SymbolInfo* s = new SymbolInfo($3->getName(), $3->getType());
				s->setKeyType("variable");
				s->setDataType(currentDataType);
				
				ScopeTable* st = table->getCurrentScope();
				SymbolInfo* temp = st->LookUp(s->getName());
				if (temp != NULL) {
					string l = "Multiple declaration of " + temp->getName();
					printError(l, numLine);
				} 
				else {
					if (currentDataType != "void")
						table->Insert(*s);
				}
				printToken(symbolName);
			}
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
			{
				symbolName = $1->getName() + " , " + $3->getName() + "[" + $5->getName() + "]";
				printInLogFile("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", numLine);
				
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				SymbolInfo* s = new SymbolInfo($3->getName(), $3->getType());
				s->setKeyType("array");
				s->setDataType(currentDataType);
				int size = stoi($5->getName());
				s->setArraySize(size);

				ScopeTable* st = table->getCurrentScope();
				SymbolInfo* temp = st->LookUp(s->getName());
				if (temp != NULL) {
					string l = "Multiple declaration of " + temp->getName();
					printError(l, numLine);
				} 
				else {
					if (currentDataType != "void")
						table->Insert(*s);
				}
				printToken(symbolName);
			}
| ID
			{
				symbolName = $1->getName();
				printInLogFile("declaration_list : ID", numLine);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				SymbolInfo* s = new SymbolInfo($1->getName(), $1->getType());
				s->setKeyType("variable");
				s->setDataType(currentDataType);

				ScopeTable* st = table->getCurrentScope();
				SymbolInfo* temp = st->LookUp(s->getName());
				if (temp != NULL) {
					string l = "Multiple declaration of " + temp->getName();
					printError(l, numLine);
				} 
				else {
					if (currentDataType != "void")
						table->Insert(*s);
				}
				printToken(symbolName);
			}
| ID LTHIRD CONST_INT RTHIRD
			{
				symbolName = $1->getName() + "[" + $3->getName() + "]";
				printInLogFile("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", numLine);
				
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				SymbolInfo* s = new SymbolInfo($1->getName(), $1->getType());
				s->setKeyType("array");
				s->setDataType(currentDataType);
				int size = stoi($3->getName());
				s->setArraySize(size);

				ScopeTable* st = table->getCurrentScope();
				SymbolInfo* temp = st->LookUp(s->getName());
				if (temp != NULL) {
					string l = "Multiple declaration of " + temp->getName();
					printError(l, numLine);
				}
				else {
					if (currentDataType != "void")
						table->Insert(*s);
				}
				printToken(symbolName);
			}
;


statements : statement
			{
				symbolName = $1->getName();

				printInLogFile("statements : statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| statements statement
			{
				symbolName = $1->getName() + $2->getName();

				printInLogFile("statements : statements statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


statement : var_declaration
			{
				symbolName = $1->getName() + "\n";

				printInLogFile("statement : var_declaration", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| expression_statement
			{
				symbolName = $1->getName() + "\n";

				printInLogFile("statement : expression_statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| compound_statement
			{
				symbolName = $1->getName() + "\n";

				printInLogFile("statement : compound_statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| FOR LPAREN expression_statement expression_statement expression
RPAREN statement
			{
				symbolName = "for ( " + $3->getName() + " " + $4->getName() + " " + $5->getName() + " )\n" + $7->getName() + "\n";

				printInLogFile("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				
			}
| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
			{
				symbolName = "if ( " + $3->getName() + " )\n" + $5->getName() + "\n";

				printInLogFile("statement : IF LPAREN expression RPAREN statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| IF LPAREN expression RPAREN statement ELSE statement
			{
				symbolName = "if ( " + $3->getName() + " )\n" + $5->getName() + "else\n" + $7->getName() + "\n";

				printInLogFile("statement : IF LPAREN expression RPAREN statement ELSE statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| WHILE LPAREN expression RPAREN statement
			{
				symbolName = "while ( " + $3->getName() + " )\n" + $5->getName() + "\n";

				printInLogFile("statement : WHILE LPAREN expression RPAREN statement", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| PRINTLN LPAREN ID RPAREN SEMICOLON
			{
				symbolName = "printf ( " + $3->getName() + " );" + "\n";
				printInLogFile("statement : PRINTLN LPAREN ID RPAREN SEMICOLON", numLine);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				SymbolInfo* s = table->LookUp($3->getName());
				if(s == NULL) {
					string l = "Undeclared variable "+$3->getName();
					printError(l, numLine);
				}
				printToken(symbolName);
			}
| RETURN expression SEMICOLON
			{
				symbolName = "return " + $2->getName() + ";" + "\n";

				printInLogFile("statement : RETURN expression SEMICOLON", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				SymbolInfo* cf = table->LookUp(currentFunction);
				if(cf->getDataType() == "void") {
					printError("warning: ‘return’ with a value, in function returning void", numLine);
				}
				// has to check temp->getDataType() != "float" why don't know
				else if(cf->getDataType() != $2->getDataType()) {
					printError("Function return type error", numLine);
				}
			}
;

expression_statement : SEMICOLON
			{
				symbolName = ";";
				printInLogFile("expression_statement : SEMICOLON", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| expression SEMICOLON
			{
				symbolName = $1->getName() + ";";
				printInLogFile("expression_statement : expression SEMICOLON", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


variable : ID
			{
				symbolName = $1->getName();
				printInLogFile("variable : ID", numLine);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				SymbolInfo* s = table->LookUp($1->getName());
				if(s == NULL){
					printError("Undeclared variable "+symbolName, numLine);
					$$->setKeyType("variable");
					$$->setDataType("none");
				}
				else {
					if(s->getKeyType() == "array"){
						string l = "Type mismatch, "+s->getName()+ " is an array";
						printError(l, numLine);		
					}
					$$ = s;
				}
				printToken(symbolName);
			}
| ID LTHIRD expression RTHIRD
			{
				symbolName = $1->getName() + "[" + $3->getName() + "]";
				printInLogFile("variable : ID LTHIRD expression RTHIRD", numLine);

				SymbolInfo* s = table->LookUp($1->getName());

				if(s == NULL){
					printError("Undeclared variable "+symbolName, numLine);
					$$ = new SymbolInfo(symbolName, "array");
					$$->setKeyType("array");
					$$->setDataType("none");
				}
				else {
					if(s->getKeyType() != "array") {
						string l = "Type mismatch, "+s->getName()+ " is not an array";
						printError(l, numLine);		
					}
					if($3->getDataType() != "int") {
						printError("Expression inside third brackets not an integer", numLine);
					}
					$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
					$$->setKeyType("array");
					$$->setDataType(s->getDataType());
				}
				printToken(symbolName);
			}
;


expression : logic_expression
			{
				symbolName = $1->getName();
				printInLogFile("expression : logic_expression", numLine);
				printToken(symbolName);

				$$ = $1;
			}
| variable ASSIGNOP logic_expression
			{
				symbolName = $1->getName() + " = " + $3->getName();
				printInLogFile("expression : variable ASSIGNOP logic_expression", numLine);

				if($1->getDataType() != "" && $3->getDataType() != "") {
					if($1->getDataType() == "void" || $3->getDataType() == "void") {
						printError("Void function used in expression", numLine);
					}
					else if($1->getDataType() != "none") {
						string d1 = $1->getDataType();
						string d2 = $3->getDataType();
						if(d1 != "float" && d2 == "float") {
							printError("Type mismatch", numLine);
						}
					}
				}

				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;

logic_expression : rel_expression
			{
				symbolName = $1->getName();
				printInLogFile("logic_expression : rel_expression", numLine);
				printToken(symbolName);

				$$ = $1;
			}
| rel_expression LOGICOP rel_expression
			{
				symbolName = $1->getName() + " " + $2->getName() + " " + $3->getName();
				printInLogFile("logic_expression : rel_expression LOGICOP rel_expression", numLine);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				$$->setDataType("int");

				if($1->getDataType()=="void" || $3->getDataType()=="void" ){
					printError("Void function used in expression", numLine);				
				}
				printToken(symbolName);
			}
;


rel_expression : simple_expression
			{
				symbolName = $1->getName();
				printInLogFile("rel_expression : simple_expression", numLine);
				printToken(symbolName);

				$$ = $1;
			}
| simple_expression RELOP simple_expression
			{
				symbolName = $1->getName() + " " + $2->getName() + " " + $3->getName();
				printInLogFile("rel_expression : simple_expression RELOP simple_expression", numLine);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				$$->setDataType("int");

				if($1->getDataType()=="void" || $3->getDataType()=="void" ){
					printError("Void function used in expression", numLine);				
				}

				printToken(symbolName);
			}
;


simple_expression : term
			{
				symbolName = $1->getName();
				printInLogFile("simple_expression : term", numLine);
				printToken(symbolName);

				$$ = $1;
			}
| simple_expression ADDOP term
			{
				symbolName = $1->getName() + " " + $2->getName() + " " + $3->getName();
				printInLogFile("simple_expression : simple_expression ADDOP term", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				if($1->getDataType()=="float" || $3->getDataType()=="float"){
					$$->setDataType("float");
				}
				else if($1->getDataType()=="int" || $3->getDataType()=="int"){
					$$->setDataType("int");
				}
				else if($1->getDataType()=="void" || $3->getDataType()=="void" ){
					printError("Void function used in expression", numLine);								
				} 
			}
;


term : unary_expression
			{
				symbolName = $1->getName();
				printInLogFile("term : unary_expression", numLine);
				printToken(symbolName);

				$$ = $1;
			}
| term MULOP unary_expression
			{
				symbolName = $1->getName() + " " + $2->getName() + " " + $3->getName();
				printInLogFile("term : term MULOP unary_expression", numLine);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");

				if($1->getDataType()=="void" || $3->getDataType()=="void" ){
					printError("Void function used in expression", numLine);								
				}
				if($2->getName() == "%") {
					if($1->getDataType()!="int" || $3->getDataType()!="int"){
						printError("Non-Integer operand on modulus operator", numLine);			
					}
					if($3->getName()=="0"){
						printError("Modulus by Zero", numLine);									
					}
					$$->setDataType("int");
				}
				else{
					if($1->getDataType()=="float" || $3->getDataType()=="float"){
						$$->setDataType("float");
					}
					else{
						$$->setDataType("int");
					}
				}
				printToken(symbolName);
			}
;


unary_expression : ADDOP unary_expression
			{
				symbolName = $1->getName() + " " + $2->getName();
				printInLogFile("unary_expression : ADDOP unary_expression", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				$$->setDataType($2->getDataType());
			}
| NOT unary_expression
			{
				symbolName = "! " + $2->getName();
				printInLogFile("unary_expression : NOT unary_expression", numLine);
				printToken(symbolName);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				$$->setDataType($2->getDataType());
			}
| factor
			{
				symbolName = $1->getName();
				printInLogFile("unary_expression : factor", numLine);
				printToken(symbolName);

				$$ = $1;
			}
;

factor : variable
			{
				symbolName = $1->getName();
				printInLogFile("factor : variable", numLine);
				printToken(symbolName);

				$$ = $1;
			}
| ID LPAREN 
			{
				calledFunction = $1->getName();
			}
argument_list RPAREN
			{
				symbolName = $1->getName() +  " ( " + $4->getName() + " )";
				printInLogFile("factor : ID LPAREN argument_list RPAREN", numLine);

				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				SymbolInfo* s = table->LookUp($1->getName());
				if(s == NULL) {
					string l = "Undeclared function " + calledFunction;
					printError(l, numLine);
					parameterList.clear();
				}
				else {
					vector<SymbolInfo> params = s->getParams();
					int size = s->getParamsNum();

					if (size != parameterList.size()) {
						string l = "Total number of arguments mismatch in function " + calledFunction;
						printError(l, numLine);
						if (size > parameterList.size()) size = parameterList.size(); 
					} 
					for(int i=0; i<size; i++){			
						if(params[i].getDataType() != parameterList[i].getDataType()){
							if(params[i].getDataType()=="float" && parameterList[i].getDataType()=="int") {}
							else{
								string l = to_string(i+1) + "th argument mismatch in function " + calledFunction;
								printError(l, numLine);			
								break;
							}
						}
					}							
					parameterList.clear();
					$$->setDataType(s->getDataType());
				}
				printToken(symbolName);
			}
| LPAREN expression RPAREN
			{
				symbolName = " ( " + $2->getName() + " )";
				printInLogFile("factor : LPAREN expression RPAREN", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				$$->setDataType($2->getDataType());
			}
| CONST_INT
			{
				symbolName = $1->getName();
				printInLogFile("factor : CONST_INT", numLine);
				printToken(symbolName);
				$$ = $1;
				$$->setKeyType("value");
				$$->setDataType("int");
			}
| CONST_FLOAT
			{
				symbolName = $1->getName();
				printInLogFile("factor : CONST_FLOAT", numLine);
				printToken(symbolName);
				$$ = $1;
				$$->setKeyType("value");
				$$->setDataType("float");
			}
| variable INCOP
			{
				symbolName = $1->getName() + $2->getName();
				printInLogFile("factor : variable INCOP", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
| variable DECOP
			{
				symbolName = $1->getName() + $2->getName();
				printInLogFile("factor : variable DECOP", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


argument_list : arguments
			{
				symbolName = $1->getName();
				printInLogFile("argument_list : arguments", numLine);
				printToken(symbolName);
				$$ = $1;
			}
|
			{
				symbolName = " ";
				printInLogFile("argument_list : ", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
			}
;


arguments : arguments COMMA logic_expression
			{
				symbolName = $1->getName() + " , " + $3->getName();
				printInLogFile("arguments : arguments COMMA logic_expression", numLine);
				printToken(symbolName);
				$$ = new SymbolInfo(symbolName, "NON_TERMINAL");
				parameterList.push_back(*$3);	
			}
| logic_expression
			{
				symbolName = $1->getName();
				printInLogFile("arguments : logic_expression", numLine);
				printToken(symbolName);
				$$ = $1;
				parameterList.push_back(*$1);
			}
;

%%
int main(int argc,char *argv[])
{

	FILE* fp;
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	yyin=fp;
	yyparse();

	fclose(log_file);
	fclose(error_file);
	fclose(yyin);
	return 0;
}

