# library("data.table")
# library("miniCRAN")
# library("devtools")
# library("stringr")
# library("pryr")
# library("ninjar")
#
#
#
#
#
# pkgs <- c("foreach", "codetools", "iterators", "httr", "lubridate", "stringr", "devtools", "pryr")
# ds_repo <- getOption("repos")["r.hpds.io"]
# cran_repo <- getOption("repos")["CRAN"]
# pkgList <- unique(pkgDep(pkgs, repos = cran_repo))
#
#
# dsrDT <- dsr_list()
# dsrDT[pkgList]
