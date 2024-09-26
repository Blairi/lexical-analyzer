%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int posicion;
    char nombre[16];
    int tipo;
} Simbolo;

typedef struct {
    Simbolo simbolos[100];
    int cantidad;
} TablaSimbolos;

typedef struct {
    int posicion;
    char dato[100];
} Literal;

typedef struct {
    Literal cadenas[100];
    int cantidad;
} TablaLiteralesCadenas;

typedef struct {
    Literal flotantes[100];
    int cantidad;
} TablaLiteralesFlotantes;

typedef struct {
    Literal enteros[100];
    int cantidad;
} TablaLiteralesEnteros;

/* Funciones de inserción */
void insertar_simbolo(TablaSimbolos *tabla, const char *nombre);
void insertar_literal_cadena(TablaLiteralesCadenas *tabla, const char *dato);
void insertar_literal_flotante(TablaLiteralesFlotantes *tabla, const char *dato);
void insertar_literal_entero(TablaLiteralesEnteros *tabla, const char *dato);

/* Tablas de símbolos y literales */
TablaSimbolos tabla_simbolos;
TablaLiteralesCadenas tabla_literales_cadenas;
TablaLiteralesFlotantes tabla_literales_flotantes;
TablaLiteralesEnteros tabla_literales_enteros;

%}

%option noyywrap

