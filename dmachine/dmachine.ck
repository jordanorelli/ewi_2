1 => int midiChannel;

[
    "samples/bass.aif",
    "samples/snare.aif",
    "samples/clap.aif",
    "samples/cowbell.aif",
    "samples/cymbal.aif",
    "samples/hihat_open.aif",
    "samples/hihat_closed.aif",
    "samples/rimshot.aif"
] @=> string samples[];

SndBuf sampleBuffers[samples.cap()];
Gain gain => dac;
1.0 => gain.gain;
true => int cursorEnabled;

for (0 => int i; i < samples.cap(); i++) {
    SndBuf buf => gain;
    0.5 => buf.gain;
    samples[i] => buf.read;
    buf.samples() => buf.pos;
    buf @=> sampleBuffers[i];
}

false => int muteOn;
0 => float oldGain;
LP_Launchpad.LP_Launchpad(midiChannel) @=> LP_Launchpad lp;
200::ms => dur stepDelay;
0 => int currentStep;
int score[9][9];

fun void louder() {
    gain.gain() => float g;
    g * 1.05 => gain.gain;
    <<< "gain ", g, " -> ", gain.gain() >>>;
}

fun void quieter() {
    gain.gain() => float g;
    g / 1.05 => gain.gain;
    <<< "gain ", g, " -> ", gain.gain() >>>;
}

fun void mute() {
    if (muteOn) {
        lp.setGridLight(7, 8, 0);
        false => muteOn;
        oldGain => gain.gain;
    } else {
        lp.setGridLight(7, 8, LP_Color.lightRed);
        true => muteOn;
        gain.gain() => oldGain;
        0 => gain.gain;
    }
}

fun void controlChange(LP_Event e) {
    if (e.column == 0) {
        louder();
    } else if (e.column == 1) {
        quieter();
    } else if (e.column == 6 && e.velocity == 127) {
        !cursorEnabled => cursorEnabled;
    } else if (e.column == 7 && e.velocity == 127) {
        mute();
    }
}

fun void listener() {
    while(true) {
        lp.e => now;
        if (lp.e.row == 8) {
            controlChange(lp.e);
            continue;
        }
        if (lp.e.velocity == 127) {
            toggle(lp.e.column, lp.e.row);
        }
    }
}
spork ~ listener();

fun void toggle(int col, int row) {
    if (score[col][row]) {
        0 => score[col][row];
        lp.setGridLight(col, row, 0);
        return;
    }
    1 => score[col][row];
    lp.setGridLight(col, row, LP_Color.lightRed);
}

OscSend out;
out.setHost("localhost", 9001);
fun void sendNoteOn(int row) {
    row => out.addInt;
    out.startMsg("/noteOn", "i");
}

fun void columnOn(int col) {
    for (0 => int row; row < 8; row++) {
        if (score[col][row]) {
            lp.setGridLight(col, row, LP_Color.red);
            sendNoteOn(row);
            0 => sampleBuffers[row].pos;
        } else {
            if (cursorEnabled) {
                lp.setGridLight(col, row, LP_Color.lightYellow);
            } else {
                lp.setGridLight(col, row, 0);
            }
        }
    }
}

fun void columnOff(int col) {
    for (0 => int row; row < 8; row++) {
        if (score[col][row] == 1) {
            lp.setGridLight(col, row, LP_Color.lightRed);
        } else {
            lp.setGridLight(col, row, 0);
        }
    }
}

while(true) {
    columnOff(currentStep);

    currentStep++;
    if (currentStep > 7) 0 => currentStep;

    columnOn(currentStep);
    stepDelay => now;
}
