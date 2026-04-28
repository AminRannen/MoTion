Class {
	#name : 'MatcherLessThanOrEqualTo',
	#superclass : 'MatcherLiteralNumber',
	#category : 'MoTion',
	#package : 'MoTion'
}

{ #category : 'as yet unclassified' }
MatcherLessThanOrEqualTo >> lessOrEqualTo: aValue [
    ^ MatcherLessThanOrEqualTo value: aValue
]

{ #category : 'matching' }
MatcherLessThanOrEqualTo >> matchOnlyNumber: aNumber withContext: aContext [
    aContext isMatch: aNumber <= value
]
