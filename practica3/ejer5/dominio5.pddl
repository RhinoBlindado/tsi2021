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

; Ejercicio 5, Dominio

(define (domain terran5)
    (:requirements :adl)
    (:types
        localizable map resource research - object
        unit building - localizable
    )
    (:constants
        VCE marine segador - uType
        centro-de-mando barrancon extractor bahia-de-ingenieria - bType
        mineral gas - resource
    )
    (:predicates
        ; Atributos
        
        ; - Tipo de unidad.
        (unitType ?unit - unit ?type - uType)
        ; - Tipo de edificio.
        (buildingType ?building - building ?type - bType)

        ; Predicados

        ;   + Predicados del mapa
        ;       - Indica que un objeto localizable está en un lugar del mapa.
        (in ?obj - localizable ?coord - map)
        ;       - Indica que dos puntos del mapa están conectados y se puede transitar por ellos.
        (connected ?x ?y - map)

        ;   + Predicados de Recursos
        ;       - Localización en el mapa de un nodo de recursos.
        (resourceNode ?coord - map ?resource - resource)
        ;       - Indica que una unidad está extrayendo un recurso.
        (isExtracting ?unit - unit ?resource - resource)
        ;       - Indica que un recurso está siendo extraido.
        (beingExtracted ?resource - resource)


        ;   + Predicados de Edificios
        ;       - Indica que un edificio está construido.
        (built ?building - building)
        ;       - Indica que recurso necesita una clase de edificio para construirse.
        (toBuildNeeds ?buildType - bType ?resource - resource)


        ;   + Predicados de Unidades
        ;       - Indica que una unidad está en uso.
        (unitInUse ?unit - unit)
        ;       - Indica que recurso necesita una clase de unidad para reclutarse.
        (toHireNeeds ?unitType - uType ?resource - resource)
        ;       - Indica que una unidad ha sido ya reclutada.
        (isHired ?unit - unit)
        ;       - Indica que en un cierto edificio se recluta una unidad particular.
        (hiredIn ?unitType - uType ?buildingType - bType)
        ;       - Indica que necesita una investigación para poderse recludar.
        (needsResearch ?unitType - uType ?research - research)

        ;   + Predicados de Investigaciones
        ;       - Indica que una investigación necesita recursos
        (toResearchNeeds ?research - research ?resourse - resource)
        ;       - Indica que una investigación ya ha sido investigada
        (isResearched ?research - research)
    )


    (:action navegar
        ; Si la unidad está en un sitio del mapa y este sitio está conectado con los otros, puede moverse hacia ellos.
        :parameters (?unit - unit ?x ?y - map)
        :precondition 
        (and 
            (connected ?x ?y)
            (in ?unit ?x)

        )
        :effect 
        (and 
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

            ; La unidad está libre.
            (not (unitInUse ?unit))

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
            (beingExtracted  ?resourceType) 
            ; La unidad está en uso.
            (unitInUse ?unit)
        )
    )

    (:action construir
        :parameters (?unit - unit ?building - building ?x - map)
        :precondition 
        (and 
            ; La unidad es un VCE.
            (unitType ?unit VCE)
            ; La unidad está en el sitio indicado.
            (in ?unit ?x)
            ; La unidad está libre.
            (not (unitInUse ?unit))
            ; No existe algún otro edificio que esté en este mismo sitio.
            (not(exists(?b - building) 
                    (in ?b ?x)
                )
            )
            ; El edificio no ha sido construido
            (not (built ?building))

            ; Se están extrayendo los recursos que necesita el edificio, es decir:
            ; Existe un tipo de edicio...
            (exists (?bt - bType)
                (and
                    ; ... que es del tipo que quiero construir ...
                    (buildingType ?building ?bt)
                    ; ... y para todos los recursos...
                    (forall (?r - resource)
                        ; ... que necesita este tipo de edificio en particular ...
                        (imply (toBuildNeeds ?bt ?r)
                            ; ... verificar que se están extrayendo.
                            (beingExtracted ?r)
                        )
                    )
                )
            )
        )
        :effect 
        (and 
            ; Se indica tanto en el mapa como en el predicado, que está construido ya ese edificio.
            (built ?building)
            (in ?building ?x)
        )
    )

    (:action reclutar
        :parameters (?building - building ?unit - unit ?x - map)
        :precondition 
        (and 
            ; Se está en un edificio.
            (in ?building ?x)

            ; Para la unidad de un cierto tipo...
            (exists (?ut - uType) 
                (and
                    ; ... que es de la unidad que se desea...
                    (unitType ?unit ?ut)
                    ; ... y para todos los recursos ...
                    (forall (?r - resource) 
                        ; ... que necesita dicha unidad ...
                        (imply (toHireNeeds ?ut ?r)
                            ; ... ya se están extrayendo, ...
                            (beingExtracted ?r)
                        )
                    )
                    ; ... y el edificio actual ...
                    (exists (?bt - bType) 
                        (and
                            ; ... es el edificio en el que se recluta ese tipo de unidad.
                            (buildingType ?building ?bt)
                            (hiredIn ?ut ?bt)
                        )
                    )
                    
                    ; Si la unidad es un segador, se necesita la investigación "Impulsar Segador"
                    (imply (= ?ut segador) (isResearched impulsar-segador))          
                )
            )
        )
        :effect 
        (and 
            ; La unidad se recluta y aparece en la localización del edificio.
            (in ?unit ?x)
            (isHired ?unit)
        )
    )

    (:action investigar
        :parameters (?building - building ?research - research)
        :precondition 
        (and 
    
            ; El edificio está construido.
            (built ?building)
            ; El edificio es la bahía de ingeniería.
            (buildingType ?building bahia-de-ingenieria)

            
            ; Se tienen disponibles todos los recursos que la investigación necesita.
            (forall(?r - resource)
                (imply (toResearchNeeds ?research ?r)
                    (beingExtracted ?r)
                )
            )
        )
        :effect 
        (and 
            ; La investigación se ha completado.
            (isResearched ?research)
        )
    )
    
    
    
)