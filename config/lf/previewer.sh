#!/bin/sh

file="$1"

# lf requires output on stdout
case "$(file --mime-type -Lb "$file")" in
  text/*|application/json|application/xml)
    if command -v bat >/dev/null 2>&1; then
      bat --color=always --style=plain --pager=never "$file"
    else
      sed -n '1,200p' "$file"
    fi
    ;;
  application/pdf)
    pdftotext "$file" - 2>/dev/null | sed -n '1,200p'
    ;;
  application/zip|application/x-tar|application/x-7z-compressed)
    bsdtar -tf "$file"
    ;;
  *)
    file "$file"
    ;;
esac

