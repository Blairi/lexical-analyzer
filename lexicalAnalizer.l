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
    // arreglo de 100 espacios de memoria
    Simbolo simbolos[100];
    // longitud de la tabla
    int cantidad;
} TablaSimbolos;

// estructura para guardar las literales
typedef struct {
    int posicion;
    char dato[100];
} Literal;

// tabla para guardar literales tipo cadena
typedef struct {
    // arreglo de 100 espacios
    Literal cadenas[100];
    // longitud de la tabla
    int cantidad;
} TablaLiteralesCadenas;

// tabla para guardar literales tipo cadena
typedef struct {
    // arreglo de 100 espacios
    Literal flotantes[100];
    // longitud de la tabla
    int cantidad;
} TablaLiteralesFlotantes;

// tabla para guardar literales enteras
typedef struct {
    // arreglo de 100 espacios
    Literal enteros[100];
    // longitud de la tabla
    int cantidad;
} TablaLiteralesEnteros;

/* Firmas de funciones de inserción */
void insertar_simbolo(TablaSimbolos *tabla, const char *nombre);
void insertar_literal_cadena(TablaLiteralesCadenas *tabla, const char *dato);
void insertar_literal_flotante(TablaLiteralesFlotantes *tabla, const char *dato);
void insertar_literal_entero(TablaLiteralesEnteros *tabla, const char *dato);

/* Tablas de símbolos y literales */
TablaSimbolos tabla_simbolos;
TablaLiteralesCadenas tabla_literales_cadenas;
TablaLiteralesFlotantes tabla_literales_flotantes;
TablaLiteralesEnteros tabla_literales_enteros;

/* Archivos de entrada y salida*/
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

IDENT           {LETRA}({LETRA}|{DIGITO}|_)*
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
"CHAR"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 2\n"); }
"CONTINUE"       { fprintf(archivoSalida, "Token: Clase 5, Valor: 3\n"); }
"DO"             { fprintf(archivoSalida, "Token: Clase 5, Valor: 4\n"); }
"DOUBLE"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 5\n"); }
"ELSE"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 6\n"); }
"FLOAT"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 7\n"); }
"FOR"            { fprintf(archivoSalida, "Token: Clase 5, Valor: 8\n"); }
"IF"             { fprintf(archivoSalida, "Token: Clase 5, Valor: 9\n"); }
"INT"            { fprintf(archivoSalida, "Token: Clase 5, Valor: 10\n"); }
"LONG"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 11\n"); }
"RETURN"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 12\n"); }
"SHORT"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 13\n"); }
"SIZEOF"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 14\n"); }
"SWITCH"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 15\n"); }
"UNSIGNED"       { fprintf(archivoSalida, "Token: Clase 5, Valor: 16\n"); }
"VOID"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 17\n"); }
"WHILE"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 18\n"); }

"="              { fprintf(archivoSalida, "Token: Clase 6, Valor: 0\n"); }
"\+="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 1\n"); }
"\-="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 2\n"); }
"\*="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 3\n"); }
"\/="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 4\n"); }
"\%="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 5\n"); }
"\&="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 6\n"); }
"\^="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 7\n"); }
"\|="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 8\n"); }
"<<="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 9\n"); }
">>="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 10\n"); }

"\|\|"           { fprintf(archivoSalida, "Token: Clase 7, Valor: 0\n"); }
"&&"             { fprintf(archivoSalida, "Token: Clase 7, Valor: 1\n"); }
"!"              { fprintf(archivoSalida, "Token: Clase 7, Valor: 2\n"); }

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

/**
 * Funcion principal para correr el programa
 * @param argc numero de argumentos
 * @param argv apuntadores de argumentos
 * @return retorna entero
 */
