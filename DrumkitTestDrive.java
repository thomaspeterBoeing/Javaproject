public class DrumkitTestDrive {
    public static void main(String[] args) {
        Drumkit d = new Drumkit();

        // d.playSnare();

        if (d.snare == true) {
            d.playSnare();

        }
        d.playTopHat();
        // d.snare = false;

    }
}
