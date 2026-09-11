#!/usr/bin/python3
import requests
import os
import sys
import gitlab
import git

# Retrieves all environment variables
ci_project_id = os.getenv("CI_PROJECT_ID")
ci_server_host = os.getenv("CI_SERVER_HOST")
ci_repository_url = os.getenv("CI_REPOSITORY_URL")
ci_commit_ref_name = os.getenv("CI_COMMIT_REF_NAME")
ci_project_path = os.getenv("CI_PROJECT_PATH")

if os.getenv("GITLAB_PRIVATE_TOKEN"):
    token = os.getenv("GITLAB_PRIVATE_TOKEN")
else:
    print("Projects in this group do not need their repos forks to be updated.")
    sys.exit(0)

os.system(
    'git config --global url."https://gitlab-ci-token:${token}@git.greensocs.com/".insteadOf "git@git.greensocs.com:"'.format(
        token=str(token)
    )
)
os.system('git config --global user.email "mark.burton@greensocs.com"')
os.system('git config --global user.name "BURTON Mark"')

# Connect to the API
gl = gitlab.Gitlab("http://git.greensocs.com/", token)
project = gl.projects.get(ci_project_id)

# List of fork project of the main project
forks_list = project.forks.list()

project_path = "/builds/" + str(ci_project_path)

# We go through all the fork projects and update them with the main project
if len(forks_list) != 0:
    # We check whether a mirror branch has been created beforehand because gitlab CI scripts keep track of git configurations, including branches and remotes.
    os.system("git branch -D _mirror")
    os.system("git checkout -b _mirror")
    for i in range(len(forks_list)):

        fork_path = forks_list[i].path_with_namespace
        fork_id = forks_list[i].id
        fork_name = forks_list[i].path

        os.system(
            "git remote add {fork_name} {ssh_url}".format(
                fork_name=str(fork_name), ssh_url=forks_list[i].ssh_url_to_repo
            )
        )
        os.system("git remote update && git remote && git branch")
        os.system(
            "git push http://root:{token}@{ci_server_host}/{fork_path} _mirror --force".format(
                token=str(token),
                ci_server_host=str(ci_server_host),
                fork_path=str(fork_path),
            )
        )
        os.system("git remote rm {fork_name}".format(fork_name=str(fork_name)))

        os.system(
            "gitlab_auto_mr -t "
            + str(ci_commit_ref_name)
            + " --source-branch _mirror --project-id "
            + str(fork_id)
            + " -c Automatic-MR --user-id 5 -d "
            + str(project_path)
            + "/cmake-boilerplate/.gitlab/merge_request/merge_request.md --private-token "
            + str(token)
        )

else:
    print("Nothing to do")
