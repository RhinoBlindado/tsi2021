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
 * [EJERCICIO 6] - Asignación de Horarios 2
 */

include "globals.mzn";

/* - Para representar los diferentes elementos se realizaron sets para hacer más cómoda la resolución del ejercicio.
 *
 *   - time es para el horario de la siguiente manera:
 *   1              2              3              4
 *   09:00 - 10:00  10:00 - 11:00  12:00 - 13:00  13:00 - 14:00
 *     - Se ignora la hora de 11:00 - 12:00 ya que al ser no lectiva, no tendría mucho sentido añadirla para luego restringirla totalmente, en todo caso
 *       se añade overhead al solver ya que estaría realizando comprobaciones adicionales para algo que se sabe es certero, que allí no pueden haber clases.
 *
 *   - day representa los días:
 *   1       2        3         4      5 
 *   Lunes   Martes   Miércoles Jueves Viernes
 *
 *   - professor, los profesores:
 *   1           2            3            4
 *   Profesor 1  Profesor 2   Profesor 3   Profesor 4
 *
 *   - course para las asignaturas, cada asignatura con su grupo.
 */

set of int: time = 1..5;
set of int: day = 1..5;
set of int: professor = 1..4;
set of int: course = 1..16;

/*
 * - El array courses almacena para la asignatura-bloque i, el profesor que la imparte.
 * 
 *                       i=            1    2    3    4    5    6    7    8    9    10   11   12   13   14   15   16  
 *                       Asignatura=   A1-1 A1-2 A2-1 A2-2 A3-1 A3-2 A4-1 A4-2 A5-1 A5-2 A6-1 A6-2 A7-1 A7-2 A8-1 A9-1
 *                       Profesor=     1    1    4    4    1    1    2    2    2    2    3    3    4    4    4    3
 *  
 * - El array 'weeklyHours' almacenar para cada bloque de asignatura las horas semanales que se imparten.
 */

array[course] of professor: courses = [1,   1,   4,   4,   1,   1,   2,   2,   2,   2,   3,   3,   4,   4,   4,    3];
array[course] of 1..2: weeklyHours  = [2,   2,   1,   1,   2,   2,   2,   2,   2,   2,   1,   1,   1,   1,   2,    1];

array[time, day] of var course: scheduleTable;

/* 
 * Para restringir que las asignaturas aparezcan las veces que deben, es decir, que se respeten las horas semanales que se tienen asignadas, 
 * se cuenta en toda la matriz 'scheduleTable' las veces que la asignatura i aparece, esto se restringe con el predicado 'count' a las horas
 * semanales que poseen, dentro del array 'weeklyHours'.
 */
constraint forall(i in course)(count(scheduleTable, i, weeklyHours[i]));  

/*
 * El orden de cada bloque es importante, en el sentido de que el primer bloque de cada asignatura se posiciona en un día anterior que el segundo bloque.
 * Para cumplir esto, se indica que para el bloque 1 de una asignatura de más de un bloque, el bloque 2 solo puede aparecer luego en los días, es decir, que
 * l sea mayor que j, ambos siendo los días de la semana. Aquí solo se tienen en cuenta las asignaturas que se imparten en más de un bloque.
 */
constraint forall(i in time, j in day, k in time, l in day, m in {1, 3, 5, 7, 9, 11, 13})
           (
             if( (scheduleTable[i,j] == m /\ scheduleTable[k,l] == m+1) ) then
                j < l
             endif
           );


% El Profesor 1 solo puede dar clase en las dos últimas horas de la mañana.
constraint forall(i in time, j in day)
           (
             if(courses[ scheduleTable[i,j] ] == 1) then
                 i = 4 \/ i = 5
             endif
           );

% El Profesor 2 solo puede dar clase en las dos primeras horas de la mañana.
constraint forall(i in time, j in day)
           (
             if(courses[ scheduleTable[i,j] ] == 2) then
                 i = 1 \/ i = 2
             endif
           );

