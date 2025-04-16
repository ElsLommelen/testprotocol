#!/bin/sh -l

git clone --branch=$INPUT_GITHUB_HEAD_REF https://$INPUT_PAT@github.com/$GITHUB_REPOSITORY /update
cd /update
git config --global user.email "info@inbo.be"
git config --global user.name "INBO"

rm .Rprofile

echo '\nSession info\n'
Rscript -e 'sessioninfo::session_info()'

echo '\nUpdating zenodo...\n'
Rscript --no-save --no-restore -e 'protocolhelper:::update_zenodo()'
git add .zenodo.json
git commit --message="update .zenodo.json"

echo '\nUpdating general NEWS.md...\n'
Rscript --no-save --no-restore -e 'protocolhelper:::update_news_release("'$INPUT_GITHUB_HEAD_REF'")'
git add NEWS.md
git commit --message="update general NEWS.md"

echo '\nUpdating doi in index.Rmd ...\n'

# First, run the update_doi function
Rscript --no-save --no-restore -e 'protocolhelper:::update_doi(protocol_code = "'$INPUT_GITHUB_HEAD_REF'", sandbox = TRUE, token = "'$INPUT_ZENODO_SANDBOX'")'

# Get the path to the index.Rmd file 
FILE_PATH=$(Rscript --no-save --no-restore -e 'protocolhelper::get_path_to_protocol(protocol_code = "'$INPUT_GITHUB_HEAD_REF'") |> file.path("index.Rmd") |> cat()')

# Check if the file exists
if [ -f "$FILE_PATH" ]; then
  echo "Found index.Rmd at: $FILE_PATH"
  git add "$FILE_PATH"
  git commit --message="update doi in index.Rmd"
else
  echo "Error: index.Rmd not found at path: $FILE_PATH"
  exit 1
fi

# Diagnostic code before git push
echo "=== DIAGNOSTIC INFORMATION ==="
echo "Current directory: $(pwd)"
echo "Repository content:"
ls -la
echo "Git status:"
git status
echo "Git remote information:"
git remote -v
echo "Git branch information:"
git branch -a
echo "Git config information:"
git config --list
echo "GITHUB_REPOSITORY value: ${GITHUB_REPOSITORY}"
echo "GITHUB_TOKEN availability: ${GITHUB_TOKEN:+AVAILABLE}"
echo "Testing git authentication:"
git ls-remote https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git HEAD || echo "Authentication test failed"
echo "=== END DIAGNOSTIC ==="

# Original git push command
echo 'git push'
git remote set-url origin https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
git push -f || echo "Git push failed with exit code $?"
