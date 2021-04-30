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
 * [EJERCICIO 1] - Puzzle Cripto-aritmético
 */

% Se incluye esta librería para las restricciones globales.
include "globals.mzn";

/*
 * - Para facilitar la representación del problema se decidió que cada letra del puzzle cripto-aritmético sea una 
 * posición en un vector de enteros de la siguiente forma:
 * 
 * i           0  1  2  3  4  5  6  7  8
 * valor[i] =  E  I  N  S  T  V  W  X  Y
 *
 * - Para que la suma funcione correctamente también se creó otro vector de enteros
 * para el acarreo, se hizo un vector para que fuera más compacto el código.
 */

array[0..8] of var 0..9: numArr;
array[0..4] of var 0..9: carry;

% Se indica que los números del vector deben ser todos diferentes, notar que no se aplica al acarreo.
constraint all_different(numArr);


% Las restricciones siguientes son la representación de la suma que se pide añadiendo también el acarreo para que las operaciones se realicen correctamente.
% Y = N + N + X
constraint numArr[8] + (carry[0]*10) == 2*numArr[2] + numArr[7];

% T = E + E + I
constraint numArr[4] + (carry[1]*10) == 2*numArr[0] + numArr[1] + carry[0];

% N = V + V + S
constraint numArr[2] + (carry[2]*10) == 2*numArr[5] + numArr[3] + carry[1];

% E = E + E
constraint numArr[0] + (carry[3]*10) = 2*numArr[0] + carry[2];

% W = S + S
constraint numArr[6] + (carry[4]*10) = 2*numArr[3] + carry[3];

% T
constraint numArr[4] == carry[4];

% Se resuelve para satisfacer lo que se pide.
solve satisfy;

% Se formatea la salida como "una suma perfectamente alineada":

output ["      \(numArr[3]) \(numArr[1]) \(numArr[7])\n"];
output ["+ \(numArr[3]) \(numArr[0]) \(numArr[5]) \(numArr[0]) \(numArr[2])\n"];
output ["+ \(numArr[3]) \(numArr[0]) \(numArr[5]) \(numArr[0]) \(numArr[2])\n"];
output ["===========\n"];
output ["\(numArr[4]) \(numArr[6]) \(numArr[0]) \(numArr[2]) \(numArr[4]) \(numArr[8])"];