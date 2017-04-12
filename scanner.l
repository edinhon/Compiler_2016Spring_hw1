%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
int num_line = 1;
bool isSrc = true;
bool isToken = true;
char srcBuf[2048];
char tokenBuf[2048];
%}

%x COMMENT
%x STRING
%%

"//"(.)* {
	/*Comment*/
	strcat(srcBuf, yytext);
}

"/*" {
	/*Start Comment*/
	strcat(srcBuf, yytext);
	BEGIN COMMENT;
}

<COMMENT>"*/" {
	/*End Comment*/
	strcat(srcBuf, yytext);
	BEGIN 0;
}
<COMMENT>\n {
	/*During Comment*/
	if(isToken){
		printf("%s", tokenBuf);
	}
	if(isSrc){
		printf("%d:%s\n", num_line, srcBuf);
	}
	
	strcpy(srcBuf, "\0");
	strcpy(tokenBuf, "\0");

	num_line++;
	BEGIN COMMENT;
}
<COMMENT>(.|\\n) {
	/*During Comment*/
	strcat(srcBuf, yytext);
	BEGIN COMMENT;
}

\n { 
	if(isToken){
		printf("%s", tokenBuf);
	}
	if(isSrc){
		printf("%d:%s\n", num_line, srcBuf);
	}
	
	//strcpy(srcBuf, "\0");
	//strcpy(tokenBuf, "\0");
	memset(srcBuf, 0, sizeof srcBuf);
	memset(tokenBuf, 0, sizeof tokenBuf);

	num_line++;
}

\t {
	strcat(srcBuf, yytext);
}

" " {
	strcat(srcBuf, yytext);
}

"#pragma source on" {
	isSrc = true;
	strcat(srcBuf, yytext);
}

"#pragma source off" {
	isSrc = false;
	strcat(srcBuf, yytext);
}

"#pragma token on" {
	isToken = true;
	strcat(srcBuf, yytext);
}

"#pragma token off" {
	isToken = false;
	strcat(srcBuf, yytext);
}

void|int|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default|remove|rename|tmpfile|tmpnam|fclose|fflush|fopen|freopen|setbuf|setvbuf|fprintf|fscanf|printf|scanf|snprintf|sprintf|sscanf|vfprintf|vscanf|vprintf|vscanf|vsnprintf|vsprintf|vsscanf|fgetc|fgets|fputc|fputs|getc|getchar|gets|putc|putchar|puts|ungetc|fread|fwrite|fgetpos|fseek|fsetpos|ftell|rewind|clearerr|feof|ferror|perror {
	/*Keywords*/
	strcat(tokenBuf, "#key:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
	
}

("_"|[a-zA-Z])([a-zA-Z0-9]|"_")* {
	/*Identifier*/
	strcat(tokenBuf, "#id:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
}

[0-9]/([a-zA-Z]|"_") {
	/*Identifier&Integer Error*/
	fprintf(stderr, "Error at line %d: %s\n", num_line, yytext);exit(1);
}

"+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"=!"|"="|"&&"|"||"|"!"|"&" {
	/*Operators*/
	strcat(tokenBuf, "#op:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
}

":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}" {
	/*Punctuation*/
	strcat(tokenBuf, "#punc:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
}

(([0-9]+)|((([0-9]*)"."([0-9])+)|(([0-9]+)"."([0-9]*))))(E|e)("-")?[0-9]+ {
	/*Sci*/
	/*(Int+Double)(E+e)(Int)*/
	strcat(tokenBuf, "#sci:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
}

([1-9]([0-9])*)|"0" {
	/*Integer*/
	strcat(tokenBuf, "#integer:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
}

"0"/[0-9]+ {
	/*Integer Error*/
	fprintf(stderr, "Error at line %d: %s\n", num_line, yytext);exit(1);
}

(([0-9]*)"."([0-9])+)|(([0-9]+)"."([0-9]*)) {
	/*Double*/
	strcat(tokenBuf, "#double:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
}

\'(.|\\n|\\t)\' {
	/*Char*/
	strcat(tokenBuf, "#char:");
	strcat(tokenBuf, yytext);
	strcat(tokenBuf, "\n");
	strcat(srcBuf, yytext);
}

\" {
	/*String*/
	strcat(srcBuf, yytext);
	strcat(tokenBuf, "#string:");
	BEGIN STRING;
}
<STRING>\" {
	/*End String*/
	strcat(srcBuf, yytext);
	strcat(tokenBuf, "\n");
	BEGIN 0;
}
<STRING>\n {
	/*Error String*/
	fprintf(stderr, "Error at line %d: %s\n", num_line, yytext);exit(1);
}
<STRING>(.|\\n) {
	/*During String*/
	strcat(srcBuf, yytext);
	strcat(tokenBuf, yytext);
	BEGIN STRING;
}

. {
	fprintf(stderr, "Error at line %d: %s\n", num_line, yytext); exit(1);
}

%%

int main(void)
{
	yylex();
	return 0;
}

int yywrap()
{
	return 1;
}

