baseUrl="$1"

invalid_urls=0

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

function invalid {
  clearLine
  echo "❌ $1"
}

function checkScreenshot {
  echo -n "⌛ $1"
  path=$(readPath "$1")
  if [ -n "$path" ]
  then
    if http --quiet --check-status --headers GET "${baseUrl}${path}" 2>/dev/null
    then
      valid "$1"
    else
      ((invalid_urls = invalid_urls + 1))
      invalid "$1"
    fi
  else
    clearLine
  fi
}

function checkScreenshots {
  readarray -t urls < "$1"
  for url in "${urls[@]}"
  do
    checkScreenshot "$url"
  done
}

function summary {
  echo ""
  if [ $invalid_urls -gt 0 ]; then
    echo "❌ ${invalid_urls} invalid URLs"
  else
    echo "✅ ${invalid_urls} all good!"
  fi
  exit $invalid_urls
}

list="./list"

trap cleanup EXIT HUP

function cleanup {
  # shellcheck disable=SC2317
  rm "$list"
}

function proceed {
  listPages > "$list"
  checkScreenshots "$list"
  summary
}

proceed