DIGITO          [0-9]
LETRA           [a-zA-Z]
STRING          "#"([^#\n]|\\#)*"#"
COMMENT_LINE    "~~".*"\n"
COMMENT_BLOCK   "~/"(.|\n)*"\\~"

OP_SUMA         "+"
OP_RESTA        "-"
OP_MULT         "*"
OP_DIV          "/"

IDENT           {LETRA}({LETRA}|{DIGITO}|_)*
ENTERO          {DIGITO}+[ul]?
FLOAT           {DIGITO}+"."{DIGITO}+(e[+-]?{DIGITO}+)?

%%

{ENTERO}         { printf("Token: Clase 0, Valor: %d\n", tabla_literales_enteros.cantidad);
                    insertar_literal_entero(&tabla_literales_enteros, yytext);
                  }

{FLOAT}          { printf("Token: Clase 1, Valor: %d\n", tabla_literales_flotantes.cantidad);
                    insertar_literal_flotante(&tabla_literales_flotantes, yytext);
                  }

{OP_SUMA}        { printf("Token: Clase 2, Valor: 0\n"); }
{OP_RESTA}       { printf("Token: Clase 2, Valor: 1\n"); }
{OP_MULT}        { printf("Token: Clase 2, Valor: 2\n"); }
{OP_DIV}         { printf("Token: Clase 2, Valor: 3\n"); }

"%"              { printf("Token: Clase 2, Valor: 4\n"); }
"\+\+"           { printf("Token: Clase 2, Valor: 5\n"); }
"\-\-"           { printf("Token: Clase 2, Valor: 6\n"); }
"\*\*"           { printf("Token: Clase 2, Valor: 7\n"); }

[\{\}\[\]\(\)\.] { printf("Token: Clase 3, Valor: %c\n", yytext[0]); }

{STRING}         { printf("Token: Clase 4, Valor: %d\n", tabla_literales_cadenas.cantidad);
                    insertar_literal_cadena(&tabla_literales_cadenas, yytext);
                  }

"BREAK"          { printf("Token: Clase 5, Valor: 0\n"); }
"CASE"           { printf("Token: Clase 5, Valor: 1\n"); }
"CHAR"           { printf("Token: Clase 5, Valor: 2\n"); }
"CONTINUE"       { printf("Token: Clase 5, Valor: 3\n"); }
"DO"             { printf("Token: Clase 5, Valor: 4\n"); }
"DOUBLE"         { printf("Token: Clase 5, Valor: 5\n"); }
"ELSE"           { printf("Token: Clase 5, Valor: 6\n"); }
"FLOAT"          { printf("Token: Clase 5, Valor: 7\n"); }
"FOR"            { printf("Token: Clase 5, Valor: 8\n"); }
"IF"             { printf("Token: Clase 5, Valor: 9\n"); }
"INT"            { printf("Token: Clase 5, Valor: 10\n"); }
"LONG"           { printf("Token: Clase 5, Valor: 11\n"); }
"RETURN"         { printf("Token: Clase 5, Valor: 12\n"); }
"SHORT"          { printf("Token: Clase 5, Valor: 13\n"); }
"SIZEOF"         { printf("Token: Clase 5, Valor: 14\n"); }
"SWITCH"         { printf("Token: Clase 5, Valor: 15\n"); }
"UNSIGNED"       { printf("Token: Clase 5, Valor: 16\n"); }
"VOID"           { printf("Token: Clase 5, Valor: 17\n"); }
"WHILE"          { printf("Token: Clase 5, Valor: 18\n"); }

"="              { printf("Token: Clase 6, Valor: 0\n"); }
"\+="            { printf("Token: Clase 6, Valor: 1\n"); }

"\|\|"           { printf("Token: Clase 7, Valor: 0\n"); }
"&&"             { printf("Token: Clase 7, Valor: 1\n"); }
"!"              { printf("Token: Clase 7, Valor: 2\n"); }

{IDENT}          { printf("Token: Clase 8, Valor: %d\n", tabla_simbolos.cantidad);
                    insertar_simbolo(&tabla_simbolos, yytext);
                  }

{COMMENT_LINE}   { }
{COMMENT_BLOCK}  { }

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

    printf("Tabla de símbolos:\n");
    for (int i = 0; i < tabla_simbolos.cantidad; i++) {
        printf("TIPO[%d] símbolo %d: %s\n", tabla_simbolos.simbolos[i].tipo, i, tabla_simbolos.simbolos[i].nombre);
    }

    printf("Tabla de literales (cadenas):\n");
    for (int i = 0; i < tabla_literales_cadenas.cantidad; i++) {
        printf("Cadena %d: %s\n", i, tabla_literales_cadenas.cadenas[i].dato);
    }

    printf("Tabla de literales (flotantes):\n");
    for (int i = 0; i < tabla_literales_flotantes.cantidad; i++) {
        printf("Flotante %d: %s\n", i, tabla_literales_flotantes.flotantes[i].dato);
    }

    printf("Tabla de literales (enteros):\n");
    for (int i = 0; i < tabla_literales_enteros.cantidad; i++) {
        printf("Entero %d: %s\n", i, tabla_literales_enteros.enteros[i].dato);
    }

    return 0;
}

void insertar_simbolo(TablaSimbolos *tabla, const char *nombre) {
    for (int i = 0; i < tabla->cantidad; i++) {
        if (strcmp(tabla->simbolos[i].nombre, nombre) == 0) {
            return;
        }
    }
    strcpy(tabla->simbolos[tabla->cantidad].nombre, nombre);
    tabla->simbolos[tabla->cantidad].tipo = -1;
    tabla->cantidad++;
}

void insertar_literal_cadena(TablaLiteralesCadenas *tabla, const char *dato) {
    strcpy(tabla->cadenas[tabla->cantidad].dato, dato);
    tabla->cantidad++;
}

void insertar_literal_flotante(TablaLiteralesFlotantes *tabla, const char *dato) {
    strcpy(tabla->flotantes[tabla->cantidad].dato, dato);
    tabla->cantidad++;
}

void insertar_literal_entero(TablaLiteralesEnteros *tabla, const char *dato) {
    for (int i = 0; i < tabla->cantidad; i++) {
        if (strcmp(tabla->enteros[i].dato, dato) == 0) {
            return;
        }
    }
    strcpy(tabla->enteros[tabla->cantidad].dato, dato);
    tabla->cantidad++;
}
