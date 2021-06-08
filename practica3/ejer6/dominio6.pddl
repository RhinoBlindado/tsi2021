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

; Ejercicio 6, Dominio

(define (domain terran6)
    (:requirements :adl)
    (:types
        localizable map resource int - object
        unit building - localizable
    )
    (:constants
        VCE marine segador - uType
        centro-de-mando barrancon extractor - bType
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
    )
    (:functions
        ; + Funciones de Recursos
        ;   - Máximo número de un recurso.
        (maxResourses ?resource - resource)
        ;   - Contador de VCEs por cada Nodo de Recurso en el mapa.
        (VCEcount ?resource - resource ?x - map)
        ;   - Contador de la cantidad actual de un recurso en general.
        (resourceCount ?resource - resource)
        ;   - Cuantos recursos necesita un edificio para constuirse.
        (toBuildNeedsNum ?buildType - bType ?resource - resource)
        ;   - Cuantos recursos necesita una unidad para reclutarse.
        (toHireNeedsNum ?unitType - uType ?resource - resource)
    )
    
    (:action navegar
        :parameters (?unit - unit ?x ?y - map)
        :precondition 
        (and 
            ; Si la unidad no está en uso.            
            (not (unitInUse ?unit))
            ; Si el mapa está conectado con otra porción del mismo.
            (connected ?x ?y)
            ; Si la unidad está en una parte del mapa.
            (in ?unit ?x)

        )
        :effect 
        (and 
            ; Puede moverse a la porción con que se conecta.
            (in ?unit ?y)
            (not (in ?unit ?x))
        )
    )

    (:action asignar
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

            ; Si se trata de Gas Vespeno, verificar si existe un extractor construido.
            (imply(= ?resourceType gas)
                (and
                    (exists (?b - building) 
                        (and
                            (buildingType ?b extractor)
                            (built ?b)
                            (in ?b ?resourceLocation)   
                        )
                    )
                    
                )
            )

        )
        :effect 
        (and 
            ; La unidad empieza a extraer el recurso.
            (isExtracting ?unit ?resourceType)
            (beingExtracted  ?resourceType)

            ; La unidad está en uso.
            (unitInUse ?unit)

            ; La unidad se cuenta al total de VCEs extrayendo ese recurso en ese nodo en particular.
            (increase (VCEcount ?resourceType ?resourceLocation) 1)
        )
    )

    (:action construir
        :parameters (?unit - unit ?building - building ?x - map)
        :precondition 
        (and 
            ; El edificio no está construido.
            (not(built ?building))
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
                            (and
                            ; ... se están extrayendo y se tienen en la cantidad necesaria.
                                (>= (resourceCount ?r) (toBuildNeedsNum ?bt ?r))
                            )
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

            ; Se reducen los recursos que utiliza el recurso para construirse.
            (when (buildingType ?building barrancon) 
                (and
                    (decrease (resourceCount mineral) (toBuildNeedsNum barrancon mineral))
                    (decrease (resourceCount gas) (toBuildNeedsNum barrancon gas))
                )
            )

            (when (buildingType ?building extractor) 
                (decrease (resourceCount mineral) (toBuildNeedsNum extractor mineral))
            )
        )
    )

    (:action reclutar
        :parameters (?building - building ?unit - unit ?x - map)
        :precondition 
        (and 
            ; Se está en un edificio.
            (in ?building ?x)
            ; La unidad no está reclutada anteriormente.
            (not (isHired ?unit))
            
            ; Para la unidad de un cierto tipo...
            (exists (?ut - uType) 
                (and
                    ; ... que es de la unidad que se desea...
                    (unitType ?unit ?ut)
                    ; ... y para todos los recursos ...
                    (forall (?r - resource) 
                        ; ... que necesita dicha unidad ...
                        (imply (toHireNeeds ?ut ?r)
                            (and
                            ; ... se están extrayendo y se tienen en la cantidad necesaria.
                                (>= (resourceCount ?r) (toHireNeedsNum ?ut ?r))
                            )
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
                )
            )
        )
        :effect 
        (and 
            ; La unidad se recluta y aparece en la localización del edificio.
            (in ?unit ?x)
            (isHired ?unit)

            ; Se reduce la cantidad de recursos dependiendo del tipo de unidad que se ha reclutado.
            (when (unitType ?unit VCE) 
                (decrease (resourceCount mineral) (toHireNeedsNum VCE mineral))
            )

            (when (unitType ?unit marine)
                (and
                    (decrease (resourceCount mineral) (toHireNeedsNum marine mineral))
                    (decrease (resourceCount gas) (toHireNeedsNum marine gas))
                )
            )

            (when (unitType ?unit segador)
                (and
                    (decrease (resourceCount mineral) (toHireNeedsNum segador mineral))
                    (decrease (resourceCount gas) (toHireNeedsNum segador gas))
                )
            )
        )
    )

    (:action recolectar
        :parameters (?resource - resource ?x - map)
        :precondition 
        (and 
            ; Se está en un nodo de recurso.
            (resourceNode ?x ?resource)
            
            ; Hay al menos un VCE que lo está extrayendo.
            (exists (?u - unit) 
                (and
                    (isExtracting ?u ?resource)
                    (in ?u ?x)
                )
            )

            ; El total actual de recursos más los que serían añadidos no supera el máximo que se puede almacenar.
            (<= (+ (resourceCount ?resource) (* 10 (VCEcount ?resource ?x))) (maxResourses ?resource))
        )
        :effect 
        (and 
            ; Se incrementa la cantidad del recurso dependiendo de cuántos VCEs están asignados al nodo.
            (increase (resourceCount ?resource) (* 10 (VCEcount ?resource ?x)))
        )
    )
    
)