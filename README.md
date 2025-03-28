2025-03-28

# prerequisite

- install the requirements
- install video_export_processing (https://github.com/hamoid/video_export_processing/tree/kotlinGradle)
- add .env with a variable "GOOGLE_CLOUD_API_KEY_PATH" in the root project directory. GOOGLE_CLOUD_API_KEY_PATH is the path to the google api key

# execution

    python3 kings.py -i path/to/input.wav

or 

    python kings.py -i path/to/input.wav

the output.mp4 will be placed in data/ after generated.

# workflow

kings.py is the entry point of the application. here's the workflow:
1. finds the input file and converts it to two audio files: 16000 (for google api) and 44100 hertz (for processing).
2. convert the 16000 hz one into a mono channel, send it to google, and save the response as a json (data/speech.json). i don't think it uses a vtt file anymore. 
3. kings.pde is called. it uses the 44100hz audio file and the transcript json to generate the video. at this moment, the video is muted.
4. back to king.py. it merges the muted video and the 44100hz audio file and makes the output.mp4. 
5. remove all the intermediate files.