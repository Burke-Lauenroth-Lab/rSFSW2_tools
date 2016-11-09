# Tools to support the development of [SWSF](https://github.com/Burke-Lauenroth-Lab/SoilWat_R_Wrapper)

## Test Projects
Complete SWSF projects configured to test different functionality. Code is available to
execute these test projects and compare against reference databases.

1. Required setup
    - Folder structure of git clones with adequate branches checked out on both
        - ./SoilWat_R_Wrapper
        - ./rSWSFtools
    - If needed adjust `dir.external`, i.e., path to external datasets in p1 of test projects

2. Run test projects
    - Start R
    - ```r
      setwd("rSWSFtools/") # Set working directory
      source("Test_projects/Run_all_test_projects.R")
      ```
    - Enter your request at the command prompt (for full details, read the code)
    - > Should the test output be used as future reference (y/n):
    - > Should the test output be force deleted (y/n):
    - > Should the test output be deleted (y/n):
    - > Available tests:
    - >     1) Test1_downscaling_overhaul
    - >     2) Test2_LookupWeatherFolders
    - >     3) Test3_OnlyMeanDailyOutput
    - >     4) Test4_AllOverallAggregations_snow
    - >     5) Test5_AllOverallAggregations_mpi
    - >     6) Test6_wgen_downscaling
    - > Which of the 6 tests should be run ('all'; a single number; several numbers
      > separated by commas; zero or a negative number to delete any temporary objects):

3. Check the outcomes
    - If the output does not compare favorably with the reference database, then a
      problem report is generated.
    - The outcome(s) of each test project run is/are summarized by a logical table with
      the columns "has_run", "has_problems", "made_new_refs", "deleted_output", and
      "referenceDB"


## Please, report [issues](https://github.com/Burke-Lauenroth-Lab/rSWSFtools/issues) and offer [pull-request](https://github.com/Burke-Lauenroth-Lab/rSWSFtools/pulls)
