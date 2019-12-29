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

CLIP_TOO_LONG=`echo "$DESIRED_CLIP_LENGTH_SECONDS < $ORIGINAL_CLIP_LENGTH_SECONDS" | bc`

if [ $CLIP_TOO_LONG -gt 0 ]; then
	echo "Clip is too long!"
	SCALE_FACTOR=`echo "${ORIGINAL_CLIP_LENGTH_SECONDS}/${DESIRED_CLIP_LENGTH_SECONDS}" | bc -l`
	echo "Scale factor is ${SCALE_FACTOR}"
	sox word_trimmed.aiff word_tempod.aiff tempo $SCALE_FACTOR



fi

sox word_tempod.aiff word_repeated.aiff repeat 50
sox -m shots_instruments_128_bpm_sampled.aiff word_repeated.aiff mixed.aiff
play mixed.aiff
