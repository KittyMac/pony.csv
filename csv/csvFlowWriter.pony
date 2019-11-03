use "collections"
use "fileExt"
use "flow"

actor CSVFlowWriter is Flowable
	"""
	Takes an array of array of strings and converts it into raw, chunked CSV content
	"""
		
	let comma:U8 = 44
	let doubleQuote:U8 = 34
	let newLine:U8 = 10
	
	let target:Flowable tag
	
	
	fun _batch():USize => 4
	
	new create(target':Flowable tag) =>
		target = target'
			
	be flowFinished() =>
		true

	be flowReceived(dataIso:Any iso) =>
		true
		
		
		
	
	