#' CRAN Repo Functions
#'
#' Functions that interact with cran
#'
#' @param pkg_name character of package names
#'
#' @import data.table
#' @importFrom stringr str_split
#' @importFrom utils available.packages
#'
#' @name cran_repo
NULL

#' @describeIn cran_repo list packages and version numbers. Returns data.table sorted by package, version
#' @export
cran_list <- function(){
  avail_pkg <- available.packages()
  avail_pkg_names <- row.names(avail_pkg)
  avail_pkg_DT <- as.data.table(avail_pkg)
  DT <- avail_pkg_DT[, .(Package, Version)]

  #order by major, minor, ...
  verDT <- cbind(DT, data.table(str_split(DT$Version, "\\.|\\-", simplify = TRUE)))
  vcol_names <- paste0("V", 1:(ncol(verDT)-2))
  setorderv(verDT, vcol_names, order = -1)
  setkeyv(verDT, c("Package", vcol_names))
  return(verDT)
}


#' @describeIn cran_repo boolean. True if package exists in CRAN
#' @export
cran_pkg_exists <- function(pkg_name = NULL){
  chk_dat <- cran_list()[pkg_name][!is.na(Version)]
  if(nrow(chk_dat)==0)
    return(FALSE)
  return(TRUE)
}

#' @describeIn cran_repo similar to \code{cran_list} except returns NULL if package does not exist, otherwise
#'    returns the subset of full data returned by \code{cran_list}
#' @export
cran_get_version <- function(pkg_name = NULL){
  if(!cran_pkg_exists(pkg_name))
    return(NULL)
  cran_list()[pkg_name]
}

#' @describeIn cran_repo if package does not exist in dsr, returns NULL. Otherwise FALSE if does not need updating, and TRUE
#'     if dsr version is different then CRANs. Will print the respective version numbers to console before returning TRUE.
#' @export
cran_update_check <- function(pkg_name = NULL){
  if(!dsr_pkg_exists(pkg_name))
    return(NULL)

  if(!cran_pkg_exists(pkg_name))
    stop("package not available on cran")

  a <- dsr_list()[pkg_name, .(Package, Version)][1, Version]
  b <- cran_list()[pkg_name, .(Package, Version)][1, Version]
  if(identical(a, b))
    return(FALSE)
  print(paste0("Repo version: ", a))
  print(paste0("CRAN version: ", b))
  return(TRUE)
}
