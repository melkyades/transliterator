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
ImageModuleBuilder >> addClassDefinition: aClass [
	| spec |
	spec := self specFromClass: aClass.
	module addClass: spec.
	self importSharedPoolsOf: aClass.
	^spec
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addClassExtension: aClass [
	| spec |
	spec := self specFromClass: aClass.
	module addClassExtension: spec.
	self importSharedPoolsOf: aClass.
	^spec
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addClasses: aCollection [
	aCollection do: [:c | self addClass: c]
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addMethod: aCompiledMethod [
	^self subclassResponsibility
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> addMethodCompiling: aString in: aSpecies [
	| class spec |
	class := self ensureClass: aSpecies.
	spec := self specFromSource: aString species: class.
	class addMethod: spec

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

{ #category : #private }
ImageModuleBuilder >> compilerFor: aSpeciesSpec [
		^self subclassResponsibility
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> ensureClass: aClass [
	| class |
	class := module resolveClass: aClass name.
	^class ifNil: [self addClassExtension: aClass] ifNotNil: [class]
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> importSharedPoolsOf: aClass [
	aClass sharedPools do: [:symbol | 
		module at: symbol ifAbsent: [| pool |
			pool := Smalltalk at: symbol.
			module addImport: symbol -> pool copy]]
]

{ #category : #initialization }
ImageModuleBuilder >> initialize [
	module := ModuleSpec new
]

{ #category : #'adding / removing' }
ImageModuleBuilder >> isIncomplete: aClassSpec [
	"
	a class that has been added inderectly and whose shape is not defined
	"
	^aClassSpec name != 'ProtoObject' and: [aClassSpec superclass = nil]
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

{ #category : #private }
ImageModuleBuilder >> specFromMetaclass: aMetaclass class: aClassSpec [
	^MetaclassSpec new
		ivars: aMetaclass instVarNames asOrderedCollection;
		module: module;
		instanceClass: aClassSpec
]

{ #category : #private }
ImageModuleBuilder >> specFromMethod: aCompiledMethod species: aSpeciesSpec [
	^MethodSpec new
		module: module;
		selector: aCompiledMethod selector;
		classBinding: aSpeciesSpec;
		source: aCompiledMethod sourceCode;
		category: aCompiledMethod category
]

{ #category : #private }
ImageModuleBuilder >> specFromSource: aString species: aSpeciesSpec [
	| compiler method |
	compiler := self compilerFor: aSpeciesSpec.
	method := compiler compile: aString.
	^MethodSpec new
		module: module;
		selector: method selector;
		classBinding: aSpeciesSpec;
		source: aString;
		category: 'unclassified'
]
