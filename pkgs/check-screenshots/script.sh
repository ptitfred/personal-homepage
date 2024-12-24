set -e

baseUrl="$1"

function listPages {
  curl -s "$baseUrl/sitemap.xml" | htmlq -t urlset url loc
}

function readPath {
  local url="$1"
  curl -s "$url" | htmlq 'meta[property="og:image"]' --attribute content
}

function clearLine {
  echo -en "\r\033[K"
}

function valid {
  clearLine
  echo "✅ $1"
}

function checkScreenshot {
  echo -n "⌛ $1"
  path=$(readPath "$1")
  if [ -n "$path" ]
  then
    http --quiet --check-status --headers GET "${baseUrl}${path}" && valid "$1"
  else
    clearLine
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
