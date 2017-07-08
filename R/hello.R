# library("miniCRAN")
# library("devtools")
# library("stringr")
#
# Sys.setenv(R_KEEP_PKG_SOURCE = "yes")
# Sys.setenv(GITHUB_PAT = "f287eb8fae0c76854c44f7aa3c7b6ed87d71cc4c")
# Sys.getenv("GITHUB_PAT")
# getOption("GITHUB_PAT")
#
# r_version <- str_extract(paste0(R.Version()$major, ".", R.Version()$minor), ".\\..")
# src_path <- path.expand("~/dsrepo/src/contrib")
# bin_path <- path.expand("~/dsrepo/bin/windows/contrib/", r_version, "/")
#
#
#
# repo <- getOption("repos")["r.hpds.io"]
# pkgs <- c("foreach", "codetools", "iterators", "httr", "lubridate", "stringr", "devtools", "pryr")
#
#
# list.files(src_path)
# # dir.create(rpath)
#
#
# # Specify list of packages to download and make repo
# # init_pkgs <- "data.table"
# # pkgList <- pkgDep(init_pkgs, repos = getOption("repos"))
# # makeRepo(pkgList, path=rpath, type=c("source", "win.binary"))
# cranURI <- paste("file://", normalizePath(rpath, winslash = "/"), sep = "")
# options(repos = c(getOption("repos"), r.hpds.io = cranURI))
#
#
# # Add to repo
# add_packs <- c()
# pkgList <- pkgDep(add_packs, repos = getOption("repos"))
#
# ## first remove older versions
# old_files <- get_old_names(pkgList, rpath)
#
#
# if(!is.null(old_files$remove)){
#   lapply(old_files$remove, file.remove)
#   rVersion <- paste(unlist(getRversion())[1:2], collapse = ".")
#   updateRepoIndex(rpath, type=c("source", "win.binary"), Rversion=R.version)
# }
#
# NoInstall <- unique(c(old_files$no_inst_bin, old_files$no_inst_src))
#
# new_pkgs <- pkgList[!pkgList %in% NoInstall]
#
# if(length(new_pkgs) > 0){
#   addPackage(new_pkgs, path=rpath, type=c("source", "win.binary"), writePACKAGES = TRUE)
# }else{
#   message("No new package versions found. Not added to repo")
# }
# return(pkgAvail())
#
#
#
#
#
#
#
# get_old_names <- function(pkgs = pkgList, path = rpath){
#   pkgVersionsSrc <- checkVersions(pkgs, path=path, type="source")
#   pkgVersionsBin <- checkVersions(pkgs, path=path, type="win.binary")
#
#   # After inspecting package versions, remove old versions
#
#   ## Source first
#   keepSrc <- basename(pkgVersionsSrc)
#   srcDT <- rbindlist(lapply(stringr::str_split(keepSrc, "_"), pryr::f(i, {
#     pkg_name <- i[[1]]
#     data.table(
#       pkg_name,
#       version = unlist(stringr::str_extract_all(i, ".+(?=\\.tar)")),
#       full_name = paste0(i, collapse = "_")
#     )
#   })))
#   src_noinst_ind <- srcDT[, pkg_name %in% srcDT[, .N, pkg_name][N == 1, pkg_name]]
#   src_old_remove <- srcDT$full_name[srcDT[, version != max(version), pkg_name]$V1]
#
#   ## bin
#   keepBin <- basename(pkgVersionsBin)
#   binDT <- rbindlist(lapply(stringr::str_split(keepBin, "_"), pryr::f(i, {
#     pkg_name <- i[[1]]
#     data.table(
#       pkg_name,
#       version = unlist(stringr::str_extract_all(i, ".+(?=\\.zip)")),
#       full_name = paste0(i, collapse = "_")
#     )
#   })))
#   bin_noinst_ind <- binDT[, pkg_name %in% binDT[, .N, pkg_name][N == 1, pkg_name]]
#   bin_old_remove <- binDT$full_name[binDT[, version != max(version), pkg_name]$V1]
#
#   all_old <- c(src_old_remove, bin_old_remove)
#
#   noInstall <- list(no_inst_bin = binDT[bin_noinst_ind]$pkg_name,
#                     no_inst_src = srcDT[src_noinst_ind]$pkg_name)
#   if(length(all_old) > 0){
#     return(c(noInstall, list(remove = paste0(path, "src/contrib/", all_old))))
#   }
#   return(c(noInstall, list(remove = NULL)))
# }
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# oldVers <- data.frame(package=c("foreach", "codetools", "iterators"),
#                       version=c("1.4.0", "0.2-7", "1.0.5"),
#                       stringsAsFactors=FALSE)
# pkgs <- oldVers$package
# addOldPackage(pkgs, path=rpath, vers=oldVers$version, type="source")
