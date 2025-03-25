#!/usr/bin/env python3

import argparse
import sys
import ffmpeg
from dotenv import load_dotenv
from google.cloud import speech_v1 as speech
import os
import subprocess  # ← required for running shell commands
from pydub import AudioSegment
import json

# Load the .env file
load_dotenv()

# Get the API key
api_key_path = os.getenv("GOOGLE_CLOUD_API_KEY_PATH")

# Create the Google Cloud client
client = speech.SpeechClient.from_service_account_file(api_key_path)

# Help text and description
DESCRIPTION = """\
Submit Google Cloud Speech-to-Text recognize request, returns .json.
Run kings.pde using returned speech.wav & txt.json.
Input audio files can be any format that ffmpeg can handle.
"""


def convert_audio(input_file, output_file, sample_rate):
    try:
        (
            ffmpeg
            .input(input_file)
            .output(output_file, acodec='pcm_s16le', ac=1, ar=sample_rate)
            .run(overwrite_output=True)
        )
        print(f"Saved {sample_rate}Hz file to {output_file}")
    except ffmpeg.Error as e:
        print(f"ffmpeg error:\n{e.stderr.decode()}")
        sys.exit(1)


def combine_video_and_audio(video_path, audio_path, output_path):
    try:
        video_stream = ffmpeg.input(video_path)
        audio_stream = ffmpeg.input(audio_path)
        (
            ffmpeg
            .output(video_stream, audio_stream, output_path, vcodec='copy', acodec='aac', shortest=None)
            .run(overwrite_output=True)
        )
        print(f"Combined video + audio saved to {output_path}")
    except ffmpeg.Error as e:
        print(f"Error combining video and audio:\n{e.stderr.decode()}")
        sys.exit(1)


def convert_to_mono(input_file, output_file):
    audio = AudioSegment.from_file(input_file)
    audio = audio.set_channels(1)
    audio.export(output_file, format="wav")
    print('Converted to mono')


def transcribe_audio(input_file, output_file):
    with open(input_file, 'rb') as audio_file:
        content = audio_file.read()
        audio = speech.RecognitionAudio(content=content)
        config = speech.RecognitionConfig(
            encoding = speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz = 16000,
            language_code = "en-US",
            enable_word_time_offsets=True
        )
        response = client.recognize(config=config, audio=audio)
    response_dict = speech.RecognizeResponse.to_dict(response)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(response_dict, f, ensure_ascii=False, indent=2)


def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(
        description=DESCRIPTION,
        usage="kings [-i INPUT_FILE]"
    )
    parser.add_argument(
        "-i", "--input",
        required=True,
        help="input file"
    )

    args = parser.parse_args()
    input_file = args.input

    if not os.path.isfile(input_file):
        print(f"Error: File not found — {input_file}")
        sys.exit(1)

    # with wave.open(input_file, "rb") as wav_file:
    #     sample_rate = wav_file.getframerate()
    #     print(f"sample rate: {sample_rate}")

    filename = os.path.basename(input_file)
    name, _ = os.path.splitext(filename)

    print("process audio ...")
    # Prepare output paths
    os.makedirs("data", exist_ok=True)
    filepath_wav_16 = f"data/speech-16k.wav"
    filepath_wav_16_mono = f"data/speech-16k-mono.wav"
    filepath_wav_44 = f"data/speech-44k.wav"
    filepath_mp4_silent = f"data/speech-silent.mp4"
    filepath_json = "data/speech.json"
    filepath_output = "data/output.mp4"
    # for google speech-to-text api
    convert_audio(input_file, filepath_wav_16, 16000)
    # for processing
    convert_audio(input_file, filepath_wav_44, 44100)

    convert_to_mono(filepath_wav_16, filepath_wav_16_mono)
    transcribe_audio(filepath_wav_16_mono, filepath_json)

    # Step 5: Run Processing sketch if JSON was created
    if os.path.exists(filepath_json):
        print("speech.json created successfully. Launching Processing sketch...")
        try:
            subprocess.run(
                ["processing-java", "--sketch=" + os.getcwd(), "--run"],
                check=True
            )

        except subprocess.CalledProcessError as e:
            print(f"Error running Processing sketch:\n{e}")
            sys.exit(1)

        combine_video_and_audio("data/speech-silent.mp4", filepath_wav_44, filepath_output)
        print("removing files...")
        os.remove(filepath_wav_16)
        os.remove(filepath_wav_44)
        os.remove(filepath_wav_16_mono)
        os.remove(filepath_json)
        os.remove(filepath_mp4_silent)
    else:
        print("Error: speech.json not found. Skipping Processing sketch.")


if __name__ == "__main__":
    main()
