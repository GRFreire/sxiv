#!/bin/sh

### DEPENDENCIES
# - git
# - npx
# - mandoc

copy_from_master() {
    git show "master:$1" > "$1"
}

copydir_from_master() {
    mkdir "$1"
    FILES="$(git show master:"$1" | sed "s/tree master:$1//g" | sed '/^$/d')"
    for FILE in $FILES; do
        copy_from_master "$1/$FILE"
    done
}

generate_manpage_html() {
    copy_from_master sxiv.1

    mandoc -Thtml sxiv.1 > sxiv.1.html
    awk '/<style>/,/<\/style>/ { if ( $0 ~ /<\/style>/ ) print "  <link rel=\"stylesheet\" href=\"sxiv.1.css\">"; next } 1' \
        sxiv.1.html > sxiv.1.html.tmp && mv sxiv.1.html.tmp sxiv.1.html
}

generate_readme_html() {
    mkdir README
    copy_from_master README.md
    copydir_from_master README

    rm img/*
    mv README/* img

    cat header.html README.md > README.md.tmp && mv README.md.tmp README.md

    npx github-readme-to-html README.md sxiv
    mv dist/index.html .
    sed -i 's/README\//img\//g' index.html
}


remove_all_tmp() {
    rm sxiv.1 README.md
    rm -Rf README dist
}

main() {
    generate_manpage_html
    generate_readme_html

    remove_all_tmp
}

main
