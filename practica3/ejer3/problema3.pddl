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

; Ejercicio 3, Problema

(define (problem ej3p)
    (:domain terran3)
    (:objects
        ; Se instancian los objetos necesarios.
        LOC11 LOC12 LOC13 LOC14 LOC21 LOC22 LOC23 LOC24 LOC31 LOC32 LOC33 LOC34 - map
        VCE1 VCE2 VCE3 - unit
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
        ; - Localizando en el mapa las unidades.
        (in VCE1 LOC11)
        (in VCE2 LOC11)
        (in VCE3 LOC11)

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
        (needs extractor mineral)

        ; Barrancones
        ; - Indicando que los Barrancones son del tipo.
        (buildingType barrancon1 barrancon)
        ; - Indicando que los Barrancones necesitan varios minerales.
        (needs barrancon mineral)
        (needs barrancon gas)
    )
    (:goal
        (and
            ; El objetivo es construir un Barrancón en LOC32.
            (in barrancon1 LOC32)
        )
    )
)