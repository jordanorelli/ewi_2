import themidibus.*;

MidiBus myBus;
int y = 0;
int vel = 0;

void setup() {
  size(720, 840, P2D);
  background(0);
  myBus = new MidiBus(this, 0, -1);
}

void draw() {
  background(0);
  float ny = norm(y, 36, 98) * height;
  stroke(180, 180, 180, vel);
  strokeWeight(pow(norm(vel, 0, 127), 2) * 40);
  line(0, height - ny, width, height - ny);
  
//  stroke(255);
//  strokeWeight(4);
//  pushMatrix();
//  translate(width * 0.5, height);
//  rotate(TWO_PI * 0.5 * (bend - 0.5));
//  line(0, 0, 0, -200);  
//  popMatrix();
}

int countOn;
void noteOn(int channel, int pitch, int velocity) {
  countOn++;
  y = pitch;
  println("<on " + countOn + " channel:" + channel + " pitch:" + pitch + " velocity:" + velocity + ">");
}

int countOff;
void noteOff(int channel, int pitch, int velocity) {
  countOff++;
  println("<off " + countOff + " channel:" + channel + " pitch:" + pitch + " velocity:" + velocity + ">");
}

void controllerChange(int channel, int number, int value) {
  if (channel == 0 && number == 2) {
    vel = value * 2;
    return;
  }
  println("<cc " + " channel:" + channel + " number:" + number + " value:" + value + ">");  
}

float bend = 0.5;
void rawMidi(byte[] data) { // You can also use rawMidi(byte[] data, String bus_name)
  int status = (int)(data[0] & 0xFF);
  switch (status) {
  case 176: // breath velocity
    return;
  case 144: // noteOn
    return;
  case 128: // noteOff
    return;
  }
  // int v = (byte)(data[1] & 127) | ((byte)(data[2] & 127) << 7);
  int v = data[1] & 127 | (data[2] & 127) << 7;  
  bend = norm(v, 0, 1 << 15 - 1);
}