% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{make_filename}
\alias{make_filename}
\title{Create a year-specific FARS data filename}
\usage{
make_filename(year)
}
\arguments{
\item{year}{an integer, or an object that can be coerced into an integer,
representing the year of FARS data}
}
\value{
This function returns a character strig for a year-specific FARS
  dataset.
}
\description{
This is a helper function function that, given a year, returns a file name
for a FARS dataset.
}
\examples{
my_file <- system.file("extdata", "fars_data.zip", package = "fars")
unzip(my_file, junkpaths = TRUE)
file_name <- make_filename(2013)
fars_read(file_name)

}
