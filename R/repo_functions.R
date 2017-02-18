#' Data Science Repo Functions
#'
#' Functions that interact with dsr (repo). Note that these are local functions only, and will run on the R machine
#' that hosts the repo.
#'
#' @param pkg_name character of package names
#'
#' @import data.table
#' @import miniCRAN addPackage updateRepoIndex
#' @importFrom stringr str_replace str_split_fixed str_split str_extract
#' @importFrom ninjar print_stamp
#'
#' @name dsr_repo
NULL


#' @describeIn dsr_repo list packages and version numbers. Returns data.table sorted by package, version
#' @export
dsr_list <- function(){
  src_path <- path.expand("~/dsrepo/src/contrib")

  clean_src_names <- str_replace(list.files(src_path), "\\.tar\\.gz", "")
  pkg_table <- as.data.table(str_split_fixed(clean_src_names, "_", 2))
  setnames(pkg_table, c("Package", "Version"))
  setkeyv(pkg_table, "Package")

  #order by major, minor, ...
  verDT <- cbind(pkg_table, data.table(str_split(pkg_table$Version, "\\.|\\-", simplify = TRUE)))
  vcol_names <- paste0("V", 1:(ncol(verDT)-2))
  setorderv(verDT, vcol_names, order = -1)
  setkeyv(verDT, c("Package", vcol_names))
  return(verDT)
}

#' @describeIn dsr_repo boolean. True if package exists in dsr
#' @export
dsr_pkg_exists <- function(pkg_name = NULL){
  chk_dat <- dsr_list()[pkg_name][!is.na(Version)]

  if(nrow(chk_dat)==0)
    return(FALSE)
  return(TRUE)
}

#' @describeIn dsr_repo similar to \code{dsr_list} except returns NULL if package does not exist, otherwise
#'    returns the subset of full data returned by \code{dsr_list}
#' @export
dsr_get_version <- function(pkg_name = NULL){
  if(!dsr_pkg_exists(pkg_name))
    return(NULL)
  dsr_list()[pkg_name]
}




#' @describeIn dsr_repo lists the bin files found in repo
#' @export
dsr_bin_files <- function(pkg_name = NULL){
  r_version <- str_extract(paste0(R.Version()$major, ".", R.Version()$minor), ".\\..")
  list.files(paste0(path.expand("~/dsrepo/bin/windows/contrib/"), r_version),
             pattern = pkg_name,
             full.names = TRUE)
}

#' @describeIn dsr_repo lists the source files found in repo
#' @export
dsr_src_files <- function(pkg_name = NULL){
  list.files(path.expand("~/dsrepo/src/contrib"),
             pattern = pkg_name,
             full.names = TRUE)
}

#' @describeIn dsr_repo the internal function to add the source and bin package files to the repo
#' @export
dsr_internal_add <- function(pkg_name){
  addPackage(pkg_name,
             path = path.expand("~/dsrepo/"),
             type=c("source", "win.binary"),
             Rversion = r_version,
             writePACKAGES = TRUE,
             deps = TRUE,
             quiet = FALSE)
}

#' @describeIn dsr_repo the internal function to remove the source and bin package files from the repo
#' @export
dsr_internal_rm <- function(pkg_name){
  for(pk in pkg_name){
    file.remove(dsr_bin_files(pk))
    file.remove(dsr_src_files(pk))
  }
  return(TRUE)
}

#' @describeIn dsr_repo internal function to update the package index of the repo
#' @export
dsr_update_index <- function(){
  updateRepoIndex(path.expand("~/dsrepo/"),
                  type=c("source", "win.binary"),
                  Rversion=R.version)
}

#' @describeIn dsr_repo user-facing function that adds packages to repo. This will run checks and update if necessary
#' @export
dsr_add <- function(pkg_name){
  UPDATE <- FALSE

  pkg_chk <- dsr_list()[pkg_name][!is.na(Version), Package]
  pkg_install <- pkg_name[!pkg_name %in% pkg_chk]

  if(length(pkg_install) > 0){

    ## check if available on cran:
    cran_DT <- cran_list()
    install_these <- pkg_install[pkg_install %in% cran_DT[pkg_install][!is.na(Version), Package]]
    not_found <- pkg_install[!pkg_install %in% install_these]

    if(length(not_found) > 0){
      ninjar::print_stamp("Packages not on cran")
      print(not_found)
    }

    if(length(install_these) > 0){
      ninjar::print_stamp("Installing packages")
      dsr_internal_add(pkg_install)

      UPDATE <- TRUE
      ninjar::print_stamp("Finished Installing")
    }
  }else{
    ninjar::print_stamp("No new packages to add")
  }

  if(length(pkg_chk) > 0){
    ninjar::print_stamp("Checking for latest")

    pkg_update <- pkg_chk[sapply(pkg_chk, cran_update_check)]

    if(length(pkg_update) > 0){

      ninjar::print_stamp("Updating packages")

      dsr_internal_rm(pkg_update)
      dsr_internal_add(pkg_update)

      UPDATE <- TRUE
      ninjar::print_stamp("Update Done")

    }else{
      ninjar::print_stamp("No packages to update")
    }
  }
  if(UPDATE){
    ninjar::print_stamp("Updating index")
    dsr_update_index()
  }
  return(UPDATE)
}

