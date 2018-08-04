/*
    word transcribed from google cloud speech-to-text
    with time stamps
*/

class Word {

    String txt;
    float in, out, width;
    Boolean spoken = false;
    // float duration = sample.duration();

    Word(float in_, float out_, String txt_) {    
        in = in_;
        out = out_;
        txt = txt_;
        width = textWidth(this.txt);
    }
  
    Boolean spoken() {
        float now = (float)(millis() - millis_start)/1000;
        if (playing)
            if ((in <= now)) 
                return true;
            else 
                return false;
        else
            return false;
    }

    void display(int fill, int _x, int _y) {
        fill(fill);
        // float x = map(in, 0.0, duration, 0.0, width);
        text(txt, _x, _y);
    }
}

