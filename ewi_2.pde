import themidibus.*;

MidiBus myBus;
int y = 0;
float vel = 0;
int MIN_NOTE = 36;
int MAX_NOTE = 98;

void setup() {
//  size(1440, 900, P2D);
  size(720, 820, P2D);
  background(0);
  myBus = new MidiBus(this, 0, -1);
}

void draw() {
  background(0, 0.0, 0);

  // if (countOff >= countOn) { return; }
  colorMode(HSB, 12, 1.0, 1.0, 1.0);
  noFill();
  
  int octave = y / 12;
  float oct = norm(octave, 2, 8) * 0.5;

  float hue = y % 12 + (2.0 * bend);
  stroke(hue, 0.8, 0.8, vel);
  strokeWeight(pow(vel, 1.3) * 80);
  float ny = height - (norm(y, MIN_NOTE, MAX_NOTE) * height);
  float dy = vel * bend * 120.0;
  bezier(0, ny, 0.25 * width, ny - dy, 0.75 * width, ny - dy, width, ny); 
}

int countOn;
void noteOn(int channel, int pitch, int velocity) {
  vel = norm(velocity, 0, 127);
  y = pitch;
  countOn++;  
//  println("<on " + countOn + " channel:" + channel + " pitch:" + pitch + " velocity:" + velocity + ">");
}

int countOff;
void noteOff(int channel, int pitch, int velocity) {
  countOff++;
  vel = 0;
//  println("<off " + countOff + " channel:" + channel + " pitch:" + pitch + " velocity:" + velocity + ">");
}

void controllerChange(int channel, int number, int value) {
  if (channel == 0 && number == 2) {
    if (countOn > countOff || value == 0) {
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

