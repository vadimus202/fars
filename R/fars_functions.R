#' Read FARS data file
#'
#' This is a simple function that, given a filename, opens the data and returns
#' it in a dataframe. Throws an error if the filename is invalid.
#'
#' The function uses imported \code{readr::read_csv()} to open the file and
#' \code{dplyr::tbl_df()} to coerce the dat into a tibble object.
#'
#' @param filename A character string giving the source file the function will
#'   read
#'
#' @return This function returns the FARS data in a tibble dataframe.
#'
#' @examples
#' library(readr)
#' my_file <- system.file("extdata", "fars_data.zip", package = "fars")
#' unzip(my_file, junkpaths = TRUE)
#' fars_read("accident_2013.csv.bz2")
#'
#' @importFrom readr read_csv
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}



#' Create a year-specific FARS data filename
#'
#' This is a helper function function that, given a year, returns a file name
#' for a FARS dataset.
#'
#' @param year an integer, or an object that can be coerced into an integer,
#'   representing the year of FARS data
#'
#' @return This function returns a character strig for a year-specific FARS
#'   dataset.
#'
#' @examples
#' my_file <- system.file("extdata", "fars_data.zip", package = "fars")
#' unzip(my_file, junkpaths = TRUE)
#' file_name <- make_filename(2013)
#' fars_read(file_name)
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}






#' Read months and years columns from FARS data
#'
#' This function, given a vector ov calendar years, returns a list of dataframes
#' containig a the month and year columns from each yearly dataset. The function
#' returns a warning if there is no data file for a given year.
#'
#' The function uses imported \code{dplyr::mutate()} and \code{dplyr::mutate()}
#' to prepare the dataframe.
#'
#' @param years a vector of integers, or objects that can be coerced into
#'   integers, representing specific years of FARS data.
#'
#' @return A list of dataframes (one list element per year). Each dataframe
#'   contains two columns: MONTH and year, and has as many rows as the source
#'   dataset
#'
#' @examples
#' my_file <- system.file("extdata", "fars_data.zip", package = "fars")
#' unzip(my_file, junkpaths = TRUE)
#' fars_read_years(2013:2015)
#'
#' @import dplyr
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select_("MONTH", "year")
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}




#' Summarize dates within FARS datsets
#'
#' Given a vector of years, this function returns a table for numbers of
#' observations within each month/year in FARS datasets.
#'
#' @param years a vector of integers, or objects that can be coerced into
#'   integers, representing specific years of FARS data.
#'
#' @return a datframe with the first column MONTH with integers 1 through 12,
#'   and a columm for each specified year. A worning is diplayed if a year does
#'   not return a valid source file.
#'
#' @seealso \code{\link{fars_read_years}}
#'
#' @import dplyr
#' @importFrom tidyr spread
#'
#' @examples
#' my_file <- system.file("extdata", "fars_data.zip", package = "fars")
#' unzip(my_file, junkpaths = TRUE)
#' fars_summarize_years(2013:2015)
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by_("year", "MONTH") %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread_("year", "n")
}

#' Plot accidents on a state map.
#'
#' This function takes a state number and year as its argumants, and returns a
#' map of all all accidents in that state and year. The function requres FARS
#' raw datsets saved in \code{getwd()}.
#'
#' An invalid state number throws an error. If no accides found in that state,
#' the function returns \code{NULL} silently. The function uses imported
#' \code{maps::map()} tp plot the data.
#'
#' @param state.num an integer, or an object that can be coerced into integer,
#'   representing a state number
#' @param year an integer, or an object that can be coerced into integer,
#'   representing a calendar year
#'
#' @return a plot of a state accidents map
#'
#' @export
#'
#' @import dplyr
#' @importFrom maps map
#'
#' @examples
#' my_file <- system.file("extdata", "fars_data.zip", package = "fars")
#' unzip(my_file, junkpaths = TRUE)
#' fars_map_state(16, 2015)
#'
#'
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter_(data, "STATE" == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
