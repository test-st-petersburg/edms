@echo on

powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

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

git config --local core.quotepath false
git config --local core.longpaths true
