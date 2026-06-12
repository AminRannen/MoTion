Class {
	#name : 'MoTionChange',
	#superclass : 'Object',
	#instVars : [
		'path',
		'from',
		'to'
	],
	#category : 'Model-Transformation',
	#package : 'Model-Transformation'
}

{ #category : 'accessing' }
MoTionChange >> from [
    ^ from
]

{ #category : 'accessing' }
MoTionChange >> from: aValue [
    from := aValue
]

{ #category : 'accessing' }
MoTionChange >> path [
    ^ path
]

{ #category : 'accessing' }
MoTionChange >> path: aPath [
    path := aPath
]

{ #category : 'accessing' }
MoTionChange >> to [
    ^ to

]

{ #category : 'accessing' }
MoTionChange >> to: aValue [
    to := aValue
]
