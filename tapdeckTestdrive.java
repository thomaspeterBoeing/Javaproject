public class tapdeckTestdrive {
    public static void main(String[] args) {
        tapedeck t = new tapedeck();
        t.canRecord = true;
        t.playTape();

        if (t.canRecord == true) {
            t.recordTape();
        }
    }
}
