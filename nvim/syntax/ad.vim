" Vim syntax file
" Language:    Analyse Descendante INSA (.ad)
" Maintainer:  Antigravity

if exists("b:current_syntax")
  finish
endif

syntax case ignore

syntax keyword adTodo contained TODO FIXME XXX NOTE ATTENTION NB IMPORTANT
syntax match adComment "//.*$" contains=adTodo

syntax match adSection "^\s*\(AD\|Nom\|Opérations\|Operations\|Organisation\)\s*:"

syntax keyword adType Entier Naturel NaturelNonNul NNN Reel Réel Booleen Booléen Caractere Caractère Chaine Chaîne Tableau Ensemble Point2D Operateur Opérateur
syntax match adType "\c\<naturel\(\s\+non\s\+nul\)\?\>"
syntax match adType "\c\<naturels\(\s\+non\s\+nuls\)\?\>"
syntax match adType "\c\<chaine\s\+de\s\+caract[eè]res\?\>"
syntax match adType "\c\<chaîne\s\+de\s\+caract[eè]res\?\>"

syntax match adOperator "→"
syntax match adOperator "->"
syntax match adOperator "←"
syntax match adOperator "<-"
syntax match adOperator "↛"
syntax match adOperator "\<x\>"
syntax match adOperator "×"

syntax match adDelimiter "[:,]"

hi def link adTodo Todo
hi def link adComment Comment
hi def link adSection Keyword
hi def link adType Type
hi def link adOperator Operator
hi def link adDelimiter Delimiter

let b:current_syntax = "ad"
