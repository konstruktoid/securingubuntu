#!/bin/sh
find ../hardening/scripts/ -type f | while read -r f; do
  DIRECTORY="$(echo "$f" | sed 's/.*_//g')"
  echo "./sections/${DIRECTORY}"
  find ../hardening/tests/ -type f -name "*${DIRECTORY}*" | while read -r t; do
    grep -Ro '@test ".*"' "$t" | tr -d "'*$\"" | \
    sed -e 's/.*@test //g' -e 's/ /_/g' -e 's/\//_/g' -e 's/__/_/g' -e 's/\./_/g' -e 's/_$//g' | \
    tr '[:upper:]' '[:lower:]' | sed 's/verify/ensure/g' | while read -r sectskel; do
      cd "./sections/${DIRECTORY}" || exit 1
      if [ -f ../../sections/shared/skeleton.adoc ] && ! [ -f "./${sectskel}.adoc" ]; then
        cp --verbose "../../sections/shared/skeleton.adoc" "./${sectskel}.adoc"
      fi
      if [ -f "./${sectskel}" ]; then
        mv --verbose "./${sectskel}" "./${sectskel}.adoc"
      fi
      cd "../../" || exit 1
    done
  done
done

echo "= Summary
" > ./SUMMARY.adoc
find ./ -name '*runtime*adoc' -type f -exec rm {} \;

# Clean level 2 settings for the moment
rm -rf ./sections/pre ./sections/compilers ./sections/auditd ./sections/sysctl

find ./sections -name '*.adoc' | sort | while read -r sectfile; do
  sectitle="$(grep -Eo '^=\s.*' "${sectfile}" | tr -d '=' | sed 's/^ //g')"
  sectpath="$(echo "$sectfile" | sed 's/\.\///g' | tr -d '^ ')"
  echo ". link:${sectpath}[${sectitle}]" >> ./SUMMARY.adoc
done

sed -i.bak '/Skeleton title/d' SUMMARY.adoc
find ./ -name '*.bak' -type f -exec rm {} \;
