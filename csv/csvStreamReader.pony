use "collections"
use "fileExt"

interface CSVStreamable	
	// new create(target:Streamable tag)
	be stream(rowIso:Array[String] iso)

actor CSVStreamReader is Streamable
	"""
	Converts chunked binary input into row-based chunks ( "line by line" results from the CSV )
	"""
	
	let state_normal:U32 = 0
	let state_quotes:U32 = 1
	let state_escapeQuotes:U32 = 2
	
	let comma:U8 = 44
	let doubleQuote:U8 = 34
	let newLine:U8 = 10
	
	let target:CSVStreamable tag
	let env:Env
	
	var currentRowPartsIso:Array[String] iso
	var rowString:String iso
	
	// lastStringSize is used to optimize new string allocations
	var lastStringSize:USize = 512
	
	
	var parseState:U32 = 0
	
	new create(env':Env, target':CSVStreamable tag) =>
		target = target'
		env = env'
		
		rowString = recover String(lastStringSize) end
		parseState = state_normal
		
		currentRowPartsIso = recover iso Array[String] end
	
	fun ref saveCurrentItem() =>
		// When we encounter a comma or newline outside of quoted space, save this item to the array
		rowString.strip()
		rowString.strip("\"")
		rowString.compact()
		lastStringSize = rowString.size()
		
		rowString = recover
			currentRowPartsIso.push(consume rowString)
			recover iso String(lastStringSize * 2) end
		end
	
	fun ref sendCurrentItems() =>
		// When we encounter a newline outside of quoted text, send off the row
		currentRowPartsIso = recover
			target.stream(consume currentRowPartsIso)
			recover iso Array[String] end
		end
	
	fun ref sendZeroItems() =>
		// When we encounter a newline outside of quoted text, send off the row
		target.stream(recover iso Array[String] end)
	
	be stream(chunkIso:Array[U8] iso) =>
		// we received chunks of data from the normal Streamable stream.  We need to:
		// 1. Continuously parse the chunks as they come in
		// 2. When we have enough data to identify one "row" of the csv, we forward that row to
		// our target (only one row at a time even if there are multiple rows in one chunk of data)
		// 3. Cache left over chunks of data for processing when the next chunk comes in (in the case of
		// one row of data is distributed between two chunks)
				
		try
			if chunkIso.size() == 0 then
				// we reached the end of the stream
				saveCurrentItem()
				sendCurrentItems()
				sendZeroItems()
			end
			
			let max = chunkIso.size()
			var i:USize = 0
			while i < max do
				let c:U8 = chunkIso(i)?
				
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
				
		
		
	
	