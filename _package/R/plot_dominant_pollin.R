#' @title Plot the Pollins in the Swiss Map
#'
#' @param polline_df pollin df
#' @param PATH path for the folder
#'
#' @return plot of most prominent pollin on the swiss map
#'
#' @description Plots the distribution of the pollines across the cities given
#'
#' @examples
#' \dontrun{
#' city_df <- get_pollen_for_list_cities(c("Geneva", "Lugano"))
#' plot_most_canton(city_df)}
#'
#'@import httr
#'@import jsonlite
#'@import knitr
#'@name plot_most_canton
#'
#' @export

plot_most_canton <- function(polline_df, PATH='2025_GEOM_TK') {
  world_path = paste0(PATH, '/01_INST/Gesamtflaaeche_gf/K4_kant20220101_gf/K4kant20220101gf_ch2007Poly.shp')
  l_path = paste0(PATH, '/00_TOPO/K4_seenyyyymmdd/k4seenyyyymmdd11_ch2007Poly.shp' )

  world <- sf::read_sf(world_path)
  l1    <- sf::st_read(l_path)
  l2    <- sf::st_read(l_path)

  dominant_polline_df <- polline_df |>
    tidyr::pivot_longer(cols = dplyr::ends_with("_pollin"), names_to = "type", values_to = "val") |>
    dplyr::mutate(type = gsub("_pollin", "", type)) |>
    dplyr::group_by(canton, type) |>
    dplyr::summarise(mean_val = mean(val), .groups = "drop") |>
    dplyr::group_by(canton) |>
    dplyr::slice_max(mean_val, n = 1, with_ties = FALSE)

  world_colored <- dplyr::left_join(world, dominant_polline_df, by = c("name" = "canton"))

  centroids <- world_colored |>
    dplyr::filter(!is.na(type)) |>
    sf::st_centroid()

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = world, fill = "grey90", color = "black", linewidth = 0.3) +
    ggplot2::geom_sf(data = dplyr::filter(world_colored, !is.na(type)),
                     ggplot2::aes(fill = type), color = "black", linewidth = 0.3) +
    ggplot2::geom_sf(data = l1, fill = "lightblue", color = NA) +
    ggplot2::geom_sf(data = l2, fill = "lightblue", color = NA) +
    ggplot2::geom_sf_label(data = centroids, ggplot2::aes(label = name),
                           size = 3, fill = "white", alpha = 0.7, label.size = 0.2) +
    ggplot2::scale_fill_manual(
      values = c(grass = "#66c2a5", tree = "#fc8d62", weed = "#8da0cb"),
      name = "Dominant pollen type"
    ) +
    ggplot2::labs(title = "Dominant pollen type by canton") +
    ggplot2::theme_minimal()
}

utils::globalVariables(c("type", "canton", "val", "mean_val", "name", "plant", "pollen_level_df"))

