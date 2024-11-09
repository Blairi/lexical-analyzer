%{
/*
    Compiladores -------------------

    Autores:
        - Montiel Aviles Axel Fernando
        - Guadarrama Herrera Ken Bryan

    Objetivo: Construir, en un mismo programa, los analizadores Lexico y Sintactico Descendente
        Recursivo que revisen programas escritos en el lenguaje definido por la gramatica del
        Anexo A de este documento.
*/

// bibliotecas estandar
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// estructura para guardar los simbolos
typedef struct {
    int posicion;
    char nombre[14];
    int tipo;
} Simbolo;

// estructura para la tabla de simbolos
typedef struct {
    Simbolo simbolos[100];
    int cantidad;
} TablaSimbolos;

// estructura para guardar las literales
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

void insertar_simbolo(TablaSimbolos *tabla, const char *nombre);
void insertar_literal_cadena(TablaLiteralesCadenas *tabla, const char *dato);
void insertar_literal_flotante(TablaLiteralesFlotantes *tabla, const char *dato);
void insertar_literal_entero(TablaLiteralesEnteros *tabla, const char *dato);

TablaSimbolos tabla_simbolos;
TablaLiteralesCadenas tabla_literales_cadenas;
TablaLiteralesFlotantes tabla_literales_flotantes;
TablaLiteralesEnteros tabla_literales_enteros;

FILE *archivoEntrada = NULL;
FILE *archivoSalida = NULL;

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

// Modificamos IDENT para aceptar hasta 15 caracteres
IDENT           {LETRA}({LETRA}|{DIGITO}|_){0,14}
ENTERO          {DIGITO}+[ul]?
FLOAT           {DIGITO}+"."{DIGITO}+(e[+-]?{DIGITO}+)?

%%

{ENTERO}         { fprintf(archivoSalida, "Token: Clase 0, Valor: %s\n", yytext);
                    insertar_literal_entero(&tabla_literales_enteros, yytext);
                  }

\s*([0-9]+)(u|l|ul|U|L|UL) { fprintf(archivoSalida, "Token: Clase 0, Valor: %s\n", yytext);
                             insertar_literal_entero(&tabla_literales_enteros, yytext);
                            }

{FLOAT}          { fprintf(archivoSalida, "Token: Clase 1, Valor: %d\n", tabla_literales_flotantes.cantidad);
                    insertar_literal_flotante(&tabla_literales_flotantes, yytext);
                  }

{OP_SUMA}        { fprintf(archivoSalida, "Token: Clase 2, Valor: 0\n"); }
{OP_RESTA}       { fprintf(archivoSalida, "Token: Clase 2, Valor: 1\n"); }
{OP_MULT}        { fprintf(archivoSalida, "Token: Clase 2, Valor: 2\n"); }
{OP_DIV}         { fprintf(archivoSalida, "Token: Clase 2, Valor: 3\n"); }

"%"              { fprintf(archivoSalida, "Token: Clase 2, Valor: 4\n"); }
"\+\+"           { fprintf(archivoSalida, "Token: Clase 2, Valor: 5\n"); }
"\-\-"           { fprintf(archivoSalida, "Token: Clase 2, Valor: 6\n"); }
"\*\*"           { fprintf(archivoSalida, "Token: Clase 2, Valor: 7\n"); }

[\{\}\[\]\(\)\.] { fprintf(archivoSalida, "Token: Clase 3, Valor: %c\n", yytext[0]); }

{STRING}         { fprintf(archivoSalida, "Token: Clase 4, Valor: %d\n", tabla_literales_cadenas.cantidad);
                    insertar_literal_cadena(&tabla_literales_cadenas, yytext);
                  }

"BREAK"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 0\n"); }
"CASE"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 1\n"); }
// (continúan los tokens de palabras clave...)

{IDENT}          {
                    if (strlen(yytext) > 15) {
                        fprintf(archivoSalida, "Error léxico: Identificador excede los 15 caracteres: %s\n", yytext);
                    } else {
                        fprintf(archivoSalida, "Token: Clase 8, Valor: %d\n", tabla_simbolos.cantidad);
                        insertar_simbolo(&tabla_simbolos, yytext);
                    }
                 }

{COMMENT_LINE}   { }
{COMMENT_BLOCK}  { }

[ \t\n]+         { }

.                { fprintf(archivoSalida, "Error léxico: %s\n", yytext); }

%%

// (continuación de funciones, incluyendo `insertar_simbolo`...)

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
