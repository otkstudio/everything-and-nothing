# Journal

A journal built to last. Each entry is a plain markdown file. A single webpage
is generated from the entries — one HTML file, all styling inline, no
frameworks, no dependencies beyond `bash` and `awk` (which ship on every Unix
machine). The source of truth is the plain text in `entries/`; everything else
is generated from it.

## Adding an entry

1. Create a file in `entries/` named by its date: `entries/YYYY-MM-DD.md`
   (for a second entry on the same day, add a letter: `entries/2026-06-13b.md`).
2. Write the entry in markdown.
3. Commit and push. The site rebuilds and republishes itself automatically.

That's the whole job.

## Adding a photo

Drop the image file in `images/`, then reference it from an entry:

```markdown
![a short caption](images/your-photo.jpg)
```

## Supported markdown

Kept intentionally small:

- Blank line between paragraphs
- `*italic*` and `**bold**`
- `[link text](https://…)`
- `![caption](images/photo.jpg)`
- `> a blockquote`

## Preview locally before pushing

```sh
bash build.sh && open _site/index.html
```

## How it fits together

```
entries/   your markdown files (the only thing you edit)
images/    photos referenced by entries
lib/md.awk the markdown → HTML translator (~120 lines, readable in one sitting)
build.sh   reads entries/, writes _site/index.html
.github/   the workflow that rebuilds + publishes on every push
```

`_site/` is generated output and is not committed.

## One-time GitHub setup

In the repository settings on GitHub: **Pages → Build and deployment → Source →
GitHub Actions**. After that, pushing an entry is all it takes.
