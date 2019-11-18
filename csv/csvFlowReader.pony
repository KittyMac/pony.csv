use "collections"
use "fileExt"
use "flow"

interface CPointerApply
	fun apply(i: USize): U8 ?
	fun cpointer(offset: USize = 0): Pointer[U8] tag
	fun size(): USize

actor CSVFlowReader is Flowable
	"""
	Converts chunked binary input into row-based chunks ( "line by line" results from the CSV )
	"""
	
	let state_normal:U32 = 0
	let state_quotes:U32 = 1
	let state_escapeQuotes:U32 = 2
	
	let comma:U8 = 44
	let doubleQuote:U8 = 34
	let newLine:U8 = 10
	
	let target:Flowable tag
	
	var currentRowPartsIso:Array[String] iso
	var rowString:String iso
		
	var parseState:U32 = 0
	
	fun _batch():USize => 4
	fun _tag():USize => 103
	
	new create(target':Flowable tag) =>
		target = target'
		
		rowString = recover String(1024 * 1024 * 16) end
		parseState = state_normal
		
		currentRowPartsIso = recover iso Array[String](32) end
	
	fun ref saveCurrentItem() =>
		// When we encounter a comma or newline outside of quoted space, save this item to the array
		rowString.strip()
		rowString.strip("\"")
		
		let rowCopy = rowString.clone()
		currentRowPartsIso.push(consume rowCopy)
		rowString.clear()
	
	fun ref sendCurrentItems() =>
		// When we encounter a newline outside of quoted text, send off the row
		currentRowPartsIso = recover
			target.flowReceived(consume currentRowPartsIso)
			recover iso Array[String](32) end
		end
		
	be flowFinished() =>
		saveCurrentItem()
		sendCurrentItems()
		target.flowFinished()

	be flowReceived(dataIso:Any iso) =>	
		let data:Any ref = consume dataIso
		
		try
			let chunk = data as CPointerApply ref
		
			// we received chunks of data from the normal Flowable stream.  We need to:
			// 1. Continuously parse the chunks as they come in
			// 2. When we have enough data to identify one "row" of the csv, we forward that row to
			// our target (only one row at a time even if there are multiple rows in one chunk of data)
			// 3. Cache left over chunks of data for processing when the next chunk comes in (in the case of
			// one row of data is distributed between two chunks)
				
			try
				let max = chunk.size()
				var i:USize = 0
				while i < max do
					let c:U8 = chunk(i)?
				
					if parseState == state_normal then
						i = i + 1
					
						// watch for comma and new lines.
						if (c == comma) or (c == newLine) then
							saveCurrentItem()
							if c == newLine then
								sendCurrentItems()
							end
						elseif c == doubleQuote then
							rowString.push(c)
							parseState = state_quotes
						else
							rowString.push(c)
						end
				
				
					elseif parseState == state_quotes then
						// we're inside quoted material.
						i = i + 1
					
						rowString.push(c)
					
						if c == doubleQuote then
							parseState = state_escapeQuotes
						end
				
				
					elseif parseState == state_escapeQuotes then
						// the last character was a quote, we need to check if this character is a quote or not				
						if c != doubleQuote then
							parseState = state_normal
						else
							parseState = state_quotes
							i = i + 1
						end
					end
				
				end
			end
		else
			@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "CSVFlowReader requires a CPointerApply flowable\n".cstring())
		end
		
		
	
	