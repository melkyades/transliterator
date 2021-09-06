Class {
	#name : #PharoModuleBuilder,
	#superclass : #ImageModuleBuilder,
	#category : #'CodeSpecs-Porting'
}

{ #category : #'adding / removing' }
PharoModuleBuilder >> addMethod: aCompiledMethod [
	| class spec |
	class := self ensureClass: aCompiledMethod methodClass instanceSide.
	aCompiledMethod methodClass isMeta ifTrue: [class := class metaclass].
	spec := self specFromMethod: aCompiledMethod species: class.
	class addMethod: spec

]

{ #category : #'adding / removing' }
PharoModuleBuilder >> calculateDependencies [
	| imports extensions |
	self addSubclassifiedClasses.
	imports := module requiredImports.
	module addImports: imports keys.
	extensions := Dictionary new.
	module extendedClasses do: [:spec | 
		Smalltalk at: spec name asSymbol ifPresent: [:class | | deps methods |
			deps := extensions at: class package name ifAbsentPut: [Dictionary new].
			methods := deps at: spec name ifAbsentPut: [OrderedCollection new].
			methods addAll: spec methods]].
	module addDependencies: extensions
	
]

{ #category : #'adding / removing' }
PharoModuleBuilder >> compilerFor: aSpeciesSpec [
	^(SCompiler forClass: aSpeciesSpec) namespace: module
]

{ #category : #'adding / removing' }
PharoModuleBuilder >> specFromClass: aClass [
	| class metaclass n |
	class := ClassSpec new.
	metaclass := self specFromMetaclass: aClass class: class.
	n := aClass superclass ifNotNil: [:s | s name].
	class
		module: module;
		metaclass: metaclass;
		name: aClass name;
		supername: n;
		ivars: aClass instVarNames asOrderedCollection;
		cvars: aClass classPool;
		sharedPools: aClass sharedPools.
	aClass isVariable ifTrue: [class beArrayed].
	aClass isBytes ifTrue: [class beBytes].
	^class
]
