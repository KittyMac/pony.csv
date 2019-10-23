use "collections"
use "fileExt"

actor CSVStreamWriter is CSVStreamable
	"""
	Takes an array of array of strings and converts it into raw, chunked CSV content
	"""
	
	let comma:U8 = 44
	let doubleQuote:U8 = 34
	let newLine:U8 = 10
	
	let target:Streamable tag
	let env:Env
	
	new create(env':Env, target':Streamable tag) =>
		target = target'
		env = env'
			
	be stream(rowIso:Array[String] iso) =>
		env.err.print("Not Implemented")
		true
		
		
		
	
	