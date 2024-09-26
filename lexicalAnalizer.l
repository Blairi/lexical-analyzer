%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int clase;
    int valor;
} Token;

typedef struct {
    int posicion;
    char nombre[16];
    int tipo;
} Simbolo;

typedef struct {
    int posicion;
    char dato[100];
} Literal;

void insertar_simbolo(const char *nombre);
void insertar_literal(const char *dato);

Simbolo tabla_simbolos[100];
Literal tabla_literales[100];
int pos_simbolos = 0;
int pos_literales = 0;

%}

%option noyywrap

/* expresiones regulares */
DIGITO          [0-9]
LETRA           [a-zA-Z]
STRING          [#\#.*\##]
COMMENT_LINE    "~~".*"\n"
COMMENT_BLOCK   "~/"(.|\n)*"\\~"

/* operadores aritmeticos */
OP_SUMA         "+"
OP_RESTA        "-"
OP_MULT         "*"
OP_DIV          "/"

IDENT           {LETRA}({LETRA}|{DIGITO}|_)*
ENTERO          {DIGITO}+[ul]?
FLOAT           {DIGITO}+"."{DIGITO}+(e[+-]?{DIGITO}+)?

%%

{ENTERO}         { printf("Token: Clase 0, Valor: %d\n", atoi(yytext)); 
                    insertar_literal(yytext);
                    }

{FLOAT}          { printf("Token: Clase 1, Valor: %d\n", pos_literales);
                    insertar_literal(yytext);
                  }

{OP_SUMA}              { printf("Token: Clase 2, Valor: 0\n"); }
{OP_RESTA}              { printf("Token: Clase 2, Valor: 1\n"); }
{OP_MULT}              { printf("Token: Clase 2, Valor: 2\n"); }
{OP_DIV}               { printf("Token: Clase 2, Valor: 3\n"); }

"%"               { printf("Token: Clase 2, Valor: 4\n"); }
"\+\+"            { printf("Token: Clase 2, Valor: 5\n"); }
"\-\-"            { printf("Token: Clase 2, Valor: 6\n"); }
"\*\*"            { printf("Token: Clase 2, Valor: 7\n"); }

"\{"              { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }
"\}"              { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }
"\["              { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }
"\]"              { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }
"\("              { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }
"\)"              { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }
"."             { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }

{STRING}         { printf("Token: Clase 4, Valor: %d\n", pos_literales);
                    insertar_literal(yytext);
                  }

"BREAK"          { printf("Token: Clase 5, Valor: 0\n"); }
"CASE"           { printf("Token: Clase 5, Valor: 1\n"); }

"="              { printf("Token: Clase 6, Valor: 0\n"); }
"\+="            { printf("Token: Clase 6, Valor: 1\n"); }

"\|\|"           { printf("Token: Clase 7, Valor: 0\n"); }
"&&"             { printf("Token: Clase 7, Valor: 1\n"); }
"!"              { printf("Token: Clase 7, Valor: 2\n"); }

{IDENT}          { printf("Token: Clase 8, Valor: %d\n", pos_simbolos);
                    insertar_simbolo(yytext);
                  }

{COMMENT_LINE}   { }
{COMMENT_BLOCK}  { }
","  { }

[ \t\n]+         { }

.                { printf("Error léxico: %s\n", yytext); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            perror("Error al abrir el archivo");
            return 1;
        }
        yyin = archivo;
    }
    yylex();

    printf("Tabla de simbolos:\n");
    for(int i = 0; i<pos_simbolos; i++) {
        printf("TIPO[%d] simbolo %d: %s\n", tabla_simbolos[i].tipo, i, tabla_simbolos[i].nombre);
    }

    printf("Tabla de literales:\n");
    for(int i = 0; i<pos_literales; i++) {
        printf("literal %d: %s\n", i, tabla_literales[i].dato);
    }
    return 0;
}


void insertar_simbolo(const char *nombre) {

    // buscar simbolo antes de insertar (evitando repetidos)
    for(int i = 0; i<pos_simbolos; i++ ){ // O(n)
        // si ya existe en la tabla...
        if(strcmp( tabla_simbolos[i].nombre, nombre ) == 0)
            return;
    }

    // si aun NO existe en la tabla de simbolos...
    strcpy(tabla_simbolos[pos_simbolos].nombre, nombre);

    // TODO: Buscar tipo del simbolo
    tabla_simbolos[pos_simbolos].tipo = -1;

    pos_simbolos++;
}


void insertar_literal(const char *dato) {
    strcpy(tabla_literales[pos_literales].dato, dato);
    pos_literales++;
}