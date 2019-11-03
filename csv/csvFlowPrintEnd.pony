use "collections"
use "fileExt"
use "flow"

actor CSVFlowPrintEnd is Flowable
	"""
	Simple print CSV arrays to the console; useful for debugging
	"""
	
	let env:Env
	
	new create(env':Env) =>
		env = env'
	
	be flowFinished() =>
		true
	
	be flowReceived(dataIso:Any iso) =>
		let data:Any ref = consume dataIso
		try
			let row = data as Array[String] ref
			env.out.print(",".join(row.values()))
			env.out.print("-------------------------------")
		end