# github

This image creates a cloud9 container heavily customized for coding.

## Usage

You need to specify some of these environment variables
1. CLOUD9_WORKSPACE - the directory in the container where the ide will be located
2. CLOUD9_PORT - the port on which it listens
3. PROJECT_NAME - the title that the ide will take
4. {UPSTREAM,ORIGIN,REPORT}_ID_RSA - the ssh private keys for the respective remotes
5. {UPSTREAM,ORIGIN,REPORT}_HOST - the host for the respective remotes (e.g., github.com)
6. {UPSTREAM,ORIGIN,REPORT}_PORT - the port for the respective remotes (e.g., 22)
7. {UPSTREAM,ORIGIN,REPORT}_ORGANIZATION - the organization for the respective remotes (the remote for this repository is rebelplutonium).
8. {UPSTREAM,ORIGIN,REPORT}_REPOSITORY - the repository name for the respective remotes (this repository's name is github)
9. {UPSTREAM,ORIGIN}_BRANCH - the branch for the respective remote
10. {GPG,GPG2}_SECRET_KEY for signing
11. {GPG,GPG2}_OWNER_TRUST for signing
12. COMMITTER_{NAME,EMAIL} for git commits

Then when you run the container, it will
* import the private ssh keys from your environment variables
* import the private gpg keys from your environment variables
* initialize the git repository with
  * 3 remotes as specified in environment variables
    * disable push on upstream
  * your name and email for commits
  * your signing key for signed commits
* if specified fetch and checkout the ORIGIN_BRANCH
* otherwise if specified fetch and checkout the UPSTREAM_BRANCH
* launches the web ide

### Caution
When you use this image, you should be careful to not expose the container to outsiders.
It will contain your gpg private key - which is very sensitive data.

### Discussion
I named this project 'github' because it is geared towards repositories with structures like github or gitlab.
This is a common pattern:  `https://github.com/ORGANIZATION/REPOSITORY.git`

It is usually easy to create your own organization and usually there is one automatically created for your user-name.

I created 3 remotes - each with their own responsibilities:
1. UPSTREAM - I am invisioning a repository in which you have no 'write' privileges.
   Alternatively, this could be your employer's 'gold standard' repository - you have write privileges but you want to be careful.
   To accomodate this, the container strips write privileges from the UPSTREAM remote.
   If you accidentally type `git push upstream garbage`, garbage will not be pushed upstream.
2. ORIGIN - I am invisioning a repository which is completely yours.
   If your company has a 'gold standard' repository then you should fork it.
   Since this is 'your repository' you should not feel ashamed to push 'garbage' to it.
   In fact, to protect against accidental code loss due to your laptop being lost, etc, every single commit is pushed to origin.
   Also when the container is stopped, it makes a final commit and push.
3. REPORT - I anticipate that this remote will be used least often.  
   The problem I had was that I was using UPSTREAM to fetch changes from my employer's gold standard repository; ORIGIN to push my changes; and a merge request to move from ORIGIN to UPSTREAM.
   I liked this pattern but my code reviewers did not.
   They did not want to have to add my remote to their project to download my code.
   Since they have power and I want to get along, I created another remote to accomodate.
   REPORT is usually almost exactly the same as UPSTREAM except
   1. it has a different ssh private key
   2. push is not disabled
   If I accidentally typed in `git push report garbage` it would ask me for my passphrase - which would give me another opportunity to back out from a mistake.
   If I on purpose typed `git push report new_feature` it would ask me for my passphrase.  I would type it.  The code would be pushed.  I would create a merge request.  From the point of view of my reviewers, I pushed to the gold standard repository.



