# !/bin/bash
set -exuo pipefail

# requires say and sox

#BPM=128
#SONG=shots_instruments_128_bpm_sampled.aiff

BPM=60
SONG=smooth_jazz.aiff

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
		rest_length=`echo "$beats*${BEAT_LENGTH_SECONDS}" | bc -l`
		sox -n -r 22050 tmp/${i}.aiff trim 0.0 $rest_length
	else
		echo $word
		say "$word" -o tmp/${i}_tmp.aiff
		sox tmp/${i}_tmp.aiff tmp/${i}_trimmed.aiff silence 1 0.1 1%
		clip_length=`sox tmp/${i}_trimmed.aiff -n stat 2>&1 | grep Length | awk '{print $3}'`
		scale_factor=`echo "${clip_length}/(${BEAT_LENGTH_SECONDS}*${beats})" | bc -l`
		sox tmp/${i}_trimmed.aiff tmp/${i}.aiff tempo $scale_factor
	fi
	files="${files} tmp/${i}.aiff"
	i=$((i + 1))
done < "${1:-/dev/stdin}"

sox airhorn.aiff airhorn_repeat.aiff repeat 10
sox yeah_what_ok.aiff yeah_what_ok_repeat.aiff repeat 20
sox $files tmp/speech.aiff repeat 10
#sox -m tmp/speech.aiff $SONG yeah_what_ok_repeat.aiff tmp/mixed.aiff
sox -m tmp/speech.aiff $SONG tmp/mixed.aiff
play tmp/mixed.aiff
