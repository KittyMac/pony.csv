use "fileExt"
use "ponytest"

use @sleep[I32](seconds: I32)

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestSimpleCSV)
		test(_TestComplexCSV)


class iso _TestSimpleCSV is UnitTest
	fun name(): String => "simple csv"

	fun apply(h: TestHelper) =>
		// Using a low chunk size to test the wrapping of the CSV reader
		FileExtStreamReader(h.env, "simple.csv", 3,
			CSVStreamReader(h.env, CSVStreamPrintEnd(h.env))
		)

class iso _TestComplexCSV is UnitTest
	fun name(): String => "complex csv"

	fun apply(h: TestHelper) =>
		@sleep(3)
		// Using a low chunk size to test the wrapping of the CSV reader
		FileExtStreamReader(h.env, "complex.csv", 7,
			CSVStreamReader(h.env, CSVStreamPrintEnd(h.env))
		)
