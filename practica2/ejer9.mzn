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
 * [EJERCICIO 9] - Diagnosticar un paciente
 */

/*
 * Para representar los pacientes, tomando en cuenta que los predicados para calucar
 * distancias toman arrays se hizo un array 2D de pacientes y sus síntomas.
 */
set of int: numPac = 1..20;
set of int: symptoms = 1..4;
%                                                         Paciente:
array[numPac, symptoms] of 0..1: dataBase   = [|0,0,1,1 % 1
                                               |1,1,1,0 % 2
                                               |1,1,0,1 % 3
                                               |1,0,0,1 % 4
                                               |1,1,0,1 % 5
                                               |0,1,1,1 % 6
                                               |1,0,0,0 % 7
                                               |1,1,0,0 % 8
                                               |0,1,0,0 % 9
                                               |0,0,1,1 % 10
                                               |1,0,0,1 % 11
                                               |1,0,0,1 % 12
                                               |0,1,1,0 % 13
                                               |1,1,0,0 % 14
                                               |1,0,1,0 % 15
                                               |1,0,0,0 % 16
                                               |1,0,0,1 % 17
                                               |0,1,1,0 % 18
                                               |0,0,1,0 % 19
                                               |1,0,1,0 % 20
                                               |];

% Ahora se realiza la otra parte de la base de datos, para cada paciente, el diagnóstico que posee.
array[numPac] of string: diagnosis = ["COVID", "COVID", "COVID", "COVID", "COVID", "COVID", "COVID", "COVID", "COVID", "COVID", "Gripe", "Gripe", "Gripe" , "Gripe", "Gripe", "Gripe", "Alergias", "Alergias", "Alergias", "Alergias"];

% Se declara el array del nuevo paciente y el valor que indicará su diagnosis.
array[symptoms] of 0..1: pacientX = [0, 1, 1, 1];
var int: actDiagnosis;

% Se tiene el array que almacenará la distancia del paciente nuevo a los pacientes en la base de datos, ya que el predicado toma un array y un int.
array[numPac] of var int: distToPatients;
% Variable dónde se almacenará el índice del paciente más cercano.
var int: minDist;

%    Declarando los predicados:
%    - Calcular la distancia entre dos pacientes.
predicate distancia(array[int] of int: a, array[int] of var int: v, var int : d) = d = sum(i in index_set(a)) ( (a[i]-v[i])*(a[i]-v[i]))  /\ d >= 0;

%    - Recuperar el índice del menor valor de un array (i.e. argmin)
predicate indice_minimo(var int: mi, array[int] of var int: x) = exists(i in index_set(x)) (x[i] = min(x) /\ mi = i ) ;

%    Utilizando los predicados en restricciones:
%    - Se hace un bucle por la base de datos, comparando el nuevo paciente con cada paciente de la BD y almacenando su distancia en 'distToPatients'
constraint forall(i in numPac)
           (       
               (distancia(dataBase[i,..], pacientX, distToPatients[i]))
           );

%    - De este vector se obtendrá minDist, la distancia más corta a un paciente y el paciente nuevo. En la salida se imprime el diagnóstico que obtuvo este paciente para la posible diagnosis del nuevo paciente.
constraint indice_minimo(minDist, distToPatients);

solve satisfy;

% Se imprime la salida como se pide.
output ["Paciente  Distancia con Paciente Nuevo\n"];
output ["\(i)\t | \(distToPatients[i]) \n" | i in numPac];
output ["\nMayor semejanza con paciente número \(minDist), diagnóstico probable de \(diagnosis[fix(minDist)])"];