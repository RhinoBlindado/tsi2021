; [CASTELLANO]
; Practica 3: Planificacion Clasica con PDDL
; Asignatura: Tecnicas de Sistemas Inteligentes
; Autor: Valentino Lugli (Github: @RhinoBlindado)
; Fecha: Mayo, Junio 2021

; [ENGLISH]
; Practice 3: Classical Planning with PDDL
; Course: Intelligent Systems Techniques
; Author: Valentino Lugli (Github: @RhinoBlindado)
; Date: May, June 2021

; Ejercicio 1, Dominio

(define (domain terran1)
    (:requirements :strips :typing)
    (:types
        localizable map resource - object
        unit building - localizable
    )
    (:constants
        VCE - uType
        centro-de-mando barrancon - bType
        mineral gas - resource
    )
    (:predicates
        ; Atributos: Dadas las restricciones de las acciones, se utilizan estos predicados como atributos de los objetos.
        ; - Tipo de unidad.
        (unitType ?unit - unit ?type - uType)
        ; - Tipo de edificio.
        (buildingType ?building - building ?type - bType)

        ; Predicados
        ; - Indica que un objeto localizable está en un lugar del mapa.
        (in ?obj - localizable ?coord - map)
        ; - Indica que dos puntos del mapa están conectados y se puede transitar por ellos.
        (connected ?x ?y - map)
        ; - Indica que un edificio está construido.
        (built ?building - building)
        ; - Localización en el mapa de un nodo de recursos.
        (resourceNode ?coord - map ?resource - resource)
        ; - Indica que una unidad está extrayendo un recurso.
        (isExtracting ?unit - unit ?resource - resource)
    )
    (:action navegar
        ; Si la unidad está en un sitio del mapa y este sitio está conectado con los otros, puede moverse hacia ellos.
        :parameters (?unit - unit ?x ?y - map)
        :precondition 
        (and 
            ; Si están conectadas dos localizaciones.
            (connected ?x ?y)
            ; Y la unidad está en una de ellas.
            (in ?unit ?x)

        )
        :effect 
        (and 
            ; Puede moverse a la otra.
            (in ?unit ?y)
            (not (in ?unit ?x))
        )
    )
    (:action asignar
        ; Si una unidad VCE se encuentra en el sitio de un nodo de recursos, puede empezar a extraer dicho recurso.
        :parameters (?unit - unit ?resourceLocation - map ?resourceType - resource)
        :precondition 
        (and 
            ; Si la unidad es un VCE
            (unitType ?unit VCE)
            ; Y se encuentra en una localización
            (in ?unit ?resourceLocation)
            ; Que es la localización de un nodo de recursos.
            (resourceNode ?resourceLocation ?resourceType)
        )
        :effect 
        (and 
            ; Empezar a extraerlo.
            (isExtracting ?unit ?resourceType)
        )
    )
)