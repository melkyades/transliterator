Class {
	#name : #ImageModuleBuilder,
	#superclass : #Object,
	#instVars : [
		'module'
	],
	#category : #'CodeSpecs-Porting'
}

{ #category : #'adding / removing' }
ImageModuleBuilder >> addClass: aClass [
	| class |
	class := self addClassDefinition: aClass.
	self addAllMethodsFrom: aClass into: class
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addClasses: aCollection [
	aCollection do: [:c | self addClass: c]
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addMethods: aCollection into: aSpeciesSpec [
	| specs |
	specs := aCollection
		collect: [:m | self specFromMethod: m species: aSpeciesSpec].
	aSpeciesSpec addMethods: specs
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addSelectors: aCollection from: aSpecies [
	| class methods |
	class := self ensureClass: aSpecies instanceClass.
	aSpecies isMetaclass ifTrue: [class := class metaclass].
	methods := aCollection collect: [:selector | aSpecies >> selector].
	self addMethods: methods into: class
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addSubclassifiedClasses [
	module allClassesDo: [:c | self addSuperclassesOf: c]
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addSuperclassesOf: aClassSpec [
	| next spec |
	next := aClassSpec supername.
	[
		next ifNil: [| c |
			c := Smalltalk at: aClassSpec name asSymbol ifAbsent: [^self].
			next := c superclass ifNotNil: [:s | s name]].
		next ifNil: [^self].
		spec := module resolveClass: next.
		spec isNil or: [self isIncomplete: spec]]
		whileTrue: [| class |
			class := Smalltalk at: next asSymbol.
			spec := self specFromClass: class.
			module addSubclassifiedClass: spec.
			next := spec supername]
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> ensureClass: aClass [
	| class |
	class := module resolveClass: aClass name.
	^class ifNil: [self addClassExtension: aClass] ifNotNil: [class]
]

{ #category : #initialization }
ImageModuleBuilder >> initialize [
	module := ModuleSpec new
]

{ #category : #accessing }
ImageModuleBuilder >> module [
	^module
]

{ #category : #initialization }
ImageModuleBuilder >> module: aModuleSpec [
	module := aModuleSpec
]

{ #category : #accessing }
ImageModuleBuilder >> name: aString [
	module name: aString
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> removeClass: aClassSpec [
	module removeClass: aClassSpec
]
