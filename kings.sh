#!/bin/bash

# google cloud speech to text implemented with processing front end
# (google cloud services account free 365-day trial)
# https://cloud.google.com/speech-to-text/docs/
# gc project kings-speech-to-text, gc bucket kings-speech-to-text
# authentication key as bash environment variable

INPUT=""

# Help text
show_help() {
  echo -e "\
    Usage: kings [OPTION]... [FILE]...
    Submit google cloud speech-to-text recognize request, returns .json.
    Run kings.pde using returned speech.wav & txt.json.
    Input audio files can be any format that ffmpeg can handle.

      -i, --in              input file
      -h, --help            instructions
    "
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--input)
      if [[ -n "$2" && "$2" != -* ]]; then
        INPUT="$2"
        shift 2
      else
        echo "Error: --input requires a non-empty argument."
        exit 1
      fi
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Check if input was provided
if [[ -z "$INPUT" ]]; then
  echo "Error: Input file not specified."
  show_help
  exit 1
fi

filename=$(basename -- "$INPUT")
extension="${filename##*.}"
filename="${filename%.*}"

OUT=data/$filename.wav

TMP_16=data/temp-16k.wav
TMP_44=data/temp-44k.wav

#
#   1.  process audio (ffmpeg) to gcloud speech-to-text format
#       .wav (PCM linear16 encoding) mono 16k
#       .flac (format & encoding) mono 16k
#       output 16k for gcloud recognize ($TMP_16)
#       and 44.1k for processing ($OUT)
#

echo "process audio ..."

#   which method is more accurate, faster?
#   process each separate

ffmpeg -i $INPUT -acodec pcm_s16le -ac 1 -ar 16000 $TMP_16
ffmpeg -i $INPUT -acodec pcm_s16le -ac 1 -ar 44100 $TMP_44

#rm $TMP_16
#rm $TMP_44

# https://gist.github.com/cjus/1047794
#function jsonValue() {
#KEY=$1
#num=$2
#awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
#}

# https://cloud.google.com/speech-to-text/docs/reference/rest/v1p1beta1/RecognitionConfig
#NAME=$(curl -sS -H "Content-Type: application/json" \
#    -H "Authorization: Bearer "$(gcloud auth print-access-token) \
#    https://speech.googleapis.com/v1p1beta1/speech:longrunningrecognize \
#    --data '{
#  "config": {
#    "languageCode": "en-US",
#    "enableWordTimeOffsets": true,
#    "enableAutomaticPunctuation": true,
#    "useEnhanced": true,
#    "model": "video",
#    "speechContexts":{
#        "phrases": [""]
#    },
#    "metadata": {
#      "interactionType": "PRESENTATION",
#      "audioTopic": "Martin Luther King Jr."
#    }
#  },
#  "audio": {
#    "uri":"'$BUCKET'/speech-16k.wav"
#  }
#}' | jsonValue name)
#
#NAME=$(echo $NAME)
#
#echo "submit job with id "$NAME" ..."
#
#RESPONSE=""
#OUTPUT=""
#RESPONSELENGTH="$(echo $RESPONSE | wc -w | tr -d ' ')"
#while [ $RESPONSELENGTH -lt 1 ]
#do
#  OUTPUT=$(curl -sS -H "Content-Type: application/json" \
#      -H "Authorization: Bearer "$(gcloud auth print-access-token) \
#    https://speech.googleapis.com/v1/operations/$NAME)
#  RESPONSE=$(echo ${OUTPUT} | jsonValue response)
#  RESPONSELENGTH="$(echo $RESPONSE | wc -w | tr -d ' ')"
#  echo "wait ..."
#  sleep 2
#done
#echo 'received translation ...'
#echo $OUTPUT > $JSON

#
#   4.  run .pde using data/txt.json and data/speech.wav
#       (processing wants data/speech.wav to be 44.1k)
#       ** unimplemented **
#
#
#echo "launch processing ..."
#
#pjava .
#
#echo "** done **"
