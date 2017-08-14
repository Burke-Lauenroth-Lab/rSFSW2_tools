#!/usr/bin/env Rscript
dir_prev <- getwd()

writeLines(c("", "",
  "##############################################################################",
  paste("#------ rSFSW2_tools-TEST-PROJECTS started at", Sys.time()),
  "##############################################################################", ""))


#---Command line input for non-interactive use
if (!interactive()) {
  script_args <- commandArgs(trailingOnly = TRUE)

  if (any("--help" == script_args) || "-h" == script_args) {
    cat("Options:\n")
    cat("    '--help' or '-h': cat these explanations\n")
    cat("    '--path' or '-p': -p=path to folder of test projects 'Test_projects'\n")
    cat("    '--new_ref' or '-r': add output DB as new reference if successful\n")
    cat("    '--force-delete' or '-D': force delete test output; implies '-d'\n")
    cat("    '--delete' or '-d': delete test output if successful\n")
    cat("    '--tests' or '-t': -t=all runs all available test projects;\n")
    cat("                       -t=1,2 runs test projects 1 and 2 (separated by comma)\n")

    stop("End of help")
  }

  temp <- grepl("--path", script_args) | grepl("-p", script_args)
  path <- if (any(temp)) strsplit(script_args[temp][1], "=")[[1]][2] else dir_prev

  make_new_ref <- any("--new_ref" == script_args) || any("-r" == script_args)

  force_delete_output <- any("--force-delete" == script_args) || any("-D" == script_args)

  delete_output <- any("--delete" == script_args) || any("-d" == script_args)

  temp <- grepl("--tests", script_args) | grepl("-t", script_args)
  which_tests_torun <- if (any(temp)) {
      strsplit(script_args[temp][1], "=")[[1]][2]
    } else {
      NA
    }

} else {
  path <- make_new_ref <- force_delete_output <- delete_output <- which_tests_torun <- NA
}


#---Interactive user input
# Current working directory must be a subfolder of 'rSFSW2_tools' or itself
dir_test <- if (grepl("rSFSW2_tools", dir_prev)) {
    temp <- strsplit(dir_prev, .Platform$file.sep, fixed = TRUE)[[1]]
    temp <- do.call("file.path", as.list(temp[seq_len(which(temp == "rSFSW2_tools"))]))
    file.path(temp, "Test_projects")

  } else {
    temp <- if (interactive()) {
      readline("Enter path to folder of test projects 'Test_projects': ")
    } else path

    if ("Test_projects" != basename(temp)) {
      stop("Folder of test projects 'Test_projects' could not be located.")
    }
    temp
  }
dir_test <- normalizePath(dir_test)
setwd(dir_test)

# Ask if output should be saved as future reference DB
make_new_ref <- if (interactive()) {
    temp <- readline("Should the test output be used as future reference (y/n): ")
    temp == "y" || temp == "Y" || grepl("yes", temp, ignore.case = TRUE)
  } else {
    make_new_ref
  }

# Ask if output should be deleted even if there were problems
force_delete_output <- if (interactive()) {
    temp <- readline("Should the test output be force deleted (y/n): ")
    temp == "y" || temp == "Y" || grepl("yes", temp, ignore.case = TRUE)
  } else {
    force_delete_output
  }

# Ask if output should be deleted if all was ok
delete_output <- if (!force_delete_output) {
    if (interactive()) {
      temp <- readline("Should the test output be deleted (y/n): ")
      temp == "y" || temp == "Y" || grepl("yes", temp, ignore.case = TRUE)
    } else {
      delete_output
    }
  } else TRUE

# Ask which of the test projects should be run
temp <- list.dirs(dir_test, full.names = FALSE, recursive = FALSE)
tests <- file.path(dir_test, grep("[Test][[:digit:]+][_]", basename(temp), value = TRUE))
temp <- if (interactive()) {
    writeLines(paste0("Available tests:\n",
      paste0("    ", seq_along(tests), ") ", basename(tests), collapse = "\n")))
    readline(paste0("Which of the ", length(tests), " tests should be run: \n",
      "('c' for 'cancel'; 'all'; a single number; several numbers separated by commas;\n",
      "zero or a negative number to delete any temporary objects) "))
  } else which_tests_torun

which_tests_torun <- if (!is.na(temp)) {
    if (identical(tolower(temp), "c") || identical(tolower(temp), "cancel") ) {
      NA
    } else if ("all" == temp) {
      seq_along(tests)
    } else {
      temp <- unique(as.integer(strsplit(gsub("[[:space:]]", "", temp), ",")[[1]]))
      if (all(temp < 1)) {
        -1
      } else {
        intersect(temp, seq_along(tests))
      }
    }
  } else {
    seq_along(tests)
  }


if (any(!is.na(which_tests_torun))) {
  #---Load functions
  library("rSFSW2")

  #---Run projects
  if (any(which_tests_torun > 0)) {
    out <- rSFSW2::run_test_projects(dir_prj_tests = dir_test, dir_tests = tests,
      dir_prev = dir_prev, which_tests_torun = which_tests_torun,
      delete_output = delete_output, force_delete_output = force_delete_output,
      make_new_ref = make_new_ref, write_report_to_disk = TRUE)

    cat("\nSummary of test project runs:\n")
    print(out[["res"]])
    cat("\n")

  } else if (which_tests_torun < 1) {
    cat("\n")
    cat(paste0(Sys.time(), ": delete temporary disk files of rSFSW2 test projects.\n"))
    out <- rSFSW2::run_test_projects(dir_prj_tests = dir_test, dir_tests = tests,
      dir_prev = dir_prev, which_tests_torun = NULL, delete_output = FALSE,
      force_delete_output = TRUE, make_new_ref = FALSE, write_report_to_disk = FALSE)
  }
}

setwd(dir_prev)

temp <- warnings()
if (!is.null(temp)) {
  cat("Warnings generated during test projects:\n")
  print(temp)
}

writeLines(c("", "",
  "##############################################################################",
  paste("#------ rSFSW2_tools-TEST-PROJECTS ended at", Sys.time()),
  "##############################################################################", ""))

