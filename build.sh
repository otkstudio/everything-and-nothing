#!/usr/bin/env bash
# build.sh — generate _site/index.html from entries/*.md.
# Needs only bash + awk (both already on every Unix machine). No frameworks.

set -eu

cd "$(cd "$(dirname "$0")" && pwd)"

out="_site"
html="$out/index.html"
months="January February March April May June July August September October November December"

rm -rf "$out"
mkdir -p "$out"
if [ -d images ]; then cp -R images "$out/images"; fi

# --- page head (all CSS inline, one <style> tag, no external requests) ---
cat > "$html" <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Journal</title>
<style>
html { font-size: 20px; }
body { margin: 0; background: #fff; color: #111;
       font-family: Georgia, "Times New Roman", Times, serif; line-height: 1.5; }
main { max-width: 34rem; margin: 0 auto; padding: 6rem 1.5rem; }
article { margin: 0 0 4rem; }
article time { display: block; font-style: italic; margin-bottom: 1.5rem; }
article p { margin: 0 0 1rem; }
article img { max-width: 100%; height: auto; display: block; margin: 1.5rem 0; }
blockquote { margin: 1rem 0; padding-left: 1rem;
             border-left: 2px solid #ddd; font-style: italic; }
a { color: inherit; }
</style>
</head>
<body>
<main>
HEAD

# --- entries, newest first (plain filename sort works thanks to YYYY-MM-DD) ---
if ls entries/*.md >/dev/null 2>&1; then
  for f in $(ls entries/*.md | sort -r); do
    base="$(basename "$f" .md)"          # 2026-06-13  (or 2026-06-13b)
    mi=$((10#${base:5:2}))               # month 1..12 (10# avoids octal)
    dd=$((10#${base:8:2}))               # day without leading zero
    mname="$(echo "$months" | cut -d' ' -f "$mi")"
    {
      echo "<article>"
      echo "<time>$mname $dd</time>"
      awk -f lib/md.awk "$f"
      echo "</article>"
    } >> "$html"
  done
fi

cat >> "$html" <<'FOOT'
</main>
</body>
</html>
FOOT

echo "Built $html"
