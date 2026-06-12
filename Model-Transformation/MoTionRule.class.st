Class {
	#name : 'MoTionRule',
	#superclass : 'Object',
	#instVars : [
		'sourcePattern',
		'targetPattern',
		'model',
		'source'
	],
	#category : 'Model-Transformation',
	#package : 'Model-Transformation'
}

{ #category : 'accessing' }
MoTionRule >> model [
    ^ model
]

{ #category : 'accessing' }
MoTionRule >> model: aModel [
    model := aModel
]

{ #category : 'accessing' }
MoTionRule >> source [
    ^ source.
]

{ #category : 'accessing' }
MoTionRule >> source: aString [
    source := aString.
]

{ #category : 'accessing' }
MoTionRule >> sourcePattern [
    ^ sourcePattern
]

{ #category : 'accessing' }
MoTionRule >> sourcePattern: aPattern [
    sourcePattern := aPattern
]

{ #category : 'accessing' }
MoTionRule >> targetPattern [
    ^ targetPattern
]

{ #category : 'accessing' }
MoTionRule >> targetPattern: aPattern [
    targetPattern := aPattern
]

{ #category : 'transforming' }
MoTionRule >> transform [
    | diff results node rootType alias |
    rootType := sourcePattern type.
    alias := sourcePattern properties first value alias.
    diff := MoTionDiff new.
    diff sourcePattern: sourcePattern.
    diff targetPattern: targetPattern.
    diff compute.
    results := sourcePattern
        collectBindings: { alias }
        for: (model allWithType: rootType) first.
    results do: [ :binding |
        node := binding at: alias.
        diff differences do: [ :change |
            source := source
                copyReplaceFrom: node startPos
                to: node endPos
                with: change to value ] ].
    ^ source
]
