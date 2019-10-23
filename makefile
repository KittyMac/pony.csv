all:
	stable env ponyc -o ./build/ ./csv
	./build/csv