int main(int argc, char **argv) {

    // si se corre el programa usando argumentos
    if (argc > 1) {
        // abrir el archivo de codigo fuente
        archivoEntrada = fopen(argv[1], "r");

        // si el archivo no existe o no se encuentra
        if (!archivoEntrada) {
            perror("Error al abrir el archivo");
            return 1;
        }
        
        // archivo de entrada leido correctamente
        yyin = archivoEntrada;

        // si se elige un archivo de salida, escribimos en este
        if(argc > 2) {
            // creamos un archivo leyendo el argumento 2
            archivoSalida = fopen(argv[2], "w");

            // si ocurre un error al momento de crear el archivo
            if (!archivoSalida) {
                perror("Error al abrir el archivo de salida");
                return 1;
            }
        }
        // si no se proporciona el archivo de salida, usamos la consola
        else {  
            archivoSalida = stdout;
        }
    }

    // llamada el comando de lex para la creacion de una maquina de estados finitos
    yylex();

    // impresion de cada una de las tablas generadas

    fprintf(archivoSalida, "Tabla de símbolos:\n");
    for (int i = 0; i < tabla_simbolos.cantidad; i++) {
        fprintf(archivoSalida, "TIPO[%d] símbolo %d: %s\n", tabla_simbolos.simbolos[i].tipo, i, tabla_simbolos.simbolos[i].nombre);
    }

    fprintf(archivoSalida, "Tabla de literales (cadenas):\n");
    for (int i = 0; i < tabla_literales_cadenas.cantidad; i++) {
        fprintf(archivoSalida, "Cadena %d: %s\n", i, tabla_literales_cadenas.cadenas[i].dato);
    }

    fprintf(archivoSalida, "Tabla de literales (flotantes):\n");
    for (int i = 0; i < tabla_literales_flotantes.cantidad; i++) {
        fprintf(archivoSalida, "Flotante %d: %s\n", i, tabla_literales_flotantes.flotantes[i].dato);
    }

    fprintf(archivoSalida, "Tabla de literales (enteros):\n");
    for (int i = 0; i < tabla_literales_enteros.cantidad; i++) {
        fprintf(archivoSalida, "Entero %d: %s\n", i, tabla_literales_enteros.enteros[i].dato);
    }

    return 0;
}


/**
 * Funcion para insertar simbolo/identificadores
 * @param TablaSimbolos instancia de la tabla de simbolos
 * @param nombre nombre de identificador
 * @return void
 */
void insertar_simbolo(TablaSimbolos *tabla, const char *nombre) {

    // buscamos si es que ya existe ese identificador en la tabla de simbolos
    for (int i = 0; i < tabla->cantidad; i++) { // O(n)
        if (strcmp(tabla->simbolos[i].nombre, nombre) == 0) {
            // si se encontro el mismo identificador, matamos la funcion
            return;
        }
    }

    //si es un nuevo simbolo ...

    // copiamos el simbolo a la tabla
    strcpy(tabla->simbolos[tabla->cantidad].nombre, nombre);

    tabla->simbolos[tabla->cantidad].tipo = -1;
    tabla->cantidad++; // aumentamos la longitud de la tabla
}


/**
 * Funcion para insertar literales cadena
 * @param TablaLiteralesCadenas instancia de la tabla de literales de cadena
 * @param dato literal cadena
 * @return void
 */
void insertar_literal_cadena(TablaLiteralesCadenas *tabla, const char *dato) {
    // copiamos la cadena a la tabla
    strcpy(tabla->cadenas[tabla->cantidad].dato, dato);
    tabla->cantidad++; // aumentamos la longitud de la tabla
}


/**
 * Funcion para insertar literales flotantes
 * @param TablaLiteralesFlotantes instancia de la tabla de literales flotantes
 * @param dato literal flotante
 * @return void
 */
void insertar_literal_flotante(TablaLiteralesFlotantes *tabla, const char *dato) {
    // copiamos el flotante a la tabla
    strcpy(tabla->flotantes[tabla->cantidad].dato, dato);
    tabla->cantidad++; // aumentamos la longitud de la tabla
}


/**
 * Funcion para insertar literales enteras
 * @param TablaLiteralesEnteros instancia de la tabla de literales enteras
 * @param dato literal entera
 * @return void
 */
void insertar_literal_entero(TablaLiteralesEnteros *tabla, const char *dato) {

    // buscamos si es que ya existe ese entero en la tabla de enteros
    for (int i = 0; i < tabla->cantidad; i++) { // O(n)
        if (strcmp(tabla->enteros[i].dato, dato) == 0) {
            // si se encontro el mismo identificador, matamos la funcion
            return;
        }
    }

    //si es un nuevo entero ...

    // copiamos el entero a la tabla
    strcpy(tabla->enteros[tabla->cantidad].dato, dato);

    tabla->cantidad++; // aumentamos la longitud de la tabla
}
