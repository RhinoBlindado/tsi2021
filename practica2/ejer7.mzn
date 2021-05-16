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
 * [EJERCICIO 7] - Construir un avión
 */

% Se declaran unas variables para sumar los tiempos.
int: startTime = 1;
var int: totalTime;

% Por legibilidad, se prefirió utilizar enumerados para resolver el problema.
enum tasks = {A, B, C, D, E, F, G, H, I, J, K, L};

/*
 * - Para representar los tiempos necesarios para realizar cada tarea, se creó un array de 
 *   tasks, para cada tarea, se tiene que tanto tiempo consume.
 *
 * - Se mantiene también otro array con el tiempo de inicio, que también puede interpretarse como
 *   el tiempo que se acumula hasta que comienzan la tarea.
 *
 *                              Indice=    1   2   3  4  5  6  7  8  9  10 11 12
 *                              Tarea=      A   B   C  D  E  F  G  H  I  J  K  L
 */
array[tasks] of var int: timeToComplete = [60, 10, 5, 5, 5, 2, 7, 3, 7, 2, 5, 1];
array[tasks] of var int: accumTime;

% Se representan las restricciones de inicio de cada una de las tareas.
% Tarea A no depende de nadie.
constraint accumTime[A] = startTime;

% Tarea B depende de A
constraint accumTime[B] = accumTime[A] + timeToComplete[A];

% Tarea C depende de B
constraint accumTime[C] = accumTime[B] + timeToComplete[B];

% Tarea D depende de C
constraint accumTime[D] = accumTime[C] + timeToComplete[C];

% Tarea E depende de D
constraint accumTime[E] = accumTime[D] + timeToComplete[D];

% Tarea F depende de D
constraint accumTime[F] = accumTime[D] + timeToComplete[D];

% Tarea G depende de E y D
constraint accumTime[G] = max(accumTime[E] + timeToComplete[E], accumTime[D] + timeToComplete[D]);

% Tarea H depende de C
constraint accumTime[H] = accumTime[C] + timeToComplete[C];

% Tarea I depende de E y F
constraint accumTime[I] = max(accumTime[E] + timeToComplete[E], accumTime[F] + timeToComplete[F]);

% Tarea J depende de E y F
constraint accumTime[J] = max(accumTime[E] + timeToComplete[E], accumTime[F] + timeToComplete[F]);

% Tarea K depende de I y J
constraint accumTime[K] = max(accumTime[I] + timeToComplete[I], accumTime[J] + timeToComplete[J]);

% Tarea L de K
constraint accumTime[L] = accumTime[K] + timeToComplete[K];

% Se obtiene el tiempo que toma realizar todos los trabajos, igualado a 'totalTime'
constraint forall(i in tasks)(accumTime[i] + timeToComplete[i] <= totalTime);

% Se minimiza...
solve minimize totalTime;

% ... y se imprime el resultado.
output["TIEMPO MÍNIMO = \(totalTime)\n"];
output["Tarea '\(tasks[i])' empieza en tiempo \(accumTime[i]) \n"| i in tasks];