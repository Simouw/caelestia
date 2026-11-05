" Vim syntax file
" Language:    Type Abstrait de Données INSA (.tad)
" Maintainer:  Antigravity

if exists("b:current_syntax")
  finish
endif

syntax case ignore

syntax keyword tadTodo contained TODO FIXME XXX NOTE ATTENTION NB IMPORTANT
syntax match tadComment "//.*$" contains=tadTodo

syntax match tadSection "^\s*\(TAD\|Nom\|Param[eè]tres\?\|Utilise\|Op[eè]rations\|Operations\|S[eè]mantiques\|Semantiques\|Axiomes\|Pr[eè]conditions\|Preconditions\)\s*:"

syntax keyword tadType Entier Naturel NaturelNonNul NNN Reel Réel Booleen Booléen Caractere Caractère Chaine Chaîne Tableau Ensemble Point2D Element Pile File
syntax match tadType "\c\<naturel\(\s\+non\s\+nul\)\?\>"
syntax match tadType "\c\<naturels\(\s\+non\s\+nuls\)\?\>"
syntax match tadType "\c\<chaine\s\+de\s\+caract[eè]res\?\>"
syntax match tadType "\c\<chaîne\s\+de\s\+caract[eè]res\?\>"

syntax match tadOperator "→"
syntax match tadOperator "->"
syntax match tadOperator "←"
syntax match tadOperator "<-"
syntax match tadOperator "↛"
syntax match tadOperator "\<x\>"
syntax match tadOperator "×"
syntax match tadOperator "[=≠≤≥<>]"

syntax keyword tadLogical et ou non
syntax keyword tadBoolean vrai faux VRAI FAUX true false

syntax match tadDelimiter "[:,()]"

hi def link tadTodo Todo
hi def link tadComment Comment
hi def link tadSection Keyword
hi def link tadType Type
hi def link tadOperator Operator
hi def link tadLogical Operator
hi def link tadBoolean Boolean
hi def link tadDelimiter Delimiter

let b:current_syntax = "tad"
