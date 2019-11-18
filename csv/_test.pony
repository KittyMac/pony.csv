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

	fun apply(h: TestHelper) =>
		// Using a low chunk size to test the wrapping of the CSV reader
		var inFilePath = "complex.csv"
		FileExtFlowReader(inFilePath, 7,
			CSVFlowReader(CSVFlowPrintEnd(h.env))
		)
