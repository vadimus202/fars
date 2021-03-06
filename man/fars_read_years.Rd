% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{fars_read_years}
\alias{fars_read_years}
\title{Read months and years columns from FARS data}
\usage{
fars_read_years(years)
}
\arguments{
\item{years}{a vector of integers, or objects that can be coerced into
integers, representing specific years of FARS data.}
}
\value{
A list of dataframes (one list element per year). Each dataframe
  contains two columns: MONTH and year, and has as many rows as the source
  dataset
}
\description{
This function, given a vector ov calendar years, returns a list of dataframes
containig a the month and year columns from each yearly dataset. The function
returns a warning if there is no data file for a given year.
}
\details{
The function uses imported \code{dplyr::mutate()} and \code{dplyr::mutate()}
to prepare the dataframe.
}
\examples{
my_file <- system.file("extdata", "fars_data.zip", package = "fars")
unzip(my_file, junkpaths = TRUE)
fars_read_years(2013:2015)

}
