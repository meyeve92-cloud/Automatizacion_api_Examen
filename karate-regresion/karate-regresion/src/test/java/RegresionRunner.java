import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Ejecuta todo en una sola corrida y en secuencia (sin paralelismo),
 * porque los escenarios dependen de los datos del anterior.
 * Reporte: target/karate-reports/karate-summary.html
 */
class RegresionRunner {

    @Test
    void ejecutarRegresion() {
        Results results = Runner
                .path("classpath:features/regresion.feature",
                      "classpath:features/admin.feature")
                .outputCucumberJson(true)
                .parallel(1);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
