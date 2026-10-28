function fn() {
  var host = 'http://134.209.211.10';
  return {
    authUrl:        host + ':4001',
    walletUrl:      host + ':4002',
    transactionUrl: host + ':4003',
    adminUrl:       host + ':4004',
    // Credenciales admin (ejemplo de la documentacion)
    adminUser: 'admin',
    adminPassword: 'superpassword',
    // Endpoint del historial de transacciones del usuario (no figura en la documentacion; AJUSTAR si es otro)
    historyPath: '/wallet/v1/transactions'
  };
}
