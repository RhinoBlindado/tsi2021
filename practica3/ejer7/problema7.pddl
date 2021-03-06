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

; Ejercicio 7, Problema

(define (problem ej7p)
    (:domain terran7)
    (:objects
        ; Se instancian los objetos necesarios.
        LOC11 LOC12 LOC13 LOC14 LOC21 LOC22 LOC23 LOC24 LOC31 LOC32 LOC33 LOC34 - map
        VCE1 VCE2 VCE3 marine1 marine2 segador1 - unit
        centro-de-mando1 extractor1 barrancon1 - building
    )
    (:init
        ; Mapa
        ; - Definiendo el mapa por medio de los predicados 'connected'
        (connected LOC11 LOC12)
        (connected LOC12 LOC11)

        (connected LOC11 LOC21)
        (connected LOC21 LOC11)

        (connected LOC21 LOC31)
        (connected LOC31 LOC21)

        (connected LOC31 LOC32)
        (connected LOC32 LOC31)

        (connected LOC12 LOC22)
        (connected LOC22 LOC12)

        (connected LOC22 LOC32)
        (connected LOC32 LOC22)

        (connected LOC22 LOC23)
        (connected LOC23 LOC22)

        (connected LOC23 LOC13)
        (connected LOC13 LOC23)

        (connected LOC13 LOC14)
        (connected LOC14 LOC13)

        (connected LOC14 LOC24)
        (connected LOC24 LOC14)

        (connected LOC24 LOC34)
        (connected LOC34 LOC24)

        (connected LOC34 LOC33)
        (connected LOC33 LOC34)
        ; - Unidades de distancia entre localizaciones
        (= (distance) 10)

        ; Recursos
        ; - Localización de los nodos minerales.
        (resourceNode LOC23 mineral)
        (resourceNode LOC33 mineral)
        ; - Localización de los nodos de gas vespeno.
        (resourceNode LOC13 gas)
        ; - Contadores inicializados a cero.
        (= (resourceCount mineral) 0)
        (= (resourceCount gas) 0)
        ; - Máximo número de recursos
        (= (maxResourses mineral) 60)
        (= (maxResourses gas) 60)
        ; - Indicando que no hay VCEs extrayendo recursos.
        (= (VCEcount mineral LOC23) 0)
        (= (VCEcount mineral LOC33) 0)
        (= (VCEcount gas LOC13) 0)

        
        ; VCE
        ; - Indicando que las unidades son VCE.
        (unitType VCE1 VCE)
        (unitType VCE2 VCE)
        (unitType VCE3 VCE)
        ; - Indicando que para reclutar VCEs es necesario tener minerales.
        (toHireNeeds VCE mineral)
        ; - Indicando la cantidad necesaria.
        (= (toHireNeedsNum VCE mineral) 10)
        ; - Indicando que los VCEs se reclutan en los Centros de Mando.
        (hiredIn VCE centro-de-mando)
        ; - Localizando en el mapa la unidad.
        (in VCE1 LOC11)
        ; - Indicando que VCE1 ya está reclutado.
        (isHired VCE1)
        ; - Indicando cuánto tarda para moverse entre localizaciones.
        (= (timeToMove VCE) 1)
        ; - Indicando cuánto tarda en reclutarse.
        (= (timeToHire VCE) 12)

        ; Marines
        ; - Indicando que las unidades son del tipo Marine.
        (unitType marine1 marine)
        (unitType marine2 marine)
        ; - Indicando que para reclutar Marines se necesitan mineral y gas.
        (toHireNeeds marine mineral)
        (toHireNeeds marine gas)
        ; - Indicando la cantidad de recursos necesarios
        (= (toHireNeedsNum marine mineral) 20)
        (= (toHireNeedsNum marine gas) 10)
        ; - Indicando que los Marines se reclutan en los Barrancones.
        (hiredIn marine barrancon)
        ; - Indicando cuánto tarda para moverse entre localizaciones.
        (= (timeToMove marine) 5)
        ; - Indicando cuánto tarda en reclutarse.
        (= (timeToHire marine) 18)
        
        ; Segadores
        ; - Indicando que las unidades son del tipo Segador.
        (unitType segador1 segador)
        ; - Indicando que para reclutar Segadores se necesitan gas y minerales.
        (toHireNeeds segador mineral)
        (toHireNeeds segador gas)
        ; - Y la cantidad de esos recursos.
        (= (toHireNeedsNum segador mineral) 30)
        (= (toHireNeedsNum segador gas) 30)
        ; - Indicando que los Segadores se reclutan en los Barrancones.
        (hiredIn segador barrancon)
        ; - Indicando cuánto tarda para moverse entre localizaciones.
        (= (timeToMove segador) 10)
        ; - Indicando cuánto tarda en reclutarse.
        (= (timeToHire segador) 32)

        ; Centro de Mando
        ; - Indicando que el Centro de Mando es de tipo Centro de Mando.
        (buildingType centro-de-mando1 centro-de-mando)
        ; - Localizandolo en el mapa.
        (in centro-de-mando1 LOC11)
        ; - Indicando que ya está construido.
        (built centro-de-mando1)

        ; Extractor
        ; - Indicando que el Extractor es del tipo.
        (buildingType extractor1 extractor)
        ; - Indicando que el Extractor necesita de minerales.
        (toBuildNeeds extractor mineral)
        ; - Y la cantidad de mineral.
        (= (toBuildNeedsNum extractor mineral) 33)
        ; - Tiempo que tarda en construirse.
        (= (timeToBuild extractor) 21)
        ; - Tiempo que tarda en extraer un recurso.
        (= (timeToExtract) 10)

        
        ; Barrancones
        ; - Indicando que los Barrancones son del tipo.
        (buildingType barrancon1 barrancon)
        ; - Indicando que los Barrancones necesitan varios recursos.
        (toBuildNeeds barrancon mineral)
        (toBuildNeeds barrancon gas)
        ; - Y las cantidades de esos recursos.
        (= (toBuildNeedsNum barrancon mineral) 50)
        (= (toBuildNeedsNum barrancon gas) 20)
        ; - Tiempo que tarda en construirse.
        (= (timeToBuild barrancon) 46)

        ; Tiempo de inicio de la partida.
        (= (tick) 0)
    )
    (:goal
        ; El objetivo es:
        (and
            ; - El objetivo es construir un Barrancón en LOC32.
            (in barrancon1 LOC32)
            ; - Disponer de un marine (Marine1) en la localización LOC31
            (in marine1 LOC31)
            ; - Disponer de otro marine (Marine2) en la localización LOC24
            (in marine2 LOC24)
            ; - Disponer de un segador (Segador1) en la localización LOC12
            (in segador1 LOC12)
        )
    )
    ; Minimizar la cantidad de tiempo.
    (:metric minimize (tick))
)