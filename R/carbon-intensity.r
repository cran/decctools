#' Gets mix of fuel sources in UK electricity
#'
#' Gets the mix of fuel sources used to generate UK grid electricity between specified dates.  Valid dates are yyyy-mm-dd and must be between 2009-01-01 and the current day; the start must come before the end date.
#'
#' @source The underlying data come from BM Reports, \url{http://www.bmreports.com/bsp/bsp_home.htm}, and are used under license from Elexon (see disclaimer below). However the BM Reports website is hard to use and so this function uses archived Elexon data compiled by the charity Renewable Energy Foundation and available at no cost at \url{http://www.ref.org.uk/fuel/}.
#' ELEXON does not and shall not be deemed to warrant or guarantee or make any representation (whether expressly or impliedly) as to the title, completeness, accuracy, reliability, freeness from error, method of preparation, merchantability or fitness for the purpose or for any particular purpose (whether or not any such purpose has been notified to ELEXON) of the Licensed Data and/or any use of or dealing with it.  ELEXON shall have no liability or responsibility whatsoever or howsoever arising (whether directly or indirectly) as a result of or in connection therewith, including in respect of each and all loss of profits, loss of revenue, loss of goodwill, loss of contracts, loss of business or production, indirect loss, economic or consequential loss, claims, demands, proceedings, actions, losses, liabilities, damages, costs, charges and expenses (whether or not any of the foregoing are foreseeable)
#'
#' @param start the start date for retrieving data.
#' @param end the end date for retrieving data
#' @return a data frame with a datetime stamp and average power generated by fuel type in MW
#' @examples
#' # These require a working internet connection
#' start <- "2010-01-01"
#' end <- "2010-01-07"
#' library(RCurl)
#' if (url.exists("http://www.google.com")) {
#'   data <- get_grid_mix(start, end) # Gets data for 1st week of January 2010
#' }
#' @export
#' @import stringr XML
get_grid_mix <- function(start, end) {

  ## Coerce strings to proper dates
  start <- as.Date(start)
  end <- as.Date(end)
    
  ## Validate inputs
  first_date <- as.Date("2009-01-01")
  last_date <- get_last_date()
  template <- "Invalid %s date.  Must be between %s and %s."
  if (start < as.Date("2009-01-01") | start > last_date) {
    stop(sprintf(template, "start", first_date, last_date))
  }

  if (end < as.Date("2009-01-01") | start > last_date) {
    stop(sprintf(template, "end", first_date, last_date))
  }

  if (end < start) stop("End date before start date.  Try again.")

  ## Create a sequence of dates
  dates <- seq(start, end, by="day")

  ## Load the data from the REF website
  tmp <- list(length(dates))
  columns <- c("character","numeric", rep("FormattedNumber", 14))
  base_url <- "http://www.ref.org.uk/fuel/tablebysp.php?valdate="
  for (i in 1:length(dates)) {
    url <- paste(base_url, dates[i], sep="")
    table <- suppressWarnings(readHTMLTable(url, colClasses=columns)[[2]])
    tmp[[i]] <- table
  }
  data <- do.call("rbind", tmp)

  ## Tidy things up
  names(data) <- str_trim(names(data))

  ## Convert date format into something more sensible
  data <- mutate(data, datetime=as.POSIXct((data$SP-1)*30*60, origin=data$SD))

  ## Rearrange
  data <- data[,c(17, 3:15)]
  return(data)
}


#' Calculates the carbon intensity of electricity generation
#'
#' Calculates the carbon intensity of electricity generation in the UK between specified dates.
#'
#' @seealso \code{\link{get_grid_mix}} and \code{\link{carbon_intensities}} for data sources
#' @param start the start date for retrieving data.
#' @param end the end date for retrieving data
#' @return a data frame with a datetime stamp and average carbon intensity of electricity measured in kg CO2/kWh
#' @examples
#' # These require a working internet connection
#' start <- "2010-01-01"
#' end <- "2010-01-07"
#' library(RCurl)
#' if (url.exists("http://www.google.com")) {
#'   carbon <- get_grid_carbon(start, end) # Gets grid carbon for 1st week of January 2010
#' }
#' @export
#' @import reshape2
get_grid_carbon <- function(start, end) {

  ## Get the grid mix data for this period
  data <- get_grid_mix(start, end)

  ## Merge with carbon intensities data for each fuel type
  data.m <- melt(data, id="datetime")
  data.m <- merge(data.m, carbon_intensities, by.x="variable", by.y="fuel")

  ## Calculate the total emissions in kg CO2
  ## cif = g CO2/kWh so value must be converted from MW in a half-hour period to kWh
  tmp <- mutate(data.m, emissions=(data.m$value*0.5)*1000*data.m$cif/1000)

  ## Now sum back up for a single time period
  tmp2 <- ddply(tmp, c("datetime"), summarize, demand=sum(get("value")*0.5*1000), total_em=sum(get("emissions")))
  result <- summarize(tmp2, datetime=tmp2$datetime, cif=tmp2$total_em/tmp2$demand)
  return(result)
}
  

#' Gets the most recent date for available data
#'
#' Gets the date of the last update to the REF fuels mix database.
#'
#' @return a Date object
get_last_date <- function() {
  
  base_url <- "http://www.ref.org.uk/fuel/tablebysp.php"
  columns <- c("character","numeric", rep("FormattedNumber", 14)) 
  table <- suppressWarnings(readHTMLTable(base_url, colClasses=columns)[[2]])
  last_date <- as.Date(as.character(tail(table$SD, 1)))
  return(last_date)
}
                       
  
