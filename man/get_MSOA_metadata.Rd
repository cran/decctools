% Generated by roxygen2 (4.0.1): do not edit by hand
\name{get_MSOA_metadata}
\alias{get_MSOA_metadata}
\title{Gets metadata for all MSOAs (including Scottish IGZs)}
\source{
\url{https://www.gov.uk/government/statistical-data-sets/socio-economic-data-for-mlsoa-igz-and-llsoa-electricity-and-gas-estimates}
}
\usage{
get_MSOA_metadata(dir)
}
\arguments{
\item{dir}{an (optional) directory in which to save the downloaded
data}
}
\value{
a data frame with the MSOA id code, population, area (in
hectares), and number of households
}
\description{
Gets the socio-demographic data associated with each Middle Super
Output Area (MSOA).
}

