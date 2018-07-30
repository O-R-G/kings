#!/bin/bash

# google cloud speech to text implemented with processing front end
# (google cloud services account free 365-day trial)
# https://cloud.google.com/speech-to-text/docs/
# gc project kings-speech-to-text, gc bucket kings-speech-to-text 
# authentication key as bash environment variable

KEY="/Users/reinfurt/Documents/Projects/KINGS/software/google cloud platform/json/auth/kings-speech-to-text-cb6be9604529.json"
IN=data/speech.wav
OUT=data/speech.wav
TMP=data/speech-16k.wav
JSON=data/txt.json	
BUCKET=gs://kings-speech-to-text

while [ "$1" != "" ]; do
    case $1 in
        -i | --in )		    shift
                                IN=$1;;
        -k | --key )		shift
                                KEY=$1;;
        -h | --help )           echo -e "\
Usage: kings [OPTION]... [FILE]...
Submit google cloud speech-to-text recognize request, returns .json. \
Run kings.pde using returned speech.wav & txt.json. \
Input audio files can be any format that ffmpeg can handle.

  -i, --in              input file [unused?]
  -k, --key		        path/to/ gcloud authentication .json
"
        exit;;
    esac
    shift
done

#
#   0.  authenticate
#

echo "authenticate ..."

export GOOGLE_APPLICATION_CREDENTIALS=$KEY

#
#   1.  process audio (ffmpeg) to gcloud speech-to-text format
#       .wav (PCM linear16 encoding) mono 16k
#       .flac (format & encoding) mono 16k
#       output 16k for gcloud recognize ($TMP)
#       and 44.1k for processing ($OUT)
#

echo "process audio ..."

#   which method is more accurate, faster?
#   process each separate

ffmpeg -i $IN -acodec pcm_s16le -ac 1 -ar 16000 $TMP
ffmpeg -i $IN -acodec pcm_s16le -ac 1 -ar 44100 $OUT

# ffmpeg -i $IN -acodec pcm_s16le -ac 1 -ar 44100 $OUT
# ffmpeg -i $OUT -ar 16000 $TMP

# rm $TMP
	
#
#   2.  upload audio to gc bucket (> 1:00) or local (< 1:00)
#
#   include commandline flag for long-running

gsutil cp $TMP $BUCKET

#
#   3.  gcloud speech recognize, return data/txt.json
#       ** need to add case for recognize-long-running w/flag **
#   

echo "gcloud recognize ..."

# gcloud ml speech recognize $TMP --include-word-time-offsets --language-code='en-US' --hints=paced > $JSON
# gcloud ml speech recognize-long-running '$BUCKET/$TMP' --include-word-time-offsets --language-code='en-US' > $JSON
gcloud ml speech recognize-long-running 'gs://kings-speech-to-text/speech-16k.wav' --include-word-time-offsets --language-code='en-US' > $JSON

#
#   4.  run .pde using data/txt.json and data/speech.wav
#       (processing wants data/speech.wav to be 44.1k)
#       ** unimplemented **
#

echo "launch processing ..."

pjava .
	
echo "** done **"


