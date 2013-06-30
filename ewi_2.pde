import themidibus.*;

MidiBus myBus;
int y = 0;
float vel = 0;
int MIN_NOTE = 36;
int MAX_NOTE = 98;
int SLUR_FRAMES = 8;
int slurFrame;
int slurStartFrame;
int slurStartPitch;
int slurEndPitch;

void setup() {
//  size(1440, 900, P2D);
  size(1024, 768);
  blendMode(ADD);
  smooth();
  background(0);
  myBus = new MidiBus(this, 0, -1);
  colorMode(HSB, 12, 1.0, 1.0, 1.0);
}

void draw() {
  background(0, 0.0, 0);
  slurFrame = frameCount - slurStartFrame;
  if (slurFrame >= 0 && slurFrame < SLUR_FRAMES) {
    drawSlur(slurFrame);
  } else {
    drawNote();
  }
}

void drawNote() {
  float hue = y % 12 + (2.0 * bend);
  float ny = height - (norm(y, MIN_NOTE, MAX_NOTE) * height);
  float dy = vel * bend * 120.0;
  
  noFill();
  stroke(hue, 0.8, 0.8, vel);
  strokeWeight(pow(vel, 1.3) * 80);

  bezier(0, ny, 0.25 * width, ny - dy, 0.75 * width, ny - dy, width, ny); 
}

void drawSlur(int slurFrame) {
  float n = pow(norm(slurFrame, 0, SLUR_FRAMES), 0.25);
  float y = lerp(slurStartPitch, slurEndPitch, n);

  float slurStartHue = slurStartPitch % 12 + (2.0 * bend);
  float slurStartAlpha = (1.0 - n) * vel;

  float slurEndHue = slurEndPitch % 12 + (2.0 * bend);
  float slurEndAlpha = n * vel;

  float ny = height - (norm(y, MIN_NOTE, MAX_NOTE) * height);
  float dy = vel * bend * 120.0;

  noFill();
  strokeWeight(pow(vel, 1.3) * 80);

  stroke(slurStartHue, 0.8, 0.8, slurStartAlpha);
  bezier(0, ny, 0.25 * width, ny - dy, 0.75 * width, ny - dy, width, ny);

  stroke(slurEndHue, 0.8, 0.8, slurEndAlpha);
  bezier(0, ny, 0.25 * width, ny - dy, 0.75 * width, ny - dy, width, ny);
}

int countOn;
void noteOn(int channel, int pitch, int velocity) {
  countOn++;
  if (countOn == 2) {
    slur(y, pitch);
  }
  y = pitch;
  vel = norm(velocity, 0, 127);
  println("<on " + countOn + " channel:" + channel + " pitch:" + pitch + " velocity:" + velocity + ">");
}

void slur(int from, int to) {
  println("<slur: " + from + " -> " + to + ">");
  slurStartFrame = frameCount;
  slurStartPitch = from;
  slurEndPitch = to;
}

void noteOff(int channel, int pitch, int velocity) {
  countOn--;
  if (pitch == y) {
    vel = 0;
  }
  println("<off " + countOn + " channel:" + channel + " pitch:" + pitch + " velocity:" + velocity + ">");
}

void controllerChange(int channel, int number, int value) {
  if (channel == 0 && number == 2) {
    if (countOn > 0 || value == 0) {
      vel = norm(value, 0, 127);
    }
    return;
  }
//  println("<cc " + " channel:" + channel + " number:" + number + " value:" + value + ">");  
}

float bend = 0.0;
void rawMidi(byte[] data) { // You can also use rawMidi(byte[] data, String bus_name)
  int status = (int)(data[0] & 0xFF);
  switch (status) {
  case 176: // breath velocity
    return;
  case 144: // noteOn
    return;
  case 128: // noteOff
    return;
  case 224: // pitch bend
    bend = norm(data[1] & 127 | (data[2] & 127) << 7, 0, (1 << 14) - 1) * 2.0 - 1.0;
    return;  
  }
}

