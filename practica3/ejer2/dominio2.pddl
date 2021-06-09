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

; Ejercicio 2, Dominio

(define (domain terran2)
    (:requirements :strips :typing)
    (:types
        localizable map resource - object
        unit building - localizable
    )
    (:constants
        VCE - uType
        centro-de-mando barrancon extractor - bType
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
        ; - Indica que recurso necesita un edificio para construirse.
        (needs ?building - building ?resource - resource)
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
            ; La unidad es un VCE.
            (unitType ?unit VCE)
            ; La unidad está en el sitio adecuado.
            (in ?unit ?resourceLocation)
            (resourceNode ?resourceLocation ?resourceType)
            (or
                ; Si se trata de Gas Vespeno, verificar si existe un extractor construido.
                (and
                    (exists (?b - building) 
                        (and
                            (buildingType ?b extractor)
                            (built ?b)
                            (in ?b ?resourceLocation)   
                        )
                    )
                    (= ?resourceType gas)
                )
                ; Si se trata de Mineral, no se realiza dicha verificación.
                (= ?resourceType mineral)
            )

        )
        :effect 
        (and 
            ; La unidad empieza a extraer el recurso.
            (isExtracting ?unit ?resourceType)
        )
    )

    (:action construir
        ; Si la localización lo permite, se puede construir un edificio siempre y cuando se esté extrayendo el recurso necesario.
        :parameters (?unit - unit ?building - building ?x - map ?resource - resource)
        :precondition 
        (and 
            ; La unidad es un VCE.
            (unitType ?unit VCE)
            ; La unidad está en el sitio indicado.
            (in ?unit ?x)
            ; La unidad está libre.
            (forall (?r - resource) 
                (not (isExtracting ?unit ?r))
            )
            ; Se está extrayendo el recurso que necesita el edificio.
            (needs ?building ?resource)
            (exists (?altUnit - unit)
                (isExtracting ?altUnit ?resource)
            )
        )
        :effect 
        (and 
            ; Se indica tanto en el mapa como en el predicado 'built' que está construido ya ese edificio.
            (built ?building)
            (in ?building ?x)
        )
    )
    
)