# Karate - Regresion (Billetera Digital)

Host: 134.209.211.10 | Auth 4001 | Wallet 4002 | Transaction 4003 | Admin 4004
Header obligatorio `x-channel` (POSTMAN en usuarios, ADMIN en admin).

## Requisitos
- Java 17+ y Maven 3.8+

## Ejecutar
    mvn clean test

## Reporte
`target/karate-reports/karate-summary.html` -> Imprimir -> Guardar como PDF.

## Estructura
- `features/regresion.feature`: Escenarios 1, 2 y 3
- `features/admin.feature`: Flujo administrador
- `utils/Globals.java`: variables globales y generador de celulares
- `karate-config.js`: URLs, credenciales admin y ruta del historial

## Pendiente de confirmar
`historyPath` (historial de transacciones del usuario) no figura en la documentacion.
Si falla con 404, copiar la ruta real desde Live Logs de la app y ponerla en karate-config.js.
