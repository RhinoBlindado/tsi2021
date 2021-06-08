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

; Ejercicio 5, Problema

(define (problem ej5p)
    (:domain terran5)
    (:objects
        ; Se instancias los objetos que se piden.
        LOC11 LOC12 LOC13 LOC14 LOC21 LOC22 LOC23 LOC24 LOC31 LOC32 LOC33 LOC34 - map
        VCE1 VCE2 VCE3 marine1 marine2 segador1 - unit
        centro-de-mando1 extractor1 barrancon1 bahia-de-ingenieria1 - building
        impulsar-segador - research
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

        ; Minerales
        ; - Localización de los nodos minerales.
        (resourceNode LOC23 mineral)
        (resourceNode LOC33 mineral)
        ; Gas Vespeno
        ; - Localización de los nodos de gas vespeno.
        (resourceNode LOC13 gas)

        ; VCE
        ; - Indicando que las unidades son VCE.
        (unitType VCE1 VCE)
        (unitType VCE2 VCE)
        (unitType VCE3 VCE)
        ; - Indicando que para reclutar VCEs es necesario tener minerales.
        (toHireNeeds VCE mineral)
        ; - Indicando que los VCEs se reclutan en los Centros de Mando.
        (hiredIn VCE centro-de-mando)
        ; - Localizando en el mapa la unidad.
        (in VCE1 LOC11)
        ; - Indicando que VCE1 ya está reclutado.
        (isHired VCE1)

        ; Marines
        ; - Indicando que las unidades son del tipo Marine.
        (unitType marine1 marine)
        (unitType marine2 marine)
        ; - Indicando que para reclutar Marines se necesitan minerales.
        (toHireNeeds marine mineral)
        ; - Indicando que los Marines se reclutan en los Barrancones.
        (hiredIn marine barrancon) 
        
        ; Segadores
        ; - Indicando que las unidades son del tipo Segador.
        (unitType segador1 segador)
        ; - Indicando que para reclutar Segadores se necesitan gas y minerales.
        (toHireNeeds segador mineral)
        (toHireNeeds segador gas)
        ; - Indicando que los Segadores se reclutan en los Barrancones.
        (hiredIn segador barrancon)
        ; - Los segadores necesitan de la investigación "Impulsar Segador" para ser reclutados
        (needsResearch segador impulsar-segador)

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

        ; Barrancones
        ; - Indicando que los Barrancones son del tipo.
        (buildingType barrancon1 barrancon)
        ; - Indicando que los Barrancones necesitan varios recursos.
        (toBuildNeeds barrancon mineral)
        (toBuildNeeds barrancon gas)

        ; Bahía de Ingeniería
        ; - Indicando que la Bahía es del tipo.
        (buildingType bahia-de-ingenieria1 bahia-de-ingenieria)
        ; - Indicando que la Bahía necesita de varios recursos.
        (toBuildNeeds bahia-de-ingenieria mineral)
        (toBuildNeeds bahia-de-ingenieria gas)
        ;  - Investigación "Impulsar Segador" necesita de ciertos recursos.
        (toResearchNeeds impulsar-segador gas)
        (toResearchNeeds impulsar-segador mineral)
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
)