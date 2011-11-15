import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioPlayer jingle;
AudioOutput out;
MyNote newNote;

int pitch = 550;

void setup()
{
  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO);
  size(400, 400);
  background(255);
  noStroke();
}

int limitAngle(int ang) {
  if (ang <= 0) {
    return limitAngle(ang + 360);
  } 
  else if (ang <= 90) { 
    return ang * 2;
  } 
  else if (ang <= 180) { 
    return 90 * 2;
  } 
  else if (ang <= 270) { 
    return (270 - ang) * 2;
  } 
  else {
    return 0;
  }
}

void colorize(int angle) {
  int red = limitAngle((90 - angle) % 360);
  int green = limitAngle((210 - angle) % 360);
  int blue = limitAngle((330 - angle) % 360);
  fill(red, green, blue);
  stroke(red, green, blue);
}

void draw() {
  if (frameCount % 2 == 0) {
    float angle = atan2(mouseY - 200, mouseX - 200) - PI/4;
    // Following will Quantize
    // angle = (int)(angle / PI * 6) * PI / 6; 
    int colorBase = (int)degrees(angle);
    //    colorBase = frameCount % 180;
    background(255);
    colorize(colorBase);
    pushMatrix();
    translate(200, 200);
    rotate(radians(colorBase));
    line(0, 0, 100, 100);
    ellipse(100, 100, 32, 32);
    popMatrix();
    if (newNote != null) {
      int newPitch = (int)(261.63*pow(2, colorBase / 360.0));
      newNote.setPitch(newPitch);
    }
  }
  if (pitch > 0) {
    newNote = new MyNote(pitch, 5);
    pitch = 0;
  }
}

class MyNote implements AudioSignal
{
  private float freq;
  private float level;
  private float alph;
  private SineWave sine;

  MyNote(float pitch, float amplitude)
  {
    freq = pitch;
    level = amplitude;
    sine = new SineWave(freq, level, out.sampleRate());
    alph = 0.98;  // Decay constant for the envelope
    out.addSignal(this);
  }

  void updateLevel()
  {
    // Called once per buffer to decay the amplitude away
    level = level * alph;
    sine.setAmp(level);

    // This also handles stopping this oscillator when its level is very low.
    if (level < 0.01) {
      out.removeSignal(this);
    }
    // this will lead to destruction of the object, since the only active 
    // reference to it is from the LineOut
  }

  void generate(float [] samp)
  {
    // generate the next buffer's worth of sinusoid
    sine.generate(samp);
    // decay the amplitude a little bit more
    //updateLevel();
  }

  // AudioSignal requires both mono and stereo generate functions
  void generate(float [] sampL, float [] sampR)
  {
    sine.generate(sampL, sampR);
    //updateLevel();
  }

  void setPitch(int pitch) {
    this.freq = pitch;
    sine.setFreq(pitch);
  }
}

