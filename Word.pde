/*
    word transcribed from google cloud speech-to-text
    with time stamps
*/

class Word {

    String txt;
    float in, out;
    float width;
    int length;
    Boolean spoken = false;
    float opacity = 0.0;    // how to set float as null?

    // float duration = sample.duration();

    Word(float in_, float out_, String txt_) {    
        in = in_;
        out = out_;
        txt = txt_;
        width = textWidth(this.txt);
        length = txt.length();
    }
  
    Boolean speaking() {
        float now = (float)(millis() - millis_start)/1000;
        if ((in <= now) && (out >= now)) 
            return true;
        else 
            return false;
    }

    Boolean spoken() {
        float now = (float)(millis() - millis_start)/1000;
        if ((in <= now)) 
            return true;
        else 
            return false;
    }

    void display(int fill, int _x, int _y) {
        // rms.analyze() returns [0 ... 1]
        // this changes throughout, not persistent word to word
        // maybe need to process audio first to get amps
        println(rms.analyze());
        if (opacity == 0.0)
            opacity = map(rms.analyze(), 0.0, 0.05, 100.0, 255.0);
        fill(fill, int(opacity));
        text(txt, _x, _y);
    }
}

