/**
 * Processing Sound Library, Example 5
 * 
 * This sketch shows how to use the FFT class to analyze a stream  
 * of sound. Change the variable bands to get more or less 
 * spectral bands to work with. The smooth_factor variable determines 
 * how much the signal will be smoothed on a scale form 0-1.
 */

import processing.sound.*;
import processing.pdf.*;

SoundFile sample;
FFT fft;
Amplitude rms;
AudioDevice device;
JSONObject json;
PFont mono;

Word[] words;           // array of Word objects
String[] txt;           // speech fragments as text string

int millis_start = 0;
Boolean playing = false;
Boolean bar = true;
Boolean circle = false;
Boolean spectrum = false;
Boolean wave = false;
Boolean speech_flag = false;
Boolean lastwordspoken = false;
int counter = 0;
int bands = 128;                    // FFT bands (multiple of sampling rate)
int granularity = 3;
int in = 0;
int out = 0;
int silence_min = 30;               // [10]
int box_x, box_y, box_w, box_h;     // text box origin 
float scale = 5.0;
float r_width;
float sum_rms;
float[] sum_fft = new float[bands];   // smoothing vector
float smooth_factor = 0.175;          // smoothing factor
float playback_rate = 1.0;
float amp_floor = 0.04; // 0.02 0.04 [0.08]
float _space; 
float _leading; 
String speech_src = "speech.wav";
String txt_src = "txt.json";

void setup() {
    // size(400, 800);
    // size(1200, 200);
    size(425, 550);
    smooth();
    frameRate(60);
    mono = createFont("Speech-to-text-normal.ttf", 18);
    textFont(mono);
    _space = textWidth(" "); 
    _leading = 24;
    box_x = 20;
    box_y = 40;
    box_w = width - box_x * 2;
    box_h = height - box_y * 2;
    device = new AudioDevice(this, 44000, bands);
    r_width = width/float(bands);
    sample = new SoundFile(this, speech_src);
    load_gc_json(txt_src);
    println("READY ...");
}

void draw() {
    background(0);
    fill(255);
    noStroke();

    if (playing && ((millis() - millis_start) >= sample.duration() * 1000))
        stop_sample();
    
    int _x = 0;
    int _y = 0;

    if (playing) {

        // rms.analyze() returns [0 ... 1]
        sum_rms += (rms.analyze() - sum_rms) * smooth_factor;  
        float rms_scaled = sum_rms * (height/2) * scale;

        float float_fill = map(rms.analyze(), 0.0, 0.5, 0.0, 255.0);
        fill(int(float_fill));

        // float x = map(in, 0.0, duration, 0.0, width);


        for (Word w : words) {
            if (w.spoken()) { 
                // w.display(255, _x + box_x, _y + box_y);
                w.display(int(float_fill), _x + box_x, _y + box_y);
                if (!(_x + w.width > box_w)) {
                    _x += (w.width + _space);
                } else {
                    _x = 0;
                    _y += _leading;
                }
            }
        }

        if (bar)
            rect(0, 0, rms_scaled, 10);
        if (circle)
            ellipse(width/2, height/2, rms_scaled, rms_scaled);
        if (wave)
            rect(counter*granularity%width, height-rms_scaled, granularity, rms_scaled);
        /*
        if (spectrum) {
            fft.analyze();
            for (int i = 0; i < bands; i++) {
                sum_fft[i] += (fft.spectrum[i] - sum_fft[i]) * smooth_factor;
                rect( i*r_width, height, r_width, -sum_fft[i]*height*scale );
            }
        }
        */

    }
    counter++;
}

void keyPressed() {
    switch(key) {
        case 'b': 
            play_sample();
            bar = !bar;
            break;
        case 'c': 
            play_sample();
            circle = !circle;
            break;
        case 'w': 
            play_sample();
            wave = !wave;
            break;
        case 's': 
            play_sample();
            spectrum = !spectrum;
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
            beginRecord(PDF, "out.pdf");
            break;
        case 'q': 
            endRecord();
            exit();
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
    if (!playing) {
        in = 0;
        out = 0;
        counter = 0;
        millis_start = millis();
        // sample.play();   // always throws error on exit (bug)
        sample.loop();      // so use .loop() instead
        /*
        // not working, likely to do w/bands and sample rate
        fft = new FFT(this, bands);
        fft.input(sample);
        */
        rms = new Amplitude(this);
        rms.input(sample);           
        playing = true;
        return true;
    } else {
        return false;
    }
}

Boolean stop_sample() {
    playing = false;        
    // rms = null;
    sample.stop();  
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

