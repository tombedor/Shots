# !/bin/bash
set -euo pipefail

# requires say and sox

BPM=128

mkdir -p tmp

BEAT_LENGTH_SECONDS=`echo "60.0/${BPM}.0" | bc -l`

write_word() {
	say $1 -o tmp/$1_tmp.aiff
	sox tmp/$1_tmp.aiff tmp/$1.aiff silence 1 0.1 1%
}


i=0
files=""
while IFS=, read -r word beats
do

	if [ "$word" = "REST" ]; then
		echo "YAY"
		rest_length=`echo "$beats*${BEAT_LENGTH_SECONDS}" | bc -l`
		echo $rest_length	
		sox -n -r 22050 tmp/${i}.aiff trim 0.0 $rest_length
	else
		write_word $word
		clip_length=`sox tmp/$word.aiff -n stat 2>&1 | grep Length | awk '{print $3}'`
		scale_factor=`echo "${clip_length}/(${BEAT_LENGTH_SECONDS}*$beats)" | bc -l`
		echo $scale_factor
		sox tmp/$word.aiff tmp/$i.aiff tempo $scale_factor
	fi
	files="${files} tmp/${i}.aiff"
	i=$((i + 1))
	
done < "${1:-/dev/stdin}"
sox $files tmp/speech.aiff repeat 10

sox -m tmp/speech.aiff shots_instruments_128_bpm_sampled.aiff tmp/mixed.aiff
play tmp/mixed.aiff
