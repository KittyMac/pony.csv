# pony.csv

A simple streaming CSV (comma separated values) reader and writer for Pony.

Utilizes the Streamable type available in the [pony.fileExt](https://github.com/KittyMac/pony.fileExt) library.

```
// Use a file streamer to pipe the content through the CSV reader and 
// then through the CSV printer to see it in the console
FileExtStreamReader(h.env, "simple.csv", 4,
	CSVStreamReader(h.env, CSVStreamPrintEnd(h.env))
)
```
