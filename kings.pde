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
Boolean lastwordspoken = false;
int counter = 0;
int bands = 128;                    // FFT bands (multiple of sampling rate)
int granularity = 3;
int in = 0;
int out = 0;
int speech_counter;
int silence_min = 30;      // [10]
int _x;   
int _y;
float scale = 5.0;
float r_width;
float sum_rms;
float[] sum_fft = new float[bands];   // smoothing vector
float smooth_factor = 0.175;          // smoothing factor
float playback_rate = 1.0;
float amp_floor = 0.04; // 0.02 0.04 [0.08]
float _space; 
float _leading; 
String text_markup = " .I come to this magnificent house of worship tonight,because my conscience leaves me no other choice.I join you in this meeting because I'm in deepest agreement,with the aims and work,of the organization which has brought us together:Clergy and Laymen Concerned About Vietnam.";
String speech_src = "speech.wav";
String txt_src = "txt.json";

void setup() {
    size(400, 800);
    // size(1200, 200);
    smooth();
    frameRate(60);
    mono = createFont("Speech-to-text-normal.ttf", 18);
    textFont(mono);
    _x = 0;   
    _y = height/8;
    _space = textWidth(" "); 
    _leading = 22;
    device = new AudioDevice(this, 44000, bands);
    r_width = width/float(bands);
    sample = new SoundFile(this, speech_src);
    load_gc_json(txt_src);
    Boolean processed_text = process_text();
    println("READY ...");
}

void draw() {
    /*
    fill(0,100);
    rect(0,0,width,height);
    */
    background(0);
    fill(255);
    noStroke();

    // ** still dont have the line by line brick by brick working **
    // need to know when it is the last word spoken and only then
    // increment the _y, otherwise always cranking up the value
    // Boolean should prob be in global scope 

    _x = 0;
    // Boolean lastwordspoken = false;
    lastwordspoken = false;
    
    for (Word w : words) {
        // if (!lastwordspoken) {
            if (w.spoken() && !lastwordspoken) { 
                w.display(255, _x % width, _y + height/8);
                _x += (w.width + _space);
            } else if (!lastwordspoken) {
                if ((_x % width + w.width > width))
                    _y += _leading;
                lastwordspoken = true;
            }
        // }
    }

    if (playing) {
        /*
        fft.analyze();
        for (int i = 0; i < bands; i++) {
            sum_fft[i] += (fft.spectrum[i] - sum_fft[i]) * smooth_factor;
            rect( i*r_width, height, r_width, -sum_fft[i]*height*scale );
        }
        */
        // rms.analyze() returns value between 0 and 1
        sum_rms += (rms.analyze() - sum_rms) * smooth_factor;  
        float rms_scaled = sum_rms * (height/2) * scale;

        if (bar)
            rect(0, 0, rms_scaled, 10);
        if (circle)
            ellipse(width/2, height/2, rms_scaled, rms_scaled);
        if (wave)
            rect(counter*granularity%width, height-rms_scaled, granularity, rms_scaled);
    }
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
    // txt = splitTokens(text_markup, ",.:");
    // txt = join(words, " ");
    // txt = ["hello..........","o"];

    txt = splitTokens("OK, ready", ",.:");
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

void stroke_text(String text, int weight, int x, int y) {

    // see https://forum.processing.org/two/discussion/16700/how-to-outline-text

    int value = 255 - (weight * 50);
    /*
    fill(value);
    for (int i = -1; i < 2; i++) {
    // for (int i = -weight; i <= weight; i++) {
        text(text, x+i, y);
        text(text, x, y+i);
    }
    */
    fill(value);
    text(text, x, y);
}

