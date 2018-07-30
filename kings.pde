/**
 * Processing Sound Library, Example 5
 * 
 * This sketch shows how to use the FFT class to analyze a stream  
 * of sound. Change the variable bands to get more or less 
 * spectral bands to work with. The smooth_factor variable determines 
 * how much the signal will be smoothed on a scale form 0-1.
 */

import processing.sound.*;

SoundFile sample;
// FFT fft;
Amplitude rms;
LowPass lowpass;
AudioDevice device;
JSONObject json;
PFont mono;

Word[] words;           // array of Word objects

String[] txt;           // speech fragments as text string
int[] speech_in;        // audio in per speech fragment
int[] speech_out;       // audio out per speech fragment
int[][] speech;         // audio in & out per speech fragment

int millis_start = 0;

Boolean playing = false;
Boolean bar = true;
Boolean circle = false;
Boolean spectrum = false;
Boolean wave = false;
Boolean text = false;
Boolean process = false;
Boolean speech_flag = false;
int counter = 0;
int bands = 128;                    // FFT bands (multiple of sampling rate)
int granularity = 3;
int in = 0;
int out = 0;
int speech_counter;
int silence_min = 30;      // [10]
float scale = 5.0;
float r_width;
float sum_rms;
// float[] sum_fft = new float[bands];     // smoothing vector
// float smooth_factor = 0.25;          // smoothing factor
float smooth_factor = 0.175;          // smoothing factor
float playback_rate = 1.0;
float amp_floor = 0.04; // 0.02 0.04 [0.08]
String text_markup = " .I come to this magnificent house of worship tonight,because my conscience leaves me no other choice.I join you in this meeting because I'm in deepest agreement,with the aims and work,of the organization which has brought us together:Clergy and Laymen Concerned About Vietnam.";
String speech_src = "speech.wav";
String txt_src = "txt.json";

void setup() {
    // size(640, 360);
    size(1080, 360);
    frameRate(60);
    background(204);
    speech_in = new int[0];
    speech_out = new int[0];
    mono = createFont("Artisan12.ttf", 14);
    textFont(mono);
    device = new AudioDevice(this, 44000, bands);
    r_width = width/float(bands);

    // sample = new SoundFile(this, "martin-edit.aiff");
    // sample = new SoundFile(this, "mountain-excerpt.wav");
    // sample = new SoundFile(this, "mountaintop-trim-60.wav");
    // sample = new SoundFile(this, "mountaintop-trim-60.flac");
    // sample = new SoundFile(this, "mountaintop.flac");
    // sample = new SoundFile(this, "mountaintop.wav");
    // sample = new SoundFile(this, "mountain-excerpt.flac");
    // sample = new SoundFile(this, "mountaintop-trim.wav");
    // sample = new SoundFile(this, "mountaintop-trim.flac");

    sample = new SoundFile(this, speech_src);
    load_gc_json(txt_src);

    // load_gc_json("mountain-excerpt.json");
    // load_gc_json("mountaintop-trim-60.json");
    // load_gc_json("mountaintop.json");

    Boolean processed_text = process_text();
    println("READY ...");
        
    // play_sample();

    // exec command in terminal
    // exec("/usr/bin/say", "Ready ...");
    // exec("/bin/bash", "GOOGLE_APPLICATION_CREDENTIALS='/Users/reinfurt/Applications/Kings speech-to-text-cb6be9604529.json'");
    // exec("/Users/reinfurt/Applications/google-cloud-sdk/bin/gcloud", "ml speech recognize /Users/reinfurt/mountain-longevity.flac --language-code='en-US' > ok.json");
}

void draw() {
    /*
    if (counter*granularity%width == 0 || bar || circle)
        background(204);
    */

    background(204);
    fill(0);
    noStroke();
        
    for (Word w : words) {
        w.display();
    }
    
    if (playing) {
        // sample.pan(map(mouseX, 0, width, -1.0, 1.0));
        // sample.amp(map(mouseX, 0, width, 0.0, 1.0));
        /*
        fft.analyze();
        for (int i = 0; i < bands; i++) {
            sum_fft[i] += (fft.spectrum[i] - sum_fft[i]) * smooth_factor;
            rect( i*r_width, height, r_width, -sum_fft[i]*height*scale );
        }
        */

        // rms.analyze() returns value between 0 and 1
        // scaled to height/2 and then multiplied by a scale factor
        sum_rms += (rms.analyze() - sum_rms) * smooth_factor;  
        float rms_scaled = sum_rms * (height/2) * scale;

        if (process) {
            if (text)
                text(txt[speech_counter%7], 20, speech_counter*20);
                // text(txt[speech_counter].charAt(counter%txt[speech_counter].length()), 16*(counter%txt[speech_counter].length()), speech_counter*20);
                // x += textWidth(message.charAt(i))
                // this will be the txt incrementer but
                // for now, just one character at a time
                // int txt_increment = (counter - counter_in) / txt[speech_counter].length();

            // all of this to go into int[][] set_speech()
            // in = counter;

            if (sum_rms > amp_floor) {            
                if (counter - out > silence_min) {
                    if (!speech_flag) {                        
                        fill(0);
                        speech_flag = true;
                        speech_counter++;
                        in = counter;
                        println("+");
                        println(speech_counter);
                        println("> in : " + in);
                    }
                println("speaking . . . " + speech_counter);
                }
            } else {
                // println(counter - in);
                // println("silence");
                if (counter - in > silence_min) {
                    fill(255,255,0);
                    rect(counter*granularity%width, 0, granularity, height);
                    if (speech_flag) { 
                        speech_flag = false;
                            out = counter;
                            speech_in = append(speech_in, in);
                            speech_out = append(speech_out, out);    
                            println("> out : " + out);
                    }
                println("-- silence -- " + speech_counter);
                }
            }
        } 

        if (bar)
            rect(0, 0, rms_scaled, 10);
        if (circle)
            ellipse(width/2, height/2, rms_scaled, rms_scaled);
        if (wave)
            rect(counter*granularity%width, 360-rms_scaled, granularity, rms_scaled);
    }

    // println(sample.frames());
    counter++;
}

