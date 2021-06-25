[:es: Español](#técnicas-de-los-sistemas-inteligentes) | [:gb: English](#intelligent-systems-techniques)

---
# Técnicas de los Sistemas Inteligentes #
## :books: Curso 2020-2021, Grado en Ingeniería Informática, ETSIIT UGR.
### :pushpin: Introducción
El apartado práctico de la asignatura se dividió en tres entregas que exploraban los distintos aspectos de las técnicas de Inteligencia Artificial aplicadas a la resolución de diferentes problemas: la Creación de Agentes, la Resolución de Problemas de Satisfacción de Restricciones y la Planificación de Acciones.
### :gear: Compilación
* La primera práctica fue realizada utilizando el framework GVGAI, por lo tanto es un requerimiento tenerlo descargado y cargado en un IDE, luego se debe incluir los archivos dentro de `src_lugli__valentino` y ajustar el fichero `Test.java` para que pueda cargar el Agente desarrollado.
* La segunda práctica utilizó el IDE de Minizinc para ejecutarse, por lo tanto es un requerimiento tenerlo descargado, luego se abre un archivo `.mzn` y se ejecuta.
* La tercera práctica utilizó el MetricFF, se debe ejecutar con el comando `./ff -o <dominio> -f <problema> -O -g 1 -h 1`. Se incluyó un script de Bash que automáticamente ejecuta este comando.

### :link: Contenido
#### :moyai: Práctica 1: BoulderDash
La primera práctica consistió en la realización de un Agente Reactivo-Deliberativo diseñado para jugar una versión simplificada del juego de 1984 Boulder Dash. Se realizó utilizando el framework de [GVGAI](https://github.com/GAIGResearch/GVGAI) en Java con el IDE Eclipse por facilidad. Consistió en 5 diferentes componentes a diseñar:
  * Componente Deliberativa Simple: Hacer que el Agente se moviera por el mapa hasta llegar a la salida de manera óptima con el Algoritmo A*.
  * Componente Deliberativa Compuesta: Hacer que el Agente recoga 9 gemas en el mapa y luego planifique su camino hacia la salida.
  * Componente Reactiva Simple: Esquivar un enemigo por 2000 ticks.
  * Componente Reactiva Compuesta: Esquivar dos enemigos por 2000 ticks.
  * Componente Reactiva-Deliberativa: El Agente debe recoger 9 gemas en un mapa y esquivar los enemigos para luego irse a la salida.
#### :school_satchel: Práctica 2: Satisfacción de Restricciones
La segunda práctica consistió en la realización de diez diferentes ejercicios sobre satisfacción de restricciones utilizando el lenguaje de modelado de restricciones Minizinc para ello, para más detalles leer el [guión de prácticas](https://github.com/RhinoBlindado/tsi2021/blob/main/practica2/docs/Pr%C3%A1ctica%202%20-%20Gui%C3%B3n.pdf) asociado.
#### :factory: Práctica 3: Starcraft
La tercera práctica consistió en la realización de siete ejercicios incrementales sobre la planificación de acciones en el contexto de una versión simplificada y textual de Starcraft, se utilizó el Planning Domain Definition Language (PDDL) con el planificador Fast-Foward 1.0, para más detalles leer el [guión de prácticas](https://github.com/RhinoBlindado/tsi2021/blob/main/practica3/docs/guionP3.pdf) asociado.

---
# Intelligent Systems Techniques #
## :books: 2020-2021 Course, Computer Science Engineering Degree, ETSIIT UGR.
### :pushpin: Introduction
