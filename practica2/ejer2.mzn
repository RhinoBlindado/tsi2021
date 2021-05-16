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
 * [EJERCICIO 2] - Monedas mínimas
 */

% Se tiene cantidad de monedas en céntimos por facilidad para realizar los cálculos y evitar comparaciones de flotantes.
int: amountInCents = 799;

% Construir in vector para llevar la cuenta de las monedas y otro para mantener los valores de las monedas en céntimos.
array[1..8] of var int: coinCounter;
array[1..8] of int: coins = [1, 2, 5, 10, 20, 50, 100, 200];

% Obtener las monedas contadas.
var int : coinCount;

% Evitar que existan valores menores a 1 en la entrada.
constraint amountInCents > 0;

% Los contadores no pueden ser negativos.
constraint forall(i in 1..8)(coinCounter[i] >= 0);

% La cantidad en céntimos es igual a cada moneda multiplicada por la cantidad que tiene.
constraint sum(i in 1..8)(coins[i]*coinCounter[i]) == amountInCents;

% La suma de las cantidades se relaciona con la variable a la que se va a minimizar.
constraint sum(i in 1..8)(coinCounter[i]) == coinCount;

% Resolver minimizando el número de monedas.
solve minimize coinCount;

output ["Monedas: ["]; output [" \(coinCounter[i]) " | i in 1..8];
output ["]\nTotal de Monedas: \(coinCount)"];