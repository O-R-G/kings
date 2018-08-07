/*
    word transcribed from google cloud speech-to-text
    with time stamps
*/

class Word {

    String txt;
    int length;
    float in, out;
    float width;
    float opacity;
    Boolean spoken;
    // float duration = sample.duration();

    Word(float in_, float out_, String txt_) {    
        in = in_;
        out = out_;
        txt = txt_;
        width = textWidth(this.txt);
        length = txt.length();
        opacity = 0.0;    
        spoken = false;
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

    /*
    float opacity(float value) {
        if (opacity == 0.0)
            // opacity = map(rms.analyze(), 0.0, 0.05, 100.0, 255.0);
            opacity = map(rms.analyze(), 0.0, 0.05, 100.0, 255.0);
    }
    */

    void display(int fill, int _x, int _y) {
        // rms.analyze() returns [0 ... 1]
        // this changes throughout, not persistent word to word
        // maybe need to process audio first to get amps
        // println(rms.analyze());
        if (opacity == 0.0)
            opacity = map(rms.analyze(), 0.0, 0.05, 100.0, 255.0);
        fill(fill, int(opacity));
        // ** for now, but would be better as parameter 
        // just unsure what to call it **
        // maybe separate function for set opacity and another for display
        if (PDFoutput)
            text(txt, _x, _y);
    }
}

