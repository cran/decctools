# decctools

decctools is an R package that provides easy access to energy
statistics from the United Kingdom Department of Energy and Climate
Change.  It currently provides access to two major data sources:
	
  * sub-national final energy consumption data at the local authority,
    middle super output area (MSOA), and lower super output area
    (LSOA) scales
	
  * fuel mix data and the associated carbon intensity of grid
    electricity using Elexon balancing mechanism data

You must have [Curl](http://curl.haxx.se/) installed to use this
package.

## Sub-national statistics

Sub-national energy statistics are available at three different
geographies: Local Authority Districts (LADs), Middle Super Output
Areas (MSOAs), and Lower Super Output Areas (LSOAs).  For each
geography, the following functions are available where `*` corresponds
to the correct level (LAD, MSOA, or LSOA).

 * `get_*_data(year, sector, fuel, id, dir)` gets the energy demand
   data for the geography.  See `?get_*_data` for full detail on the
   options and note that not all geographies provide the same level of
   data.  For example at the LSOA level, data are only available for
   domestic electricity and gas in England and Wales.

   Here's an example:
 
   ```
   ## Gets energy data for electricity and gas use in the domestic sector in the most recent year
   df <- get_LAD_data(sector="domestic", fuel=c("electricity", "gas"))
   ```

   You may encounter `OutOfMemoryError (Java)` when loading LSOA data.
   In this case, close R, open a new session, and type
   `options(java.parameters = "-Xmx1000m")` _before_ loading
   decctools.  This increases the maximum amount of memory allowed for
   Java so you may need to change the 1000 value to match the
   available memory on your machine.
   
 * `get_*_years` gets a numeric vector of years for which data are
   available at the specified geography.
   
 * `get_*_metadata(dir)` gets a table of metadata about the geography
   in question.  If given, the `dir` option allows you to save a copy
   of the table to a local directory.
	
The package provides a lookup table to match LAD, MSOA, and LSOA id
codes; this is accessible via `get_geo_lookup`.  Owing to the frequent
changes in UK geography in recent years, it is advisable to merge LAD
data on the `name` field.  

You can also check if a given LAD is urban or rural by using
`is_urban(LAD, urban)` where `urban` is a set of codes defining which
ONS urban classifications you would like to consider as urban.

## Grid carbon intensity

Elexon's [BM Reports](http://www.bmreports.com/bsp/bsp_home.htm)
provides data on the UK's electricity market including the amount of
electricity generated by different fuel types in each half-hourly
period of the day.  Historic data (back to 2009-01-01) has been
archived by the charity
[Renewable Energy Foundation](http://www.ref.org.uk/fuel/) and
decctools uses their summaries to provide the data used here.

There are two methods of interest:

  * `get_grid_mix(start, end)` gets the amount of electricity
    generated by different sources at half-hourly intervals between
    two specified Dates
  
  * `get_grid_carbon(start, end)` gets the carbon intensity of grid
    electricity (kg CO2/kWh) between two specified Dates
  
An example:

    get_grid_carbon('2013-05-01', '2013-05-31')
