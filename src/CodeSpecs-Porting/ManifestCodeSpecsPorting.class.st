"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestCodeSpecsPorting,
	#superclass : #PackageManifest,
	#category : #'CodeSpecs-Porting-Manifest'
}

{ #category : #'code-critics' }
ManifestCodeSpecsPorting class >> ruleRBCollectionMessagesToExternalObjectRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#ModuleTransliteratorTest)) #'2021-08-25T00:31:06.086954-03:00') )
]

{ #category : #'code-critics' }
ManifestCodeSpecsPorting class >> ruleRBGlobalVariablesUsageV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#PharoModuleBuilder #calculateDependencies #false)) #'2021-08-24T23:07:45.576593-03:00') )
]
