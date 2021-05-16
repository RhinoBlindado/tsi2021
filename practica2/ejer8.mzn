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
 * [EJERCICIO 8] - Construir una casa
 */

include "cumulative.mzn";

/*
 * - Para representar los tiempos necesarios para realizar cada tarea, se creó un array de 
 *   tasks, para cada tarea, se tiene que tanto tiempo consume.
 *
 * - Se mantiene también otro array con el tiempo de inicio, que también puede interpretarse como
 *   el tiempo que se acumula hasta que comienzan la tarea.
 */
enum task = {A, B, C, D, E, F, G, H, I};

% Se definen unas variables para utilizar la función 'cumulative'
int: maxWorkers = 3;
int: maxTime = 30;
var int: endTime;

set of int: workerRange = 1..maxWorkers;
set of int: timeRange   = 1..maxTime;
/*  - Para mantener el tiempo que tarda cada tarea en completarse
 *    y cuántos trabajadores necesita, se crean dos arrays para ello.
 *
 *                           Indice=    1  2  3  4  5  6  7  8  9
 *                           Tarea=     A  B  C  D  E  F  G  H  I
 */
array[task] of int: timeToComplete =    [7, 3, 1, 8, 2, 1, 1, 3, 2];
array[task] of int: workersToComplete = [2, 3, 2, 2, 1, 2, 1, 1, 2];
array[task] of var 0..maxTime: timeToStart;

% Se restringen los tiempos de inicio de cada una de las tareas como se ha explicado.
% Tarea A no depende de ninguna otra.
constraint timeToStart[A] = 1;

% Tarea B depende de A, lo que se entiende como el tiempo de inicio de B puede ser a lo sumo igual o mayot que el tiempo para completar A + el tiempo de inicio de A, ídem para el resto de las tareas y sus dependencias.
constraint timeToStart[B] >= timeToComplete[A] + timeToStart[A];

% Tarea C depende de B
constraint timeToStart[C] >= timeToComplete[B] + timeToStart[B];

% Tarea D depende de A
constraint timeToStart[D] >= timeToComplete[A] + timeToStart[A];

% Tarea E depende de C y D
constraint timeToStart[E] >= max( timeToComplete[C] + timeToStart[C], timeToComplete[D] + timeToStart[D]);

% Tarea F depende de C y D
constraint timeToStart[F] >= max( timeToComplete[C] + timeToStart[C], timeToComplete[D] + timeToStart[D]);

% Tarea G depende de C y D
constraint timeToStart[G] >= max( timeToComplete[C] + timeToStart[C], timeToComplete[D] + timeToStart[D]);

% Tarea H depende de A
constraint timeToStart[H] >= timeToComplete[A] + timeToStart[A];

% Tarea I depende F y H
constraint timeToStart[I] >= max( timeToComplete[F] + timeToStart[F], timeToComplete[H] + timeToStart[H]);

% La función 'cumulative' se encarga de obtener los tiempos más cortos para realizar las tareas dados los trabajadores disponibles
constraint cumulative(timeToStart, timeToComplete, workersToComplete, maxWorkers);

% Se iguala la suma entera al tiempo final para minimizarlo.
constraint forall(i in task)(timeToStart[i] + timeToComplete[i] <= endTime);

% Se minimza para el menor tiempo posible.
solve minimize endTime;


output["TIEMPO MÍNIMO = \(endTime)\n******\n"];
output["Tarea '\(task[i])' empieza en tiempo \(timeToStart[i]) \n"| i in task];
output["******"];