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

// funciones auxiliares
void imprimir_tablas();

/* Tablas de símbolos y literales */
TablaSimbolos tabla_simbolos;
TablaLiteralesCadenas tabla_literales_cadenas;
TablaLiteralesFlotantes tabla_literales_flotantes;
TablaLiteralesEnteros tabla_literales_enteros;

/* Archivos de entrada y salida*/
FILE *archivoEntrada = NULL;
FILE *archivoSalida = NULL;

/*
    ----------------------------------------
    Variables y constantes para el analizador sintactico
    -----------------------------------------
*/
typedef struct {
    char *cadena;
    int longitud;
} CadenaAtomos;

CadenaAtomos *cadena_atomos;

void inicializar_cadena();
void insertar_atomo(char c);

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
                    insertar_atomo('n');
                  }

\s*([0-9]+)(u|l|ul|U|L|UL) { fprintf(archivoSalida, "Token: Clase 0, Valor: %s\n", yytext);
                             insertar_literal_entero(&tabla_literales_enteros, yytext);
                             insertar_atomo('n');
                            }

{FLOAT}          { fprintf(archivoSalida, "Token: Clase 1, Valor: %d\n", tabla_literales_flotantes.cantidad);
                    insertar_literal_flotante(&tabla_literales_flotantes, yytext);
                    insertar_atomo('r');
                  }

{OP_SUMA}        { fprintf(archivoSalida, "Token: Clase 2, Valor: 0\n"); 
                    insertar_atomo('+');
                    }
{OP_RESTA}       { fprintf(archivoSalida, "Token: Clase 2, Valor: 1\n"); 
                    insertar_atomo('-');
                    }
{OP_MULT}        { fprintf(archivoSalida, "Token: Clase 2, Valor: 2\n"); 
                    insertar_atomo('*');
                    }
{OP_DIV}         { fprintf(archivoSalida, "Token: Clase 2, Valor: 3\n"); 
                    insertar_atomo('/');
                    }

"%"              { fprintf(archivoSalida, "Token: Clase 2, Valor: 4\n"); 
                    insertar_atomo('%');
                    }
"\+\+"           { fprintf(archivoSalida, "Token: Clase 2, Valor: 5\n"); 
                    insertar_atomo('m');
                    }
"\-\-"           { fprintf(archivoSalida, "Token: Clase 2, Valor: 6\n"); 
                    insertar_atomo('l');
                    }
"\*\*"           { fprintf(archivoSalida, "Token: Clase 2, Valor: 7\n"); 
                    insertar_atomo('p');
                    }

[\{\}\[\]\(\)\.] { fprintf(archivoSalida, "Token: Clase 3, Valor: %c\n", yytext[0]); 
                    insertar_atomo(yytext[0]);
                }

{STRING}         { fprintf(archivoSalida, "Token: Clase 4, Valor: %d\n", tabla_literales_cadenas.cantidad);
                    insertar_literal_cadena(&tabla_literales_cadenas, yytext);
                    insertar_atomo('s');
                  }

"BREAK"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 0\n");  
                    insertar_atomo('b');
                    }
"CASE"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 1\n"); 
                    insertar_atomo('z');
                    }
"CHAR"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 2\n"); 
                    insertar_atomo('h');
                    }
"CONTINUE"       { fprintf(archivoSalida, "Token: Clase 5, Valor: 3\n");  
                    insertar_atomo('c');
                    }
"DO"             { fprintf(archivoSalida, "Token: Clase 5, Valor: 4\n");  
                    insertar_atomo('d');
                    }
"DOUBLE"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 5\n");  
                    insertar_atomo('u');
                    }
"ELSE"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 6\n");  
                    insertar_atomo('e');
                    }
"FLOAT"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 7\n");  
                    insertar_atomo('f');
                    }
"FOR"            { fprintf(archivoSalida, "Token: Clase 5, Valor: 8\n");  
                    insertar_atomo('v');
                    }
"IF"             { fprintf(archivoSalida, "Token: Clase 5, Valor: 9\n");  
                    insertar_atomo('i');
                    }
"INT"            { fprintf(archivoSalida, "Token: Clase 5, Valor: 10\n"); 
                    insertar_atomo('t');
                }
"LONG"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 11\n");  
                    insertar_atomo('g');
                    }
"RETURN"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 12\n"); 
                    insertar_atomo('x');
                    }
"SHORT"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 13\n"); 
                    insertar_atomo('y');
                    }
"SIZEOF"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 14\n"); 
                    insertar_atomo('j');
                    }
"SWITCH"         { fprintf(archivoSalida, "Token: Clase 5, Valor: 15\n"); 
                    insertar_atomo('k');
                    }
"UNSIGNED"       { fprintf(archivoSalida, "Token: Clase 5, Valor: 16\n");  
                    insertar_atomo('q');
                    }
"VOID"           { fprintf(archivoSalida, "Token: Clase 5, Valor: 17\n");  
                    insertar_atomo('o');
                    }
"WHILE"          { fprintf(archivoSalida, "Token: Clase 5, Valor: 18\n"); 
                    insertar_atomo('w');
                    }

"="              { fprintf(archivoSalida, "Token: Clase 6, Valor: 0\n"); 
                    insertar_atomo('=');
                }
"\+="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 1\n");  
                    insertar_atomo('#');
                    }
"\-="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 2\n");  
                    insertar_atomo(';');
                    }
"\*="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 3\n");  
                    insertar_atomo('$');
                    }
"\/="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 4\n");  
                    insertar_atomo(',');
                    }
"\%="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 5\n");  
                    insertar_atomo('?');
                    }
"\&="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 6\n");  
                    insertar_atomo(':');
                    }
"\^="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 7\n");  
                    insertar_atomo('^');
                    }
"\|="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 8\n");  
                    insertar_atomo('@');
                    }
"<<="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 9\n");  
                    insertar_atomo('<');
                    }
">>="            { fprintf(archivoSalida, "Token: Clase 6, Valor: 10\n");  
                    insertar_atomo('>');
                    }

"\|\|"           { fprintf(archivoSalida, "Token: Clase 7, Valor: 0\n");  
                    insertar_atomo('|');
                    }
"&&"             { fprintf(archivoSalida, "Token: Clase 7, Valor: 1\n");  
                    insertar_atomo('&');
                    }
"!"              { fprintf(archivoSalida, "Token: Clase 7, Valor: 2\n");  
                    insertar_atomo('!');
                    }

{IDENT}          {
                    if (strlen(yytext) > 15) {
                        fprintf(archivoSalida, "Error léxico: Identificador excede los 15 caracteres: %s\n", yytext);
                    } else {
                        fprintf(archivoSalida, "Token: Clase 8, Valor: %d\n", tabla_simbolos.cantidad);
                        insertar_simbolo(&tabla_simbolos, yytext);
                        insertar_atomo('a');
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

    inicializar_cadena();

    // llamada el comando de lex para la creacion de una maquina de estados finitos
    yylex();

    imprimir_tablas();
    
    // Analizador Sintactico
    printf("\nCadena de atomos generada:\n%s\n", cadena_atomos->cadena);

    return 0;
}


void inicializar_cadena() {
    // asignar memoria a la estructura de CadenaAtomos
    cadena_atomos = malloc(sizeof(CadenaAtomos));
    if (cadena_atomos == NULL) {
        printf("Error al asignar memoria\n");
        exit(1);
    }

    // inicializar y asignar memoria para la cadena 
    cadena_atomos->cadena = malloc(1 * sizeof(char));  // al menos 1 byte para string vacio
    if (cadena_atomos->cadena == NULL) {
        printf("Error al asignar memoria\n");
        free(cadena_atomos);
        exit(1);
    }

    // inicializar cadena vacia
    cadena_atomos->cadena[0] = '\0';  // caracter nulo

    // inicializar longitud de cadena 0
    cadena_atomos->longitud = 0;
}


void insertar_atomo(char c) {
    // realocar memoria para el string, uno para el caracter y otro para el null
    cadena_atomos->cadena = realloc(cadena_atomos->cadena, (cadena_atomos->longitud + 2) * sizeof(char));
    if (cadena_atomos->cadena == NULL) {
        printf("Error al asignar memoria\n");
        exit(1);
    }

    // concatenar el nuevo caracter y el nulo a la cadena
    cadena_atomos->cadena[cadena_atomos->longitud] = c;
    cadena_atomos->cadena[cadena_atomos->longitud + 1] = '\0';  // carcater nulo

    // incrementamos la longitud
    cadena_atomos->longitud++;
}


void imprimir_tablas() {
    // impresion de cada una de las tablas generadas
    fprintf(archivoSalida, "\nTabla de símbolos:\n");
    for (int i = 0; i < tabla_simbolos.cantidad; i++) {
        fprintf(archivoSalida, "TIPO[%d] símbolo %d: %s\n", tabla_simbolos.simbolos[i].tipo, i, tabla_simbolos.simbolos[i].nombre);
    }

    fprintf(archivoSalida, "\nTabla de literales (cadenas):\n");
    for (int i = 0; i < tabla_literales_cadenas.cantidad; i++) {
        fprintf(archivoSalida, "Cadena %d: %s\n", i, tabla_literales_cadenas.cadenas[i].dato);
    }

    fprintf(archivoSalida, "\nTabla de literales (flotantes):\n");
    for (int i = 0; i < tabla_literales_flotantes.cantidad; i++) {
        fprintf(archivoSalida, "Flotante %d: %s\n", i, tabla_literales_flotantes.flotantes[i].dato);
    }

    fprintf(archivoSalida, "\nTabla de literales (enteros):\n");
    for (int i = 0; i < tabla_literales_enteros.cantidad; i++) {
        fprintf(archivoSalida, "Entero %d: %s\n", i, tabla_literales_enteros.enteros[i].dato);
    }
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
