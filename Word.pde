/*
    word transcribed from google cloud speech-to-text
    with time stamps
*/

class Word {

    float in, out;
    String txt;
    // boolean active = true;
  
    // constructor
    // Word(float in_, float out_) {    
    Word(float in_, float out_, String txt_) {    
        in = in_;
        out = out_;
        txt = txt_;
    }
  
    // display
    void display() {
        fill(0);
        // fill(255);
        float duration = sample.duration();
        // float x = map(in, 0.0, duration, 0.0, width);
        int loops = 1; // [10]
        float x = map(in, 0.0, duration, 0.0, width*loops);
        float now = (float)(millis() - millis_start)/1000;
        float now_adjust = 1.0;
        // now -= now_adjust;
        if (playing)
            if ((in <= now) && (out >= now)) 
                // text(txt, x, height/8);
                text(txt, x % width, height/8);

        println(now);

        /*
        println(txt);
        println(in);
        println(x);
        */
    }
}
