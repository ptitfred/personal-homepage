set -e

baseUrl="$1"
output="$2"

function listPages {
  curl -s "$baseUrl/sitemap.xml" | htmlq -t urlset url loc
}

function readContentHash {
  local url="$1"
  curl -s "$url" | htmlq "meta[property=source_hash]" --attribute content
}

function takeScreenshot {
  local url="$1"

  hash=$(readContentHash "$url")
  if [ -n "$hash" ]
  then
    puppeteer screenshot --viewport 1200x630 "$url" "$output/$hash-uncropped.png"
    echo "Cropping to $output/$hash.png"
    convert "$output/$hash-uncropped.png" -crop 1200x630+0+0 "$output/$hash.png"
    rm "$output/$hash-uncropped.png"
  fi
}

function takeScreenshots {
  while read -r url ; do takeScreenshot "$url" ; done
}

function proceed {
  listPages | takeScreenshots
}

function sumUp {
  echo "--"
  echo "$(find $output -name '*.png' | wc -l) screenshots taken, good bye."
}

proceed
sumUp
