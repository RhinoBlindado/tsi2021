(define (domain mono)
    (:requirements :strips :typing)
    (:types
        movible localizacion - object
        mono caja - movible
    )
    (:predicates
        (en ?obj - movible ?x - localizacion)
        (tienePlatano ?m - mono)
        (sobre ?m - mono ?c - caja)
        (platanoEn ?x - localizacion)
    )
    
    (:action cogerPlatanos
        :parameters (?m - mono ?c - caja ?x - localizacion)
        :precondition
            (and
                (sobre ?m ?c)
                (en ?c ?x)
                (platanoEn ?x)
            )
        :effect
            (and
                (tienePlatano ?m)
            )
    )
    
    (:action pushBox
        :parameters (?m - mono ?c - caja ?x ?y - localizacion)
        :precondition 
        (and 
            (en ?m ?x)
            (en ?c ?x)
        )
        :effect 
        (and 
            (en ?m ?y)
            (en ?c ?y)
            (not (en ?m ?x))
            (not (en ?c ?x))
        )
    
    )

    (:action goUpBox
        :parameters (?m - mono ?c - caja ?x - localizacion)
        :precondition 
        (and 
            (en ?m ?x)
            (en ?c ?x)
        )
        :effect 
        (and 
            (sobre ?m ?c)
            (not (en ?m ?x))
        )
    )

    (:action goDownBox
        :parameters (?m - mono ?c - caja ?x - localizacion)
        :precondition 
        (and 
            (sobre ?m ?c)
            (en ?c ?x)
        )
        :effect 
        (and 
            (en ?m ?x)
            (not (sobre ?m ?c))
        )
    )
    
    
    (:action goTo
        :parameters (?m - mono ?x ?y - localizacion)
        :precondition
            (and
                (en ?m ?x)
            )
        :effect
            (and
                (en ?m ?y)
                (not (en ?m ?x))
            )
    )
    
)