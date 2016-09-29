#!/usr/bin/bash
bundle update
git add --all .
git commit -am "${*:1}"
git push
rake release mongo_session_store-rails5
