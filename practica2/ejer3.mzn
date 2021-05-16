/*
 * [CASTELLANO]
 * Practica 2: Satisfaccion de Restricciones
 * Asignatura: Tecnicas de Sistemas Inteligentes
 * Autor: Valentino Lugli (Github: @RhinoBlindado)
 * Fecha: Abril, Mayo 2021
 */

/*
 * [ENGLISH]
 * Practice 2: Constraint Satisfaction Problems
 * Course: Intelligent Systems Techniques
 * Author: Valentino Lugli (Github: @RhinoBlindado)
 * Date: April, May 2021
 */

/*
 * [EJERCICIO 3] - Colorear Sudamérica
 */

/* - Se crea un vector de los países, cada país corresponde con su número en ordenación alfabética.
 *   Es decir: Argentina = 1, Bolivia = 2, ..., Venezuela = 13.
 *
 * - Para asignarle un color se indica que cada ítem del vector solo puede tener valores enteros entre 1 y 5 para el coste de la pintura.
 *
 * - Se crea la variable paintCost para minimizar en ella el coste.
 */
array[1..13] of var 1..5: country;
var int : paintCost;

/* - Se restringe el color que puede tener cada país sea distinto con los paises con los que tiene fronteras.
 *
 * - Las restricciones son conmutativas, por lo que no se tiene que colocar cada país si ya todos los paises con los que
 *   tiene frontera han sido ya escritos.
 */

% Argentina
constraint country[1] != country[2] /\
           country[1] != country[3] /\
           country[1] != country[4] /\
           country[1] != country[9] /\
           country[1] != country[12];

% Bolivia
constraint country[2] != country[3] /\
           country[2] != country[4] /\
           country[2] != country[9] /\
           country[2] != country[10];

% Brasil
constraint country[3] != country[5] /\
           country[3] != country[7] /\
           country[3] != country[8] /\
           country[3] != country[9] /\
           country[3] != country[10] /\
           country[3] != country[11] /\
           country[3] != country[12] /\
           country[3] != country[13];

% Chile
constraint country[4] != country[10];

% Colombia
constraint country[5] != country[6] /\
           country[5] != country[10] /\
           country[5] != country[13];
           
% Ecuador
constraint country[6] != country[10];

% Guayana Francesa
constraint country[7] != country[11];

% Guyana
constraint country[8] != country[11] /\
           country[8] != country[13];
           
% Paraguay
constraint country[9] != country[12];

% El resto de los países se encuentran ya restringidos en los bloques anteriores, no hace falta volverlos a escribir.

% Para minimizar el costo, se iguala la variable a la suma de cada valor del vector de paises multiplicado por 100 para dar el valor real que se pide del costo de la pintura.
constraint paintCost == sum(i in 1..13)(country[i]*100);

% Se minimiza ese costo.
solve minimize paintCost;

% Para que la salida quede más legible, se declaran estos vectores de cadenas que tienen los nombres textuales de los colores y los países.
array[1..5] of string: colorName = ["Verde   ", "Naranja ", "Rojo    ", "Azul    ", "Amarillo"];
array[1..13] of string: countryName = ["Argentina        ", "Bolivia          ", "Brazil           ", "Chile            ", "Colombia         ", "Ecuador          ", "Guayana Francesa ", "Guyana           ", "Paraguay         ", "Perú             ", "Surinam          ", "Uruguay          ", "Venezuela        "];

% Se imprime la salida acordemente.
output["Costo total: \(paintCost)€\n\n"];
output["\(countryName[i])| \(colorName[fix(country[i])]) | \(country[i]*100)€ \n" | i in 1..13];