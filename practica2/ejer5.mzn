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
 * [EJERCICIO 5] - Asignación de Horarios
 */

include "globals.mzn";

/* - Para representar los diferentes elementos se realizaron sets para hacer más cómoda la resolución del ejercicio.
 *
 *   - time es para el horario de la siguiente manera:
 *   1              2              3              4
 *   09:00 - 10:00  10:00 - 11:00  11:00 - 12:00  12:00 - 13:00
 *
 *   - classroom representa las aulas:
 *   1       2        3
 *   Aula 1  Aula 2   Aula 3
 *
 *   - professor, los profesores:
 *   1           2            3            4
 *   Profesor 1  Profesor 2   Profesor 3   Profesor 4
 *
 *   - course para las asignaturas, cada asignatura con su grupo.
 */

set of int: time = 1..4;
set of int: classroom = 1..3;
set of int: professor = 1..4;
set of int: course = 1..12;


/*
 *   El array courses almacena para la asignatura i, el profesor que la imparte.
 * 
 *   i=            1      2      3      4      5       6       7       8       9       10      11      12
 *   Asignatura=   IA-G1  IA-G2  IA-G3  IA-G4  TSI-G1  TSI-G2  TSI-G3  TSI-G4  FBD-G1  FBD-G2  FBD-G3  FBD-G4
 *   Profesor=     1      2      3      4      3       3       4       3       1       1       1       2
 */
array[course] of professor: courses = [1, 2, 3, 4, 3, 3, 4, 3, 1, 1, 1, 2];

% El array scheduleTable es el horario propiamente, es de variable course y allí es dónde se representa que profesor da que asignatura en qué horario y en que aula.
array[time, classroom] of var course: scheduleTable;

% Cada elemento solo debe aprecer una vez ya que cada clase se da una sola hora semanal.
constraint alldifferent(scheduleTable);

/*
 * Cada aula solo puede estar ocupada por un único profesor/a al mismo tiempo, eso es que el valor que tenga scheduleTable, si se accede a courses no sea el mismo, 
 * ya que eso implicaría que el mismo profesor está dando dos clases al mismo tiempo en el mismo bloque horario.
 */
constraint forall(i in time)
           (
              courses[ scheduleTable[i,1] ] != courses[ scheduleTable[i,2] ] /\
              courses[ scheduleTable[i,2] ] != courses[ scheduleTable[i,3] ] /\
              courses[ scheduleTable[i,1] ] != courses[ scheduleTable[i,3] ]
            );

/* 
 * Cada grupo recibe docencia de una única asignatura en cada momento, esto se puede restringir haciendo que el modulo entre 4, ya que son 4 grupos, sea diferente,
 * esto se realiza así tomando la ventaja de que un grupo está espaciado de la misma manera en el vector courses, de 4 en 4, si se toma el modulo 
 * de dos asignaturas y es igual es que son el mismo grupo, por lo tanto se pide que sean diferentes.
 */
constraint forall(i in time)
           (
              scheduleTable[i,1] mod 4 != scheduleTable[i,2] mod 4 /\ 
              scheduleTable[i,2] mod 4 != scheduleTable[i,3] mod 4 /\ 
              scheduleTable[i,1] mod 4 != scheduleTable[i,3] mod 4
           );

% El profesor 2 solo puede dar clase en el aula 2 y solo está disponible de 09:00 a 10:00 y de 10:00 a 11:00
constraint forall(i in time, j in classroom)
           (
              if (courses[ scheduleTable[i,j] ] == 2) then 
                 j = 2 /\ (i = 1 \/ i = 2) 
              endif
           );


% El profesor 4 solo puede dar clase en el aula 3
constraint forall(i in time, j in classroom)
           (
              if (courses[ scheduleTable[i,j] ] == 4) then 
                 j = 3 
              endif
           );

/* 
 * La asignatura de TSI solo se puede dar en el aula 2 o 3, como en el vector TSI está entre 5 y 8, se pide que esos valores estén en
 * j = 2 o j = 3 que es decir estén en el aula 2 o 3.
 */
constraint forall(i in time, j in classroom, k in 5..8)
           (
              if ( scheduleTable[i,j] == k) then 
                 j = 2 \/ j = 3 
              endif
           );

% El grupo IA-G1 debe dar clase de 09:00 a 10:00.
constraint forall(i in time, j in classroom)
           (
              if( scheduleTable[i,j] == 1) then
                i = 1
              endif
           );

% El grupo IA-G3 debe dar clase de 11:00 a 12:00 en la Aula 1 obligatoriamente.
constraint scheduleTable[3,1] = 3;

% Satisfacer estas restricciones.
solve satisfy;

% Se crean unas variables textuales para la salida del programa.
array[time] of string: timeName = ["09:00 - 10:00", "10:00 - 11:00", "11:00 - 12:00", "12:00 - 13:00"];

array[course] of string: courseName = ["IA-G1  (P1)", "IA-G2  (P2)", "IA-G3  (P3)", "IA-G4  (P4)", "TSI-G1 (P3)", "TSI-G2 (P3)", "TSI-G3 (P4)", "TSI-G4 (P3)", "FBD-G1 (P1)", "FBD-G2 (P1)", "FBD-G3 (P1)", "FBD-G4 (P2)"];

output["                     AULA 1         AULA 2         AULA 3\n"];
output["\(timeName[i]) ->  \(courseName[ fix(scheduleTable[i,1])])  \(courseName[ fix(scheduleTable[i,2])])  \(courseName[ fix(scheduleTable[i,3])])\n" | i in time];