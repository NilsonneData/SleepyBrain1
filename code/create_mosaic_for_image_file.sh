#!/bin/bash

image=$1

if [ -z ${image} ]; then
	echo "No image provided." >&2
	exit 1
elif [[ ! -e ${image} ]]; then
	echo "Image ${image} doesn't exist." >&2
	exit 1
fi

tmpdir=$(mktemp -d `pwd`/mosaictmp.XXXXXXXX)

# 1. fslslice up the images
#fslslice ${image} ${tmpdir}/`basename ${image%.nii*}`
fslsplit ${image} ${tmpdir}/`basename ${image%.nii*}`_slice_ -x
img_n=0
for f in ${tmpdir}/*_slice_????.nii.gz; do

	img_n=$((img_n+1))
	if [[ ${img_n} == 5 ]]; then # == 10 for T2w
		png_dest=${f%.nii*}.png
		fslswapdim ${f} y z x ${f} # for the T1ws.
		slicer ${f} -A 512 ${png_dest}
		img_n=1
	fi

	rm ${f}

done

# for T2w:
#montage -rotate -90 ${tmpdir}/*.png `basename ${image%.nii*}_mosaic.png`
# for T1w:
montage ${tmpdir}/*.png `basename ${image%.nii*}_mosaic.png`

[[ -d ${tmpdir} ]] && rm -rf ${tmpdir}

exit 0