void keyPressed() {
    switch(key) {
        case 'b': 
            if (!playing)
                play_sample();
            bar = !bar;
            break;
        case 'c': 
            if (!playing)
                play_sample();
            circle = !circle;
            break;
        case 't': 
            text = !text;
            break;
        case 'w': 
            if (!playing)
                play_sample();
            wave = !wave;
            break;
        case ' ': 
            if (!playing)
                play_sample();
            else
                stop_sample();
            break;
        case '.': 
            stop_sample();
            break;
        case '=': 
            if (playing) {
                playback_rate += .1;
                sample.rate(playback_rate);
                break;
            }
        case '-': 
            if (playing) {
                playback_rate -= .1;
                sample.rate(playback_rate);
                break;
            }
        case 'p': 
            if (!playing) 
                play_sample();
            bar = false;
            circle = false;
            spectrum = false;
            wave = true;
            process = !process;
            break;        
        default:
            break;
    }
    switch(keyCode) {
        case UP:
            if (amp_floor < .99)
                amp_floor+=.01;
            background(204);
            rect(0,height - (amp_floor * height),width,1);
            println(amp_floor);
            break;        
        case DOWN:
            if (amp_floor > .01)
                amp_floor-=.01;        
            background(204);
            rect(0,height - (amp_floor * height),width,1);
            println(amp_floor);
            break;        
        case LEFT:
            if (granularity > 1)
                granularity--;
            background(204);
            break;        
        case RIGHT:
            if (granularity < width/4)
                granularity++;
            background(204);
            break;        
        default:
            break;
    }
}

Boolean play_sample() {
        // cue to 0, play (loop)
        // load sample, initialize fft and rms
        // then cue to start
        // lowpass = new LowPass(this);
        sample.cue(0);
        sample.loop();
        // lowpass.process(sample, 800);
        // fft = new FFT(this, bands);
        // fft.input(sample);
        rms = new Amplitude(this);
        rms.input(sample);
        playing = true;
        counter = 0;
        speech_counter = 0;
        in = 0;
        out = 0;
        millis_start = millis();
        return true;
}

Boolean stop_sample() {
        // stop (cue to 0?)
        playing = false;
        sample.stop();
        return true;
}

Boolean process_text() {   
    txt = splitTokens(text_markup, ",.:");
    printArray(txt);
    return true;
}

Boolean load_gc_json(String filename) {

    // parse json endpoint from google cloud speech-to-text api

    json = loadJSONObject(filename);
    JSONArray json_results = json.getJSONArray("results");

    words = new Word[0];

    for (int i = 0; i < json_results.size(); i++) {

        JSONObject r = json_results.getJSONObject(i); 
        JSONArray json_alternatives = r.getJSONArray("alternatives");

        for (int j = 0; j < json_alternatives.size(); j++) {

            JSONObject a = json_alternatives.getJSONObject(j); 
            float confidence = a.getFloat("confidence");
            String transcript = a.getString("transcript");
            JSONArray json_words = a.getJSONArray("words");

            Word[] words_a;           
            words_a = new Word[json_words.size()]; 

            for (int k = 0; k < json_words.size(); k++) {

                JSONObject w = json_words.getJSONObject(k); 
                float in = float(w.getString("startTime").replace("s",""));
                float out = float(w.getString("endTime").replace("s",""));
                String txt = w.getString("word");

                // new word object to array
                // words[k] = new Word(in, out, txt);
                words_a[k] = new Word(in, out, txt);

                /* 
                println(words[k].in);
                println(words[k].out);
                println(words[k].txt);
                */
            }

            // populate words[]
            for (Word w_a : words_a) {
                words = (Word[])append(words, w_a);
            }
        }
    }
    return true;
}


    
