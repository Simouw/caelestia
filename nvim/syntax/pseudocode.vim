" Vim syntax file
" Language:    Pseudo-code / Algorithmique (Français, Pascal, C, Python, INSA)
" Maintainer:  Antigravity
" Description: Coloration syntaxique complète pour le pseudo-code et l'algorithmique

if exists("b:current_syntax")
  finish
endif

syntax case ignore

" ---------------------------------------------------------
" 1. TODO / Annotations dans les commentaires
" ---------------------------------------------------------
syntax keyword pseudoTodo contained TODO FIXME XXX NOTE ATTENTION NB IMPORTANT BUG

" ---------------------------------------------------------
" 2. Délimiteurs de base
" ---------------------------------------------------------
syntax match pseudoDelimiter "[;,()[\]{}]"
syntax match pseudoDelimiter ":"

" ---------------------------------------------------------
" 3. Opérateurs arithmétiques, logiques et flèches d'affectation
" ---------------------------------------------------------
syntax match pseudoOperator "[+\-*/%^=<>!]"
syntax match pseudoOperator "<-"
syntax match pseudoOperator "←"
syntax match pseudoOperator ":="
syntax match pseudoOperator "->"
syntax match pseudoOperator "→"
syntax match pseudoOperator "↛"
syntax match pseudoOperator "=="
syntax match pseudoOperator "<="
syntax match pseudoOperator ">="
syntax match pseudoOperator "<>"
syntax match pseudoOperator "!="
syntax match pseudoOperator "≤"
syntax match pseudoOperator "≥"
syntax match pseudoOperator "≠"
syntax match pseudoOperator "\.\.\."
syntax match pseudoOperator "\.\."
syntax match pseudoOperator "\."
syntax match pseudoOperator "&&"
syntax match pseudoOperator "||"
syntax match pseudoOperator "×"
syntax match pseudoOperator "\<x\>"

" ---------------------------------------------------------
" 4. Mots-clés logiques (texte)
" ---------------------------------------------------------
syntax keyword pseudoLogical et and ET AND
syntax keyword pseudoLogical ou or OU OR
syntax keyword pseudoLogical non not NON NOT
syntax keyword pseudoLogical xor ouex ou_ex XOR
syntax keyword pseudoLogical mod modulo MOD
syntax keyword pseudoLogical div DIV
syntax match pseudoLogical "\c\<ou\s\+bien\>"
syntax match pseudoLogical "\c\<et\s\+alors\>"
syntax match pseudoLogical "\c\<ou\s\+sinon\>"

" ---------------------------------------------------------
" 5. Constantes, Booléens & Valeurs spéciales
" ---------------------------------------------------------
syntax keyword pseudoBoolean vrai faux true false TRUE FALSE VRAI FAUX Vrai Faux
syntax keyword pseudoConstant nil null NULL none NONE rien vide empty pi PI infini infinity

" ---------------------------------------------------------
" 6. Nombres (décimaux, flottants, scientifiques, hexadécimaux)
" ---------------------------------------------------------
syntax match pseudoNumber "\<0x[0-9a-fA-F]\+\>"
syntax match pseudoNumber "\$[0-9a-fA-F]\+\>"
syntax match pseudoNumber "\<[0-9]\+\(\.[0-9]\+\)\?\([eE][+-]\?[0-9]\+\)\?\>"

" ---------------------------------------------------------
" 7. Types de données
" ---------------------------------------------------------
syntax keyword pseudoType entier entiers integer int Int INTEGER
syntax keyword pseudoType naturel naturels Naturel Naturels NaturelNonNul NNN
syntax keyword pseudoType reel reels réel réels real float double Float Double REAL
syntax keyword pseudoType ReelPositif ReelPositifNonNul ReelNegatif ReelNegatifNonNul
syntax keyword pseudoType booleen booleens booléen booléens boolean bool Boolean BOOL
syntax keyword pseudoType caractere caracteres caractère caractères char character Char CHAR
syntax keyword pseudoType chaine chaines chaîne chaînes string text texte String STRING
syntax keyword pseudoType tableau tableaux array matrice matrices matrix vecteur vecteurs vector
syntax keyword pseudoType liste list pile stack file queue arbre tree graphe graph
syntax keyword pseudoType pointeur pointeurs pointer ptr
syntax keyword pseudoType element elements élément éléments noeud noeuds nœud nœuds node
syntax keyword pseudoType Operateur Opérateur operateur opérateur
syntax keyword pseudoType Point2D Ensemble
syntax keyword pseudoType void aucun

syntax match pseudoType "\c\<naturel\(\s\+non\s\+nul\)\?\>"
syntax match pseudoType "\c\<naturels\(\s\+non\s\+nuls\)\?\>"
syntax match pseudoType "\c\<chaine\s\+de\s\+caract[eè]res\?\>"
syntax match pseudoType "\c\<chaîne\s\+de\s\+caract[eè]res\?\>"

" ---------------------------------------------------------
" 8. Structure d'algorithme, en-têtes et modules
" ---------------------------------------------------------
syntax keyword pseudoStructure algorithme algorithmes algorithm algorithmie
syntax keyword pseudoStructure programme program
syntax keyword pseudoStructure module sub
syntax keyword pseudoStructure constantes constante const constant constants
syntax keyword pseudoStructure variables variable var vars
syntax keyword pseudoStructure type types
syntax keyword pseudoStructure structure structures struct enregistrement enregistrements record
syntax keyword pseudoStructure debut début begin start
syntax keyword pseudoStructure lexique dictionnaire
syntax keyword pseudoStructure prérequis prerequis préconditions preconditions précondition precondition
syntax keyword pseudoStructure déclaration declaration

syntax keyword pseudoStructure finalgorithme finalgorithmes finprogramme finmodule
syntax keyword pseudoStructure finstructure finenregistrement endstruct endrecord
syntax match pseudoStructure "\c\<fin\s\+algorithme\(s\)\?\>"
syntax match pseudoStructure "\c\<fin\s\+programme\>"
syntax match pseudoStructure "\c\<fin\s\+module\>"
syntax match pseudoStructure "\c\<fin\s\+structure\>"
syntax match pseudoStructure "\c\<fin\s\+enregistrement\>"
syntax match pseudoStructure "\c\<end\s\+struct\>"
syntax match pseudoStructure "\c\<end\s\+record\>"

syntax match pseudoStructure "\c\<fin\>\(\s\+\(si\|pour\|tant\s*que\|selon\|fonction\|proc[ée]dure\|action\|algorithme\(s\)\?\|programme\|module\|structure\|enregistrement\|boucle\)\)\@!"
syntax match pseudoStructure "\c\<end\>\(\s\+\(if\|for\|while\|loop\|switch\|case\|function\|procedure\|struct\|record\)\)\@!"

" ---------------------------------------------------------
" 9. Fonctions, Procédures et Déclarations
" ---------------------------------------------------------
syntax keyword pseudoFunctionDef fonction fonctions function func fn def
syntax keyword pseudoFunctionDef procedure procedures procédure procédures proc action actions
syntax keyword pseudoStatement retourne retourner renvoie renvoyer return rend rendre
syntax keyword pseudoStatement pass yield sizeof

syntax match pseudoStatement "\c\<par\s\+valeur\>"
syntax match pseudoStatement "\c\<par\s\+r[ée]f[ée]rence\>"
syntax match pseudoStatement "\c\<par\s\+adresse\>"
syntax match pseudoStatement "\c\<par\s\+variable\>"
syntax keyword pseudoStatement ref out inout

" Paramètres INSA : E, S, E/S
syntax match pseudoStatement "\<E/S\>"
syntax match pseudoStatement "\<[ES]\ze\s\+[a-zA-Z_]\>"

syntax keyword pseudoFunctionDef finfonction finprocedure finprocédure finaction
syntax keyword pseudoFunctionDef endfunction endprocedure
syntax match pseudoFunctionDef "\c\<fin\s\+fonction\>"
syntax match pseudoFunctionDef "\c\<fin\s\+proc[ée]dure\>"
syntax match pseudoFunctionDef "\c\<fin\s\+action\>"
syntax match pseudoFunctionDef "\c\<end\s\+function\>"
syntax match pseudoFunctionDef "\c\<end\s\+procedure\>"

syntax match pseudoFunctionName "\c\(\<\(fonction\|proc[ée]dure\|action\|algorithme\(s\)\?\|programme\|program\|def\)\s\+\)\@<=[a-zA-Z_][a-zA-Z0-9_]*\>"

" ---------------------------------------------------------
" 10. Structures conditionnelles
" ---------------------------------------------------------
syntax keyword pseudoConditional si if alors then sinon else
syntax keyword pseudoConditional sinonsi sinon_si elif elseif else_if
syntax keyword pseudoConditional finsi endif
syntax keyword pseudoConditional selon switch case cas choix vaut
syntax keyword pseudoConditional autrement default autre
syntax keyword pseudoConditional finselon endswitch endcase fincas

syntax match pseudoConditional "\c\<sinon\s\+si\>"
syntax match pseudoConditional "\c\<else\s\+if\>"
syntax match pseudoConditional "\c\<fin\s\+si\>"
syntax match pseudoConditional "\c\<end\s\+if\>"
syntax match pseudoConditional "\c\<fin\s\+selon\>"
syntax match pseudoConditional "\c\<end\s\+switch\>"
syntax match pseudoConditional "\c\<end\s\+case\>"
syntax match pseudoConditional "\c\<selon\s\+que\>"
syntax match pseudoConditional "\c\<cas\s\+o[ùu]\>"

