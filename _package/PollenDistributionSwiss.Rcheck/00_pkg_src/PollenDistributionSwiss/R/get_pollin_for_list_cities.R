#' @title Get data pollen of a given city
#'
#' @param list_cities list of cities in a string form
#' @param PATH path of the cities file
#'
#' @return A tibble with city name, canton, lat, lng, pollin level
#'
#' @name get_pollen_for_list_cities
#'
#' @description
#' Retrieve information about the pollen of given cities
#'
#' @examples
#'\dontrun{
#' tibble_test <- get_pollen_for_list_cities(c("Lugano", "Geneva"), "SwissCities.csv")
#'}
#'
#'@import utils
#' @export
#'


get_pollen_for_list_cities <- function(list_cities, PATH="SwissCities.csv") {

  swiss_cities <- readr::read_csv(PATH)
  swiss_cities_df <- tibble::tibble(swiss_cities)

  pollin_level_df <- tibble::tibble()

  for (city in list_cities) {

    # Get city info once
    city_info <- dplyr::filter(swiss_cities_df, city == !!city)

    lat <- city_info$lat
    lng <- city_info$lng
    cant <- city_info$admin_name

    # Get pollen data
    pollen_data <- get_pollen_forecast_with_cache(latitude = lat, longitude = lng)

    grs_pol <- dplyr::filter(pollen_data, plant == "Grass") |> dplyr::pull(index_value)
    tree_pol <- dplyr::filter(pollen_data, plant == "Tree") |> dplyr::pull(index_value)
    weed_pol <- dplyr::filter(pollen_data, plant == "Weed") |> dplyr::pull(index_value)

    # Create new row
    new_row <- tibble::tibble(
      city = city,
      canton = cant,
      lat = lat,
      lng = lng,
      grass_pollin = grs_pol,
      tree_pollin = tree_pol,
      weed_pollin = weed_pol
    )

    # Append to final dataframe
    pollin_level_df <- dplyr::bind_rows(pollin_level_df, new_row)
  }

  return(pollin_level_df)
}

utils::globalVariables(c("plant", "index_value"))
