# Code for completing [these instructions](https://cloud.google.com/architecture/managing-infrastructure-as-code)

1. Set up this repo with a dev and staging branches (rather than dev and prod in the tutorial)
1. Create environments and modules directories, and cloudbuild.yaml in main branch (pull to dev and staging)
1. Add some resources in dev, and include a remote backend.
1. Add editor role to Cloud Build service account.
1. Connect the repo to the project.
1. Create a trigger.
1. Add a tf resource to the dev branch. Make sure the build service account has bucket admin access.