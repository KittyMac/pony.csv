use "fileExt"
use "ponytest"
use "files"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestSimpleCSV)
		test(_TestComplexCSV)
	
 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponyminthreads = 2
		rto.ponynoblock = true
		rto.ponygcinitial = 0
		rto.ponygcfactor = 1.0


class iso _TestSimpleCSV is UnitTest
	fun name(): String => "simple csv"

	fun apply(h: TestHelper) =>
		// Using a low chunk size to test the wrapping of the CSV reader
		var inFilePath = "simple.csv"
		FileExtFlowReader(inFilePath, 3,
			CSVFlowReader(CSVFlowPrintEnd(h.env))
		)

class iso _TestComplexCSV is UnitTest
  
	fun name(): String => "complex csv"
    
	fun ref apply(h: TestHelper) =>
    h.long_test(30_000_000_000)
    
    let callback = object val is FlowFinished
      fun flowFinished() =>
        try
          let a = FileExt.fileToString("complex.csv")?.>strip()
          let b = FileExt.fileToString("/tmp/complex.csv")?.>strip()
                    
          h.complete(a == b)
        else
          h.complete(false)
        end
    end
    
		// Read in complex CSV file, deserialize it, serialize it, 
    // write it out, then compare for accuracy
		var inFilePath = "complex.csv"
		FileExtFlowReader(inFilePath, 7,
			CSVFlowReader(
        CSVFlowWriter(
          FileExtFlowWriter("/tmp/complex.csv",
            FileExtFlowFinished(callback,
              FileExtFlowEnd
            )
          )
        )
      )
		)
