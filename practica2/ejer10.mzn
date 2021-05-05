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
 * [EJERCICIO 10] - El Problema de la Mochila
 */

/*
 * - maxWeight: Para este problema se declara primero el peso máximo que se permite, en este caso son 5 kilos.
 * 
 * - actualWeight: Se crea la variable con el peso actual de la mochila para poder imprimirlo por pantalla.
 *  
 * - maxPref: Variable con la cual se maximizará la preferencia de los objetos.
 *
 * - Para los vectores se ha seguido el siguiente esquema con los objetos:
 * 
 *   i          1     2         3           4    5        6       7      8                       9        10
 *   objeto[i]  Mapa  Cuchillo  Prismáticos Agua Linterna Cerveza Novela Manual de Supervivencia Plátanos Caramelos
 * 
 * - itemWeight mantiene el peso de cada objeto en el vector.
 * - itemPreference mantiene el valor de las preferencias de cada objeto en el vector.
 * - itemSelection es un vector de ceros y unos de la misma longitud que indica si ese objeto se mete en la mochila (1) o si no se mete (0).
 */

int : maxWeight = 5000;
var int : actualWeight;
var int : maxPref;
array[1..12] of var int: itemWeight = [50, 500, 1000, 3000, 1500, 3000, 500, 1000, 2000, 500, 250, 500];
array[1..12] of var int: itemPreference = [100, 90, 75, 95, 85, 10, 5, 70, 90, 20, 50, 40];
array[0..12] of var 0..1: itemSelection;


/*
 * - itemWeight[i]*itemSelection[i] indica que este peso podrá o bien ser el peso del item si se mete en la mochila (1) o (0) si no se mete.
 * 
 * - Se realiza la suma de todos los items junto al valor de selección y esto se igual a actualWeight
 *
 * - actualWeight se restringe para que sea menor o igual que el peso máximo establecido, maxWeight.
 *
 * - Luego, también se realiza la suma de las preferencias de los items que se han metido en la mochila y esto se iguala a maxPref.
 * 
 * - Finalmente, se indica que se maximice el valor de maxPref con las restricciones establecidas.
 */
constraint sum(i in 1..12)(itemWeight[i]*itemSelection[i]) == actualWeight;
constraint actualWeight <= maxWeight;
constraint sum(i in 1..12)(itemPreference[i]*itemSelection[i]) == maxPref;

solve maximize maxPref;

/* 
 * - Para que la salida sea como se pide, se declara un vector con los nombres textuales de los objetos y luego en la salida se indica con un 
 *   condicional que imprima por pantalla solo aquellos objetos que se han metido en la mochila, esto es que para la posición i, se tiene que
 *   itemSelection[i] = 1.
 */

array[1..12] of var string : itemName = ["Mapa", "Cuchillo", "Prismáticos", "Agua", "Linterna", "Cerveza", "Novela", "Manual de Supervivencia", "Plátanos", "Caramelos", "Cerillas", "Espejo"];

output["Objetos = "] ++ [if fix(itemSelection[i]) == 1 then "\(itemName[i]) " else "" endif | i in 1..12] ++ [" | Preferencias = \(maxPref) | PesoFinal = \(actualWeight/1000)kg"];