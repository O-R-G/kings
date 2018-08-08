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

    void opacity(float value) {
        if (opacity == 0.0)
            opacity = map(value, 0.0, 0.05, 100.0, 255.0);
    }

    void display(int fill, int _x, int _y) {
        fill(fill, int(opacity));
        text(txt, _x, _y);
    }
}
