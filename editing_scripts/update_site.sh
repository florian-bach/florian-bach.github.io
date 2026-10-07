#!/usr/bin/env bash
# Personalize academicpages _config.yml + _pages/about.md, then commit and push.
# Run from anywhere inside the florian-bach.github.io clone.
set -euo pipefail

# ---- Fill these in (leave "" to hide the icon/link) -------------------------
EMAIL="fbach@stanford.edu"
SCHOLAR="https://scholar.google.com/citations?user=8wbnBFEAAAAJ&hl=en"
ORCID="https://orcid.org/0000-0002-0126-5516"
PUBMED=""
PHOTO="$HOME/Downloads/photocache.298007.jpg"          # local path to a headshot, e.g. "$HOME/Desktop/me.jpg"
# -----------------------------------------------------------------------------

cd "$(git rev-parse --show-toplevel)"

# setkey KEY VALUE [author]
# Replaces the value of a top-level key, or of a key inside the author: block.
# Empty VALUE leaves the key blank (Liquid treats "" as truthy, so blank != "").
setkey() {
  KEY="$1" VAL="$2" SCOPE="${3:-top}" perl -i -pe '
    my ($k, $v, $a) = ($ENV{KEY}, $ENV{VAL}, $ENV{SCOPE} eq "author");
    my $ind = $a ? "  " : "";
    if ($a ? (/^author:/ ... /^\S/) : 1) {
      s/^(\Q$ind$k\E\s*:\s*)(&\w+\s+)?[^\n]*/length($v) ? "$1$2\"$v\"" : $1/e;
    }
  ' _config.yml
}

# Site settings
setkey title       "Florian Bach"
setkey name        "Florian Bach"
setkey description "Systems immunology of early life, vaccines, and malaria"
setkey url         "https://florian-bach.github.io"
setkey repository  "florian-bach/florian-bach.github.io"

# Sidebar
AVATAR=""
if [[ -n "$PHOTO" ]]; then
  AVATAR="profile.${PHOTO##*.}"
  cp "$PHOTO" "images/$AVATAR"
fi
setkey avatar        "${AVATAR:-profile.png}" author
setkey name          "Florian Bach" author
setkey pronouns      "" author
setkey bio           "Postdoctoral Scholar, Stanford University School of Medicine" author
setkey location      "Stanford, CA" author
setkey employer      "Stanford University" author
setkey email         "$EMAIL" author
setkey googlescholar "$SCHOLAR" author
setkey orcid         "$ORCID" author
setkey pubmed        "$PUBMED" author
setkey github        "florian-bach" author
setkey bluesky       "" author

# About page
cat > _pages/about.md <<'EOF'
---
permalink: /
title: "About"
author_profile: true
redirect_from:
  - /about/
  - /about.html
---

I am a postdoctoral scholar in the Division of Infectious Diseases and Geographic Medicine at Stanford University School of Medicine, working with [Prasanna Jagannathan](https://profiles.stanford.edu/prasanna-jagannathan). I study how the immune system develops in early life, and how exposures before and after birth, particularly malaria, shape immune development, vaccine responsiveness, and susceptibility to infection in children in low- and middle-income settings.

My work combines systems immunology approaches, including single-cell transcriptomics, high-dimensional proteomics, and flow cytometry, with longitudinal birth cohorts in Uganda and elsewhere in Africa. I founded the Early Life Immunology in Africa (ELIA) consortium, which brings together birth-cohort studies to pool data and samples on early-life immunity.

My research is supported by an NIH/NIAID K99/R00 Pathway to Independence Award.

## Research interests

- Early-life immune development
- Vaccine hyporesponsiveness in infants
- Malaria and malaria chemoprevention in pregnancy and childhood
- Maternal influences on fetal and infant immunity, including microchimerism
EOF

git diff --stat
git add -A
git commit -m "Personalize config and about page"
git push
