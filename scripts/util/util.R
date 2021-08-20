### USEFUL FUNCTONS ###########################################################

# get filenames in a given directory ------------------------------------------

getFilenames <- function(outputPath, pattern){
	filenames <- dir(
		path = outputPath,
		# match all files with given pattern
		pattern = pattern,
		# return only names of visible files
		all.files = FALSE,
		# return only file names, not relative file paths
		full.names = FALSE,
		# assume all are in given directory, not in any subdirectories
		recursive =	FALSE,
		ignore.case =TRUE
	);
	return(filenames);
}