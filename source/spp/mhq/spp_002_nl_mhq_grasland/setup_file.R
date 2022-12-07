library(protocolhelper)
create_protocol(
   protocol_type = "spp",
   title = "Een project-specifiek protocol",
   short_title = "mhq grasland",
   authors = c("Oosterlynck, Patrik"),
   orcids = c("0000-0002-5712-0770"),
   reviewers = c("Hans Van Calster", "Toon Westra", "Leen Govaere"),
   file_manager = "Patrik Oosterlynck",
   project_name = "mhq",
   language = "nl",
   subtitle = NULL)
checklist::new_branch("spp-002-nl")
# saved this file as setup_file.R in spp-002-nl folder
# manually added a NEWS item
gert::git_add(".")
gert::git_commit_all("initial commit")
protocolhelper::check_all("spp-002-nl")
