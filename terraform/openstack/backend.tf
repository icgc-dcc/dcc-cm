terraform {
  backend "artifactory" {
    url     = "https://artifacts.oicr.on.ca/artifactory"
    repo    = "sweng-dev-terraform"
    subpath = "cumulus-state"
  }
}
