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
 * [EJERCICIO 4] - ¿Qué día es?
 */

/*
 * - Para facilitar la legibilitad, se prefirió utilizar enumerados en este ejercicio,
 *   se declaran tanto las personas como los días en sus tipos respectivos, además de
 *   varias variables auxiliares
 */
enum days   = {lunes, martes, miercoles, jueves, viernes, sabado, domingo};
enum people = {juan, maria, carmen, francisco, marta, olga, pepe};

%  Para mantener quien dice la verdad, se mantiene un vector de booleanos con las personas.
array[people] of var bool: whoIsRight;


% Para conectar los días, se declaran estas variables enumeradas ...
var days: today;
var days: tomorrow;
var days: yesterday;

var people: who;

% ... y se conectan los días de manera lógica

constraint tomorrow  = today mod 7 + 1;
constraint yesterday = today mod 7 - 1;

%  Juan: "Hoy es martes"
constraint whoIsRight[juan] = (today == martes);

%  María: "Eso no es correcto, mañana es martes".
constraint whoIsRight[maria] = (tomorrow == martes);

%  Carmen: "Ambos estáis equivocados. Ayer fue martes".
constraint whoIsRight[carmen] = (yesterday == martes) /\ (today != martes) /\ (tomorrow != martes);

%  Francisco: "No Carmen, ayer fue sábado".
constraint whoIsRight[francisco] = (yesterday == sabado) /\ (yesterday != martes);

%  Marta: "Hoy es o jueves o viernes"
constraint whoIsRight[marta] = (today == jueves \/ today == viernes);

%  Olga: "No es así, hoy es domingo".
constraint whoIsRight[olga] = (today == domingo) /\ (today != jueves /\ today != viernes);

%  Pepe: "No, hoy no es domingo".
constraint whoIsRight[pepe] = (today != domingo);

%  Solo una de las afirmaciones anteriores es correcta...
constraint (sum(i in people)(bool2int(whoIsRight[i]))) = 1;

%  Se obtiene quién la dijo...
constraint forall(i in people)(if whoIsRight[i] == true then who = i endif);

solve satisfy;
% ... y se imprime
output ["Hoy: \(today)\nEmisor: \(who)"];