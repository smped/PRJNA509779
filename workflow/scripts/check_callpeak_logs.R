#' This script checks the macs2 callpeak logs for any failures that may
#' have occured without any errors being thrown. 
#' If not enough allocation has been assigned to tmpdir, this may occur

args <- commandArgs(TRUE)
input <- here::here(args[[1]])
output <- here::here(args[[2]])

lines <- readLines(input)
any_err <- any(grepl("Exception", lines))
if (any_err) {
	msg <- paste0(
		"Exception found in ", input, "\n",
		"Please ensure you have enough space in your tmpdir"
	)
	stop(msg)
}
file.create(output)