import oscP5.*;
import netP5.*;

OscP5 drums;
DrumNotes notes;

void setup_drums() {
  drums = new OscP5(this, 9001);
  drums.plug(this, "drumNoteOn", "/noteOn");
  notes = new DrumNotes();
}

void draw_drums() {
  notes.draw();
}

void drumNoteOn(int note) {
  notes.addNote(note);
  println(note);
}
