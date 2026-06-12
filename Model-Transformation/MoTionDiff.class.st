Class {
	#name : 'MoTionDiff',
	#superclass : 'Object',
	#instVars : [
		'sourcePattern',
		'targetPattern',
		'differences'
	],
	#category : 'Model-Transformation',
	#package : 'Model-Transformation'
}

{ #category : 'as yet unclassified' }
MoTionDiff >> comparePattern: source with: target [
    source properties doWithIndex: [:sourceProp :i |
        | targetProp |
        targetProp := target properties at: i.
        sourceProp value = targetProp value
            ifFalse: [
                differences add: (MoTionChange new
                    path: sourceProp key;
                    from: sourceProp value;
                    to: targetProp value) ]].
]

{ #category : 'accessing' }
MoTionDiff >> compute [
    | sourceProp targetProp |
    differences := OrderedCollection new.
    sourceProp := sourcePattern properties first value matcher properties first.
    targetProp := targetPattern properties first value matcher properties first.
    sourceProp value = targetProp value ifFalse: [
        differences add: (MoTionChange new
            path: sourceProp key;
            from: sourceProp value;
            to: targetProp value;
            yourself) ].
]

{ #category : 'accessing' }
MoTionDiff >> differences [
    ^ differences
]

{ #category : 'accessing' }
MoTionDiff >> sourcePattern [
    ^ sourcePattern
]

{ #category : 'accessing' }
MoTionDiff >> sourcePattern: aPattern [
    sourcePattern := aPattern
]

{ #category : 'accessing' }
MoTionDiff >> targetPattern [
    ^ targetPattern

]

{ #category : 'accessing' }
MoTionDiff >> targetPattern: aPattern [
    targetPattern := aPattern
]
