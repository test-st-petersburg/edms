@echo on
choco install git.install
choco install vscode
choco install nodejs
choco install onescript -y

call npm install

call opm install precommit1c
call Precommit1c --install
@echo #!/bin/sh > .git/hooks/pre-commit
@echo oscript -encoding=utf-8 .git/hooks/v8files-extractor.os --git-precommit src --remove-orig-bin-files --use-designer >> .git/hooks/pre-commit

call opm install gitsync
call opm install packman
call opm install deployka
