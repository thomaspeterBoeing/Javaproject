class EchoTestDrive {
    public static void main(String[] args) {
        Echo e1 = new Echo();
        Echo e2 = new Echo();
        int x = 0;

        while (x < 4) {
            e1.hello();

            if (e1.count == 0) {

                e1.count = e1.count + 1; // 1
                e2 = e1; // 1
                e2.count = e2.count + 1; // 2

            }
            if (e2.count == 2) {
                e2.count = e2.count + e1.count; // 5
                e1.count = e1.count + 1; // 2
                e2.count = e2.count + e1.count; // 8
                // e2 = e1;
                // e2.count = e2.count + e1.count;

            }
            x = x + 1;
        }
        System.out.println(e2.count);
    }
}