class DrumNotes {
  ArrayList<DrumNote> notes;
  
  DrumNotes() {
    this.notes = new ArrayList<DrumNote>();
  }
  
  void draw() {
    for (int i = this.notes.size() - 1; i >= 0; i--) {
      DrumNote note = this.notes.get(i);
      note.draw();
      if (note.isDead()) {
        this.notes.remove(i);
      }
    }
  }
  
  void addNote(int note) {
    switch (note) {
    case 0:
      this.notes.add(new BassDrumNote());
      return;
    case 1:
      this.notes.add(new SnareDrumNote());
      return;
    case 2:
      this.notes.add(new ClapNote());
      return;
    }
  }
}

class DrumNote {
  void draw() {}
  boolean isDead() { return false; }
}

int MAX_BASS_DRUM_AGE = 12;

class BassDrumNote extends DrumNote {
  int age;
  
  BassDrumNote() {
    this.age = 0;
  }

  void draw() {
    float n = norm(this.age, 0, MAX_BASS_DRUM_AGE);
    float y = height - (0.5 * height * pow(n, 0.8));
    strokeWeight(pow((1.0 - n), 0.5) * 120);
    stroke(0, 0, 1, 1.0-n);
    line(0, y, width, y);
    this.age++;
  }
  
  boolean isDead() {
    return this.age >= MAX_BASS_DRUM_AGE;
  }
}

class SnareDrumSpark {
  PVector origin;
  PVector velocity;
  int age;
  
  SnareDrumSpark(int i) {
    float n = norm(i, 0, NUM_SNARE_SPARKS);
    this.age = 0;
    this.origin = new PVector(n * width, height * 0.5);
    if (i % 2 == 0) {
      this.velocity = new PVector(random(-10.0, 10.0), random(10.0, 20.0));
    } else {
      this.velocity = new PVector(random(-10.0, 10.0), random(-20.0, -10.0));
    }
  }
  
  void draw() {
    pushMatrix();
    translate(this.origin.x, this.origin.y);
    rotate(this.velocity.heading());
    stroke(0, 0, 1, 1.0 - norm(this.age, 0, MAX_SNARE_DRUM_AGE));
    strokeWeight(20);
    float w = width / (float)NUM_SNARE_SPARKS;
    line(0, -w * 0.5, 0, w * 0.5);
    popMatrix();
    this.origin.add(this.velocity);    
    this.age++;
  }
}

int MAX_SNARE_DRUM_AGE = 12;
int NUM_SNARE_SPARKS = 24;
class SnareDrumNote extends DrumNote {
  int age;
  ArrayList<SnareDrumSpark>sparks;
  
  SnareDrumNote() {
    this.age = 0;
    this.sparks = new ArrayList<SnareDrumSpark>();
    for (int i = 0; i < NUM_SNARE_SPARKS; i++) {
      this.sparks.add(new SnareDrumSpark(i));      
    }
  }
  
  void draw() {
    for (int i = 0; i < this.sparks.size(); i++) {
      SnareDrumSpark spark = this.sparks.get(i);
      spark.draw();
    }
    this.age++;
  }
  
  boolean isDead() {
    return this.age >= MAX_SNARE_DRUM_AGE;
  }
}

int MAX_CLAP_AGE = 12;
class ClapNote extends DrumNote {
  int age;
  float theta;
  ClapNote() {
    this.age = 0;
    this.theta = random(0, TWO_PI);
  }
  void draw() {
    float n = norm(this.age, 0, MAX_CLAP_AGE);
    pushMatrix();
    translate(width * 0.5, height * 0.5);
    noFill();
    stroke(0, 0, 1, 1.0-n);
    rotate(this.theta + n * TWO_PI);
    strokeWeight(n * 400.0);
    rectMode(CENTER);
    rect(0, 0, n * width, n * width);
    popMatrix();
    this.age++;
  }
  boolean isDead() {
    return this.age >= MAX_CLAP_AGE;
  }
}

