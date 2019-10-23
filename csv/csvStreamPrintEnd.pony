use "collections"
use "fileExt"

actor CSVStreamPrintEnd is CSVStreamable
	"""
	Simple print CSV arrays to the console; useful for debugging
	"""
	
	let env:Env
	
	new create(env':Env) =>
		env = env'
			
	be stream(rowIso:Array[String] iso) =>
		let row:Array[String] ref = recover ref consume rowIso end
		env.out.print(",".join(row.values()))
		env.out.print("-------------------------------")