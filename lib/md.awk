# md.awk — a tiny markdown subset -> HTML.
#
# Deliberately small and self-contained. Runs identically on macOS's BSD awk
# and the GNU awk on the build server; uses no gensub and no regex
# backreferences, so it stays portable forever.
#
# Supported: blank-line-separated paragraphs, > blockquotes, *italic*,
# **bold**, [text](url) links, and ![alt](src) images.

# --- HTML-escape raw text (run before any of our own tags are inserted) ---
function esc(s) {
    gsub(/&/, "\\&amp;", s)   # must be first
    gsub(/</, "\\&lt;",  s)
    gsub(/>/, "\\&gt;",  s)
    return s
}

# --- Replace ![alt](src) with <img>. Runs before links (superset syntax). ---
function images(s,   out, m, lb, rb, lp, alt, src) {
    out = ""
    while (match(s, /!\[[^]]*\]\([^)]*\)/)) {
        out = out substr(s, 1, RSTART - 1)
        m   = substr(s, RSTART, RLENGTH)        # ![alt](src)
        lb  = index(m, "[");  rb = index(m, "]")
        lp  = index(m, "(")
        alt = substr(m, lb + 1, rb - lb - 1)
        src = substr(m, lp + 1, length(m) - lp - 1)
        out = out "<img src=\"" src "\" alt=\"" alt "\">"
        s   = substr(s, RSTART + RLENGTH)
    }
    return out s
}

# --- Replace [text](url) with <a>. ---
function links(s,   out, m, lb, rb, lp, text, url) {
    out = ""
    while (match(s, /\[[^]]*\]\([^)]*\)/)) {
        out  = out substr(s, 1, RSTART - 1)
        m    = substr(s, RSTART, RLENGTH)       # [text](url)
        lb   = index(m, "[");  rb = index(m, "]")
        lp   = index(m, "(")
        text = substr(m, lb + 1, rb - lb - 1)
        url  = substr(m, lp + 1, length(m) - lp - 1)
        out  = out "<a href=\"" url "\">" text "</a>"
        s    = substr(s, RSTART + RLENGTH)
    }
    return out s
}

# --- Wrap paired delimiter d with open/close tags (toggle on each hit). ---
# Unbalanced (odd) delimiters are left as literal text.
function wrap(s, d, otag, ctag,   dl, p, n, maxd, i, out, scan) {
    dl = length(d)
    n = 0; scan = s
    while ((p = index(scan, d)) > 0) { n++; scan = substr(scan, p + dl) }
    maxd = n - (n % 2)                 # largest even count <= n
    if (maxd == 0) return s
    out = ""; i = 0
    while (i < maxd && (p = index(s, d)) > 0) {
        out = out substr(s, 1, p - 1) (i % 2 == 0 ? otag : ctag)
        s   = substr(s, p + dl)
        i++
    }
    return out s
}

function inline(s) {
    s = esc(s)
    s = images(s)
    s = links(s)
    s = wrap(s, "**", "<strong>", "</strong>")   # bold before italic
    s = wrap(s, "*",  "<em>",     "</em>")
    return s
}

function flush() {
    if (buf == "") { mode = ""; return }
    if (mode == "q") print "<blockquote>" inline(buf) "</blockquote>"
    else             print "<p>" inline(buf) "</p>"
    buf = ""; mode = ""
}

# blank line -> end current block
/^[ \t]*$/ { flush(); next }

# blockquote line
/^>[ ]?/ {
    if (mode == "p") flush()
    mode = "q"
    text = $0; sub(/^>[ ]?/, "", text)
    buf = (buf == "" ? text : buf " " text)
    next
}

# paragraph line
{
    if (mode == "q") flush()
    mode = "p"
    buf = (buf == "" ? $0 : buf " " $0)
}

END { flush() }