% El Profesor 3 solo puede dar clase en la hora justo antes del recreo.
constraint forall(i in time, j in day)
           (
             if(courses[ scheduleTable[i,j] ] == 3) then
                 i = 3
             endif
           );


% Asignatura 1 y Asignatura 4: lunes o martes
constraint forall(i in time, j in day)
           (
             if(scheduleTable[i,j] == 1 \/ scheduleTable[i,j] == 2 \/ scheduleTable[i,j] == 7 \/ scheduleTable[i,j] == 8) then
                j = 1 \/ j = 2
             endif
           );

% Asignatura 3: miércoles o jueves
constraint forall(i in time, j in day)
           (
             if(scheduleTable[i,j] == 5 \/ scheduleTable[i,j] == 6) then
                j = 3 \/ j = 4
             endif
           );

% Asignatura 5: jueves o viernes
constraint forall(i in time, j in day)
           (
             if(scheduleTable[i,j] == 9 \/ scheduleTable[i,j] == 10) then
                j = 4 \/ j = 5
             endif
           );

% Asignatura 6: miércoles o viernes
constraint forall(i in time, j in day)
           (
             if(scheduleTable[i,j] == 11 \/ scheduleTable[i,j] == 12) then
                j = 3 \/ j = 5
             endif
           );

% Asignatura 7: martes o viernes
constraint forall(i in time, j in day)
           (
             if(scheduleTable[i,j] == 13 \/ scheduleTable[i,j] == 14) then
                j = 2 \/ j = 5
             endif
           );

% Asignatura 8: miércoles
constraint forall(i in time, j in day)
           (
             if(scheduleTable[i,j] == 15) then
                j = 3
             endif
           );

% Asignatura 9: lunes
constraint forall(i in time, j in day)
           (
             if(scheduleTable[i,j] == 16) then
                j = 1
             endif
           );

/*
 * - Las restricciones horarias ya también engloban las restricciones de que no puedan impartir más de un
 *   bloque de una asignatura en un día.
 *
 * - El número de horas semanales de las asignaturas, las horas de los profesores y las restricciones diarias ya logran
 *   cubrir la restricción de que cada día se debe impartir como máximo un bloque.
 */

% Satisfacer estas restricciones
solve satisfy;

% Se crean variables textuales para la salida.
array[time] of string: timeName = ["08:00 - 09:00", "09:00 - 10:00", "10:00 - 11:00", "12:00 - 13:00", "13:00 - 14:00"];
array[course] of string: courseName = ["A1-BLOQ1-PROF1", "A1-BLOQ2-PROF1", "A2-BLOQ1-PROF4", "A2-BLOQ2-PROF4", "A3-BLOQ1-PROF1", "A3-BLOQ2-PROF2", "A4-BLOQ1-PROF2", "A4-BLOQ2-PROF2", "A5-BLOQ1-PROF2", "A5-BLOQ2-PROF2", "A6-BLOQ1-PROF3", "A6-BLOQ2-PROF3", "A7-BLOQ1-PROF4", "A7-BLOQ2-PROF4", "A8-BLOQ1-PROF4", "A9-BLOQ1-PROF3"];


output ["                   LUNES             MARTES            MIÉRCOLES         JUEVES            VIERNES\n"];
output [if i == 3 then
        ("\(timeName[i]) -> \(courseName[fix(scheduleTable[i,1])])  \(courseName[fix(scheduleTable[i,2])])  \(courseName[fix(scheduleTable[i,3])])  \(courseName[fix(scheduleTable[i,4])])  \(courseName[fix(scheduleTable[i,5])])\n'11:00 - 12:00' -> N/A               N/A               N/A               N/A               N/A\n") 
        else 
        ("\(timeName[i]) -> \(courseName[fix(scheduleTable[i,1])])  \(courseName[fix(scheduleTable[i,2])])  \(courseName[fix(scheduleTable[i,3])])  \(courseName[fix(scheduleTable[i,4])])  \(courseName[fix(scheduleTable[i,5])])\n")
        endif  | i in time];