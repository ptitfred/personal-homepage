set -e

baseUrl="$1"

function listPages {
  curl -s "$baseUrl/sitemap.xml" | htmlq -t urlset url loc
}

function readPath {
  local url="$1"
  curl -s "$url" | htmlq 'meta[property="og:image"]' --attribute content
}

function checkScreenshot {
  echo -n "$1 "
  path=$(readPath "$1")
  if [ -n "$path" ]
  then
    http --quiet --check-status --headers GET "${baseUrl}${path}" && echo OK
  else
    echo Skipped
  fi
}

function checkScreenshots {
  readarray -t urls
  for url in "${urls[@]}"
  do
    checkScreenshot "$url"
  done
}

function proceed {
  listPages | checkScreenshots
}

proceed
