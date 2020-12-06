#!/usr/bin/env bash
# Author: "abpwrs"
# Date: 20201203

# args:
# 1 --
# 2 --

#if [[ $# -ne 1 ]]; then
#    echo "Usage: $0 <param-1> <param-2> ..."
#    exit
#fi


# script:
report_filename="$(date +%Y%m%d%H%M)_report.txt"
echo $report_filename

if [[ -f $report_filename ]]; then
	rm report.txt
fi


for dd in ./*; do
	if [[ -d $dd ]]; then

cat >> $report_filename <<EOF
# IMAGE: ${dd}
# ##############################
# missing coins
n
# incorrect classification
n
# ##############################


EOF

	fi
done