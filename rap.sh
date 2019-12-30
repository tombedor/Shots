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

exit 0

sox -n -r 22050 silence.aiff trim 0.0 $BEAT_LENGTH_SECONDS


# say -r doesn't work.. the word spacing is not consistent. So, we get one repetition of the word
echo "writing word file"
say $WORD -o word.aiff

# trim silence https://digitalcardboard.com/blog/2009/08/25/the-sox-of-silence/comment-page-2/
echo "trimming leading silence of word file"
sox word.aiff word_trimmed.aiff silence 1 0.1 1%

ORIGINAL_CLIP_LENGTH_SECONDS=`sox word_trimmed.aiff -n stat 2>&1 | grep Length | awk '{print $3}'`
echo "clip length is ${ORIGINAL_CLIP_LENGTH_SECONDS} seconds"

BEAT_LENGTH_SECONDS=`echo "60.0/${BPM}.0" | bc -l`
echo "desired clip length is ${BEAT_LENGTH_SECONDS} seconds"


SCALE_FACTOR=`echo "${ORIGINAL_CLIP_LENGTH_SECONDS}/${BEAT_LENGTH_SECONDS}" | bc -l`
echo "Scale factor is ${SCALE_FACTOR}"
sox word_trimmed.aiff word_tempod.aiff tempo $SCALE_FACTOR

sox word_tempod.aiff word_1_2.aiff repeat 1
sox word_tempod.aiff word_3_4.aiff tempo 1.5 repeat 2

sox -n -r 22050  silence.aiff trim 0.0 `echo "${BEAT_LENGTH_SECONDS}*2" | bc`

sox word_1_2.aiff word_3_4.aiff words_repeated.aiff

say "everybody" -o everybody.aiff
EVERYBODY_LENGTH_SECONDS=`sox everybody.aiff -n stat 2>&1 | grep Length | awk '{print $3}'`
sox everybody.aiff everybody_tempod.aiff tempo `echo "${EVERYBODY_LENGTH_SECONDS}/(${BEAT_LENGTH_SECONDS}*3)" | bc -l`


sox -n -r 22050 silence.aiff trim 0.0 $BEAT_LENGTH_SECONDS

sox silence.aiff everybody_tempod.aiff everybody_final.aiff

sox words_repeated.aiff words_3x_repeated.aiff repeat 2
sox words_3x_repeated.aiff everybody_final.aiff words_final.aiff repeat 10
sox -m shots_instruments_128_bpm_sampled.aiff words_final.aiff yeah_what_ok.aiff mixed.aiff
play mixed.aiff
