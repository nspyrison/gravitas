#' Check if two temporal granularities are harmonies
#'
#' @param .data A tsibble object.
#' @param gran1 One of the temporal granularities to check for harmonies.
#' @param gran2 The second temporal granularity in the pair.
#' @param hierarchy_tbl A hierarchy table specifying the hierarchy of units and their relationships
#' @param facet_h levels of facet variable for which facetting is allowed while plotting bivariate temporal granularities.
#' @param ... Added arguments to be passed
#' @return TRUE if two granularties are harmonies.
#' @examples
#' library(dplyr)
#' library(tsibbledata)
#' library(ggplot2)
#' vic_elec %>% is_harmony("hour_day", "day_week")
#' @export is_harmony

is_harmony <- function(.data, gran1, gran2, hierarchy_tbl = NULL, facet_h = NULL) {

  # data must be tsibble
  if (!tsibble::is_tsibble(.data)) {
    stop("must use tsibble")
  }



  if (gran1 == gran2) {
    warning("the two granularities should be distinct")
  }


  harmony_object <- gran_tbl(.data, gran1, gran2, hierarchy_tbl)
  names <- names(harmony_object)
  # All possible combination that are missing
  # cmbmiss <-  harmony_object %>% filter(nobs==0)
  cmbmiss <- any(harmony_object$nobs == 0)
  facet_nlevel <- harmony_object[, 1] %>% dplyr::distinct()

  if (is.null(facet_h)) {
    facet_h <- 31
  }

  if (cmbmiss == "TRUE" | nrow(facet_nlevel) > facet_h) {
    return_output <- "FALSE"
  } else {
    return_output <- "TRUE"
  }
  if (gran1 == gran2) {
    return_output <- "FALSE"
  }

  return(return_output)
}




clash_reason <- function(.data, gran1, gran2, hierarchy_tbl, response = NULL, ...) {
  gran_full <- gran_tbl(.data, gran1, gran2, hierarchy_tbl)
  if (any(gran_full$nobs == 0)) {
    clash_combination <- gran_full %>% dplyr::filter(nobs == 0) %>% dplyr::select(gran1, gran2)

    distinct_gran1 <- gran_full %>% dplyr::distinct(gran_full[[gran1]]) %>% nrow()
    distinct_gran2 <- gran_full %>% dplyr::distinct(gran_full[[gran2]]) %>% nrow()

    # inter facet homogeneity

    data_count <- gran_tbl(.data, gran1, gran2, hierarchy_tbl)

    # inter_facet_homogeneity <- gran_full %>% dplyr::group_by(gran1) %>% dplyr::summarise(min_c = min(nobs), max_c = max(nobs), variation = sd(nobs)) %>% sum = sum(dplyr::if_else(min_c == max_c, 0, 1)) %>% dplyr::mutate(value = dplyr::if_else(sum == 0, "TRUE", "FALSE"))
    #
    # # intra facet homogeneity
    # intra_facet_homogeneity <- data_count %>% dplyr::group_by(!!rlang::quo_name(gran2)) %>% dplyr::summarise(min_c = min(nobs), max_c = max(nobs)) %>% dplyr::summarise(sum = sum(dplyr::if_else(min_c == max_c, 0, 1))) %>% dplyr::mutate(value = dplyr::if_else(sum == 0, "TRUE", "FALSE"))


    return(list(paste(gran1, "has", distinct_gran1, "distinct levels and", gran2, "has", distinct_gran2, "distinct levels", "with the following structurally empty combinations. They are structurally empty as the structure of calendar does not allow these combinations to appear together."), clash_combination))
  }
  else {
    return(paste("Good Work! You have chosen harmonies. Go ahead and save the plot using your choice of distribution plot"))
  }
}