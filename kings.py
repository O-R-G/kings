from dotenv import load_dotenv
from google.cloud import speech_v1 as speech
from moviepy import VideoFileClip
import os
from pydub import AudioSegment
import wave
import json
# Load the .env file
load_dotenv()

# Get the API key
api_key_path = os.getenv("GOOGLE_CLOUD_API_KEY_PATH")
output = {
    "response": {
        "results": []
    }
}
with wave.open("data/speech.wav", "rb") as wav_file:
    sample_rate = wav_file.getframerate()
    print(f"sample rate: {sample_rate}")

client = speech.SpeechClient.from_service_account_file(api_key_path)


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
            sample_rate_hertz = sample_rate,
            language_code = "en-US",
            enable_word_time_offsets=True
        )
        response = client.recognize(config=config, audio=audio)
    response_dict = speech.RecognizeResponse.to_dict(response)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(response_dict, f, ensure_ascii=False, indent=2)


convert_to_mono("data/speech.wav", "mono.wav")
transcribe_audio("mono.wav", "data/speech.json")