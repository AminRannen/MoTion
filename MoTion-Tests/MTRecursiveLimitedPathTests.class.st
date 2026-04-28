Class {
	#name : 'MTRecursiveLimitedPathTests',
	#superclass : 'MTRecursiveChildrenPathTests',
	#category : 'MoTion-Tests',
	#package : 'MoTion-Tests'
}

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testRecursiveLimitedPath [
    | path result |
    
    "depth 1 → seulement c de a"
    path := MTRecursiveLimitedPath of: #c depth: 1.
    result := path resolveFrom: a.
    self assertCollection: result hasSameElements: { c }.

    "depth 2 → c de a, puis c de b... mais b n'est pas dans les résultats"
    "Donc toujours { c }"
    path := MTRecursiveLimitedPath of: #c depth: 2.
    result := path resolveFrom: a.
    self assertCollection: result hasSameElements: { c }.
]
