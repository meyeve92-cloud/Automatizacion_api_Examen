package utils;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Almacén global compartido entre escenarios y features
 * (Karate aísla las variables de cada escenario).
 */
public class Globals {

    private static final Map<String, Object> DATA = new ConcurrentHashMap<>();
    private static final Random RANDOM = new Random();

    private Globals() {}

    public static void set(String key, Object value) {
        DATA.put(key, value);
    }

    public static Object get(String key) {
        return DATA.get(key);
    }

    /** Celular peruano aleatorio: 9 + 8 dígitos (9 dígitos en total). */
    public static String randomCelular() {
        return "9" + String.format("%08d", RANDOM.nextInt(100_000_000));
    }
}
