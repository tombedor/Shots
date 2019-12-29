# !/bin/bash
set -euo pipefail

# requires say and sox


WORD=$1
BPM=128

SAY_STRING=""


# say -r doesn't work.. the word spacing is not consistent. So, we get one repetition of the word
echo "writing word file"
say $WORD -o word.aiff

# trim silence https://digitalcardboard.com/blog/2009/08/25/the-sox-of-silence/comment-page-2/
echo "trimming leading silence of word file"
sox word.aiff word_trimmed.aiff silence 1 0.1 1%

ORIGINAL_CLIP_LENGTH_SECONDS=`sox word_trimmed.aiff -n stat 2>&1 | grep Length | awk '{print $3}'`
echo "clip length is ${ORIGINAL_CLIP_LENGTH_SECONDS} seconds"

DESIRED_CLIP_LENGTH_SECONDS=`echo "60.0/${BPM}.0" | bc -l`
echo "desired clip length is ${DESIRED_CLIP_LENGTH_SECONDS} seconds"


SCALE_FACTOR=`echo "${ORIGINAL_CLIP_LENGTH_SECONDS}/${DESIRED_CLIP_LENGTH_SECONDS}" | bc -l`
echo "Scale factor is ${SCALE_FACTOR}"
sox word_trimmed.aiff word_tempod.aiff tempo $SCALE_FACTOR

sox word_tempod.aiff word_1_2.aiff repeat 1
sox word_tempod.aiff word_3_4.aiff tempo 1.5 repeat 2

sox -n -r 22050  silence.aiff trim 0.0 `echo "${DESIRED_CLIP_LENGTH_SECONDS}*2" | bc`

sox word_1_2.aiff word_3_4.aiff words_repeated.aiff

say "everybody" -o everybody.aiff
EVERYBODY_LENGTH_SECONDS=`sox everybody.aiff -n stat 2>&1 | grep Length | awk '{print $3}'`
sox everybody.aiff everybody_tempod.aiff tempo `echo "${EVERYBODY_LENGTH_SECONDS}/(${DESIRED_CLIP_LENGTH_SECONDS}*3)" | bc -l`


sox -n -r 22050 silence.aiff trim 0.0 $DESIRED_CLIP_LENGTH_SECONDS

sox silence.aiff everybody_tempod.aiff everybody_final.aiff

sox words_repeated.aiff words_3x_repeated.aiff repeat 2


sox words_3x_repeated.aiff everybody_final.aiff words_final.aiff repeat 10


sox -m shots_instruments_128_bpm_sampled.aiff words_final.aiff mixed.aiff
play mixed.aiff
