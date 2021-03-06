% Generated by roxygen2 (4.0.1): do not edit by hand
\name{get_SOA_data}
\alias{get_SOA_data}
\title{Get SOA energy consumption data}
\usage{
get_SOA_data(level, year = max(get_SOA_years()), sector = c("domestic",
  "nondomestic"), fuel = c("electricity", "gas"), id, dir)
}
\arguments{
\item{level}{either "LSOA" or "MSOA"}

\item{year}{the year for which you want data.  Defaults to the
most recent year available.}

\item{sector}{the economic sector to fetch.  Valid values are
'domestic', 'nondomestic'}

\item{fuel}{the fuel type to fetch.  Valid values are
'electricity', 'gas'}

\item{id}{the unique id of the SOA to fetch.  If not specified,
then all SOAs are retrieved.}

\item{dir}{an optional directory in which to save a copy of the
data}
}
\value{
a long data frame with the requested data.  The 'energy'
column is measured in GWh.
}
\description{
Gets SOA (Super Output Area) energy consumption data from the DECC
website.  You can select which SOA level, sector, year, and fuel
type to fetch, as well as specifying a directory for local
caching.
}
\keyword{data}
\keyword{energy}

