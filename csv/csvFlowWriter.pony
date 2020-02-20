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
		
	fun _tag():USize => 104
	
	new create(target':Flowable tag) =>
		target = target'
			
  	be flowFinished() =>
  		target.flowFinished()

	be flowReceived(dataIso:Any iso) =>
    // We expect to receive Array[String], which we convert to String and pass along    
    // We consume and hard convert as we don't need to pass it along in this form anymore
    let data:Any ref = consume dataIso
    
    try
      let row = data as Array[String] ref
      var composite:String iso = recover String(1024) end
      
      for item in row.values() do
        composite.push(doubleQuote)
        for c in item.values() do
          if c == doubleQuote then
            composite.push(doubleQuote)
          end
          composite.push(c)
        end
        composite.push(doubleQuote)
        composite.push(comma)
      end
      try composite.pop()? end
      composite.push(newLine)
      
      target.flowReceived(consume composite)
    end
    
		
		
		
	
	