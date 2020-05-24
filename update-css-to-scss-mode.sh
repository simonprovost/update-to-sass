#!/bin/bash

function execChange() {
  num=$(grep -o '/' <<<"$1" | grep -c .)
  directory=$1
  if [ $num -gt 1 ]; then
    directory=$(echo "$1" | cut -d / -f1-2)
  else
    directory="."
  fi

  file="./exclude-directories-update-sass-css.txt"
  lines=$(cat $file)
  for line in $lines; do
    if [ "$line" == "$directory" ]; then
      return
    fi
  done

  if [ "$2" == "sass" ]; then
    mv "$1" "${1%.css}".scss
  else
    mv "$1" "${1%.scss}".css
  fi
}

export -f execChange

function change_filename() {
  echo "process to change all files extension..."
  if [ "$1" == "sass" ]; then
    find . -name '*.css' -exec bash -c 'execChange "$1" sass' - '{}' \;
  else
    find . -name '*.scss' -exec bash -c 'execChange "$1" css' - '{}' \;
  fi
}

function change_path() {
  file="./exclude-directories-update-sass-css.txt"
  lines=$(cat $file)
  # shellcheck disable=SC2034
  paths=""
  for line in $lines; do
    paths="${paths} ${line}"
  done

  echo $paths

  echo "process to change all path directly in tsx/js files..."
  if [ "$1" == "sass" ]; then
    if [ "$2" == "js" ]; then
      rpl -ivRpd -d -x'.js' '.css' '.scss' . --exclude-directories $paths --end-excludes-directories
    elif [ "$2" == "tsx" ]; then
      rpl -ivRpd -d -x'.js' '.css' '.scss' . --exclude-directories $paths --end-excludes-directories
    else
      rpl -ivRpd -d -x'.js' '.css' '.scss' . --exclude-directories $paths --end-excludes-directories
      rpl -ivRpd -d -x'.tsx' '.css' '.scss' . --exclude-directories $paths --end-excludes-directories
    fi
  else
    if [ "$2" == "js" ]; then
      rpl -ivRpd -d -x'.js' '.scss' '.css' . --exclude-directories $paths --end-excludes-directories
    elif [ "$2" == "tsx" ]; then
      rpl -ivRpd -d -x'.tsx' '.scss' '.css' . --exclude-directories $paths --end-excludes-directories
    else
      rpl -ivRpd -d -x'.js' '.scss' '.css' . --exclude-directories $paths --end-excludes-directories
      rpl -ivRpd -d -x'.tsx' '.scss' '.css' . --exclude-directories $paths --end-excludes-directories
    fi
  fi
}

function process_x_and_check() {
  "$@"
  retval=$?
  if [ $retval -ne 0 ]; then
      echo "Return code was not zero but $retval"
      exit $retval
  fi
}

function check_error() {
  if [ "$1" != "sass" ] && [ "$1" != "css" ]; then
    echo "Please add mode 'sass' or 'css'. Any other won't work."
    exit 84
  fi
}

function main() {
  check_error "$1"
  process_x_and_check change_filename "$1"
  process_x_and_check change_path "$1" "$2"
}

main "$1"
