Class {
	#name : 'MoTionRule',
	#superclass : 'Object',
	#instVars : [
		'binding',
		'model',
		'newValue',
		'source',
		'sourcePattern',
		'bindings'
	],
	#category : 'MoTion-FAST-Transformation',
	#package : 'MoTion-FAST-Transformation'
}

{ #category : 'accessing' }
MoTionRule >> binding [

	^ binding
]

{ #category : 'accessing' }
MoTionRule >> binding: anObject [

	binding := anObject
]

{ #category : 'accessing' }
MoTionRule >> bindings [

	^ bindings
]

{ #category : 'accessing' }
MoTionRule >> bindings: anObject [

	bindings := anObject
]

{ #category : 'as yet unclassified' }
MoTionRule >> executeOnFirst [
    | matches node newSource newModel |
    matches := self sourcePattern
        collectBindings: { self binding asSymbol }
        for: self model.
    
    "Prend seulement le PREMIER match"
    node := matches first at: self binding asSymbol.
    
    newSource := source
        copyReplaceFrom: node startPos
        to: node endPos
        with: newValue.
    
    newModel := FASTTypeScriptParser new parse: newSource.
    ^ Association key: newSource value: newModel
]

{ #category : 'as yet unclassified' }
MoTionRule >> executeRemoval [
    | matches sortedNodes newSource |
    matches := self sourcePattern
                   collectBindings: bindings keys asArray
                   for: self model.
    sortedNodes := OrderedCollection new.
    matches do: [ :match |
        bindings keys do: [ :bindingKey |
            | node |
            node := match at: bindingKey ifAbsent: [ nil ].
            node isNil ifFalse: [ sortedNodes add: node ] ] ].
    "Trie par startPos décroissant"
    sortedNodes := sortedNodes asSortedCollection: [ :a :b |
                       a startPos > b startPos ].
    newSource := source.
    sortedNodes do: [ :node |
        | from to |
        from := node startPos.
        to := node endPos.
        "Gère la virgule + espace AVANT le noeud"
        ((newSource at: from - 1 ifAbsent: [ nil ]) = $ 
            and: [ (newSource at: from - 2 ifAbsent: [ nil ]) = $, ])
            ifTrue: [ from := from - 2 ]
            ifFalse: [
                "Ou la virgule + espace APRÈS le noeud (si c'est le premier)"
                (newSource at: to + 1 ifAbsent: [ nil ]) = $,
                    ifTrue: [ to := to + 2 ] ].
        newSource := newSource
                         copyReplaceFrom: from
                         to: to
                         with: '' ].
    ^ newSource
]

{ #category : 'as yet unclassified' }
MoTionRule >> executeRemoveNode [

	| matches sortedNodes newSource |
	matches := self sourcePattern
		           collectBindings: bindings keys asArray
		           for: self model.
	sortedNodes := OrderedCollection new.
	matches do: [ :match |
		bindings keys do: [ :bindingKey |
			| node |
			node := match at: bindingKey ifAbsent: [ nil ].
			node isNil ifFalse: [ sortedNodes add: node ] ] ].
	sortedNodes := sortedNodes asSortedCollection: [ :a :b |
		               a startPos > b startPos ].
	newSource := source.
	sortedNodes do: [ :node |
		| from to |
		from := node startPos.
		to := node endPos.
		"Supprime aussi les espaces/tabs avant"
		[
		from > 1 and: [
			(newSource at: from - 1) = $  or: [
				(newSource at: from - 1) = Character tab ] ] ] whileTrue: [
			from := from - 1 ].
		"Supprime aussi le saut de ligne avant"
		(from > 1 and: [ (newSource at: from - 1) = Character lf ]) ifTrue: [
			from := from - 1 ].
		"Supprime aussi le saut de ligne après"
		(to < newSource size and: [ (newSource at: to + 1) = Character lf ])
			ifTrue: [ to := to + 1 ].
		newSource := newSource copyReplaceFrom: from to: to with: '' ].
	^ newSource
]

{ #category : 'as yet unclassified' }
MoTionRule >> executeWithBindings [
    | matches sortedChanges newSource |
    matches := self sourcePattern
                   collectBindings: bindings keys asArray
                   for: self model.
    sortedChanges := OrderedCollection new.
    matches do: [ :match |
        bindings keysAndValuesDo: [ :bindingKey :newVal |
            | nodeOrValue |
            nodeOrValue := match at: bindingKey ifAbsent: [ nil ].
            nodeOrValue isNil ifFalse: [
                (nodeOrValue respondsTo: #startPos)
                    ifTrue: [
                        "cas 1 : nœud AST direct (as:)"
                        (sortedChanges noneSatisfy: [:a | a key startPos = nodeOrValue startPos])
                            ifTrue: [ sortedChanges add: (Association key: nodeOrValue value: newVal) ] ]
                    ifFalse: [
                        (nodeOrValue isKindOf: Collection)
                            ifTrue: [
                                "cas 2 : collection (*rest)"
                                nodeOrValue do: [:each |
                                    | eachNode |
                                    eachNode := (each respondsTo: #startPos)
                                        ifTrue: [ each ]
                                        ifFalse: [ self findNodeWithSourceCode: each inModel: self model ].
                                    (eachNode notNil and: [
                                       "Deduplication pour èviter les memes matchs comme CalculatorNew " sortedChanges noneSatisfy: [:a | a key startPos = eachNode startPos]
                                    ]) ifTrue: [
                                        sortedChanges add: (Association key: eachNode value: newVal) ] ] ]
                            ifFalse: [
                                "cas 3 : String (@x)"
                                | node |
                                node := self findNodeWithSourceCode: nodeOrValue inModel: self model.
                                (node notNil and: [
                                    sortedChanges noneSatisfy: [:a | a key startPos = node startPos]
                                ]) ifTrue: [
                                    sortedChanges add: (Association key: node value: newVal) ] ] ] ] ] ].
    sortedChanges := sortedChanges asSortedCollection: [ :a :b |
                         a key startPos > b key startPos ].
    newSource := source.
    sortedChanges do: [ :assoc |
        | node newVal |
        node := assoc key.
        newVal := assoc value.
        newSource := newSource
                         copyReplaceFrom: node startPos
                         to: node endPos
                         with: newVal ].
    ^ newSource
]

{ #category : 'as yet unclassified' }
MoTionRule >> findAssociation: association in: myPattern [

	myPattern properties do: [ :assoc |
		assoc = association
			ifTrue: [ ^ myPattern ]
			ifFalse: [^ self findAssociation: association in: assoc value ] ]
]

{ #category : 'as yet unclassified' }
MoTionRule >> findNodeWithSourceCode: aString inModel: aModel [


	^ aModel allChildren
		  detect: [ :node |
			  (node respondsTo: #sourceCode) and: [ node sourceCode = aString ] ]
		  ifNone: [ nil ]
]

{ #category : 'as yet unclassified' }
MoTionRule >> findWildcard: aWildcardKey in: anObjectOfTypeA [
	"Recursively searches through associations for the value matching aWildcardKey.
     Returns the value found, or nil if not found."

	anObjectOfTypeA properties do: [ :assoc |
		(assoc value isKindOf: MatcherWildcard) ifTrue: [
			assoc value alias = aWildcardKey ifTrue: [ ^ assoc  ] ].

		"If the value is itself of type A, recurse into it"
		(assoc value isKindOf: MatcherMooseObject) ifTrue: [
			| result |
			result := self findWildcard: aWildcardKey in: assoc value.
			result ifNotNil: [ ^ result ] ] ].

	^ nil
]

{ #category : 'accessing' }
MoTionRule >> model [

	^ model
]

{ #category : 'accessing' }
MoTionRule >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
MoTionRule >> newValue [

	^ newValue
]

{ #category : 'accessing' }
MoTionRule >> newValue: anObject [

	newValue := anObject
]

{ #category : 'accessing' }
MoTionRule >> source [

	^ source
]

{ #category : 'accessing' }
MoTionRule >> source: anObject [

	source := anObject
]

{ #category : 'accessing' }
MoTionRule >> sourcePattern [

	^ sourcePattern
]

{ #category : 'accessing' }
MoTionRule >> sourcePattern: anObject [

	sourcePattern := anObject
]