" ---------------------------------------------------------
" 11. Boucles et itérations
" ---------------------------------------------------------
syntax keyword pseudoRepeat pour for de from to downto pas step of dans in
syntax keyword pseudoRepeat à
syntax keyword pseudoRepeat faire do
syntax keyword pseudoRepeat finpour endfor
syntax keyword pseudoRepeat tantque tant_que while
syntax keyword pseudoRepeat fintantque endwhile
syntax keyword pseudoRepeat repeter répéter repeat
syntax keyword pseudoRepeat jusqua until
syntax keyword pseudoRepeat boucle loop finboucle endloop
syntax keyword pseudoRepeat arreter arrêter break quitter sortir continuer continue

syntax match pseudoRepeat "\c\<fin\s\+pour\>"
syntax match pseudoRepeat "\c\<end\s\+for\>"
syntax match pseudoRepeat "\c\<tant\s\+que\>"
syntax match pseudoRepeat "\c\<fin\s\+tant\s*que\>"
syntax match pseudoRepeat "\c\<end\s\+while\>"
syntax match pseudoRepeat "\c\<fin\s\+boucle\>"
syntax match pseudoRepeat "\c\<end\s\+loop\>"
syntax match pseudoRepeat "\c\<jusqu['’]\s*[aà]\s*ce\s*que\>"
syntax match pseudoRepeat "\c\<jusqu['’]\s*[àa]\>"
syntax match pseudoRepeat "\c\<jusqu\s\+[àa]\>"
syntax match pseudoRepeat "\c\<pour\s\+chaque\>"
syntax match pseudoRepeat "\c\<pour\s\+tout\(s\)\?\>"
syntax match pseudoRepeat "\c\<for\s\+each\>"
syntax match pseudoRepeat "\c\<for\s\+all\>"

syntax match pseudoRepeat "\c\<pour\>.\{-}\<de\>.\{-}\zs\<a\>\ze.\{-}\<faire\>"

" ---------------------------------------------------------
" 12. Fonctions standards d'E/S et utilitaires
" ---------------------------------------------------------
syntax keyword pseudoIO lire read readln saisir input scan scanf
syntax keyword pseudoIO ecrire écrire afficher imprimer print println printf write writeln output echo prompt
syntax keyword pseudoIO allouer liberer libérer malloc free new delete dispose
syntax keyword pseudoIO longueur taille len length size
syntax keyword pseudoIO abs racine sqrt arrondi tronc floor ceil puissance pow
syntax keyword pseudoIO concat souschaine sous_chaine substr pos
syntax keyword pseudoIO est_vide estvide isempty est_plein estplein
syntax keyword pseudoIO empiler depiler dépiler push pop
syntax keyword pseudoIO enfiler defiler défiler enqueue dequeue

syntax match pseudoCall "\<[a-zA-Z_][a-zA-Z0-9_]*\ze\s*("

" ---------------------------------------------------------
" 13. Chaînes de caractères et échappements
" ---------------------------------------------------------
syntax match pseudoEscape contained "\\\([nrt\\'""]\|[0-9]\+\)"
syntax region pseudoString start=+"+ skip=+\\"+ end=+"+ contains=pseudoEscape
syntax region pseudoString start=+'+ skip=+\\'+ end=+'+ contains=pseudoEscape

" ---------------------------------------------------------
" 14. Commentaires
" ---------------------------------------------------------
syntax match pseudoComment "//.*$" contains=pseudoTodo
syntax match pseudoComment "#.*$" contains=pseudoTodo
syntax match pseudoComment "--.*$" contains=pseudoTodo
syntax region pseudoComment start="/\*" end="\*/" contains=pseudoTodo
syntax region pseudoComment start="(\*" end="\*)" contains=pseudoTodo

" ---------------------------------------------------------
" 15. Liaisons aux groupes de surbrillance
" ---------------------------------------------------------
hi def link pseudoTodo         Todo
hi def link pseudoComment      Comment
hi def link pseudoString       String
hi def link pseudoEscape       Special
hi def link pseudoNumber       Number
hi def link pseudoBoolean      Boolean
hi def link pseudoConstant     Constant
hi def link pseudoType         Type
hi def link pseudoStructure    Structure
hi def link pseudoFunctionDef  Keyword
hi def link pseudoFunctionName Function
hi def link pseudoStatement    Statement
hi def link pseudoConditional  Conditional
hi def link pseudoRepeat       Repeat
hi def link pseudoLogical      Operator
hi def link pseudoOperator     Operator
hi def link pseudoIO           Function
hi def link pseudoCall         Function
hi def link pseudoDelimiter    Delimiter

let b:current_syntax = "pseudocode"
