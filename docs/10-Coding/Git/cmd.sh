git config --global user.signingKey /home/admin/.ssh/id_ed25519.pub
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.allowedSignersFile /home/admin/.config/git/allowed_signers



# [core]
# repositoryformatversion = 0
# filemode = true
# bare = false
# logallrefupdates = true
# [remote "origin"]
# url = git@github.com:SJFCS/cloudnative.love.git
# fetch = +refs/heads/:refs/remotes/origin/
# [branch "main"]
# remote = origin
# merge = refs/heads/main
# [gpg]
# format = ssh
# [user]
# signingKey = /home/admin/.ssh/id_ed25519.pub
# [gpg "ssh"]
# allowedSignersFile = /home/admin/.config/git/allowed_signers
# [commit]
# gpgsign = true
# [tag]
# gpgsign = true 