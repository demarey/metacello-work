"Loading the preview, should be a simulation of the standard bootstrap
after Metacello-Base has been loaded ... which is what the test harndess
does"
[| gitPath |
gitPath := (FileDirectory default directoryNamed: 'git_cache') fullName.

"Load the Metacello Tests ... "
Metacello new
	configuration: 'MetacelloPreview';
  version: '1.0.0-beta.32.2';
  repository: 'filetree://', gitPath, '/metacello-work';
  load: 'Tests'.
] on: Error do: [:ex | | stream |
    stream := Transcript. 
    (Smalltalk globals associationAt: #Transcript) value: (Smalltalk at: #OLDTranscript).
    stream close .
    ex pass].


"Run the Metacello tests"
(Smalltalk at: #MetacelloPlatform) current authorName: 'testMonkey'. "These tests save code ... need an Author"

TravisCIHarness
  value: #( 'ConfigurationOfMetacelloPreview' )
  value: 'TravisCISuccess.txt' 
  value: 'TravisCIFailure.txt'.
