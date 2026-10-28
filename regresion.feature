@regresion
Feature: Regresion - Transferencia entre usuarios (Billetera Digital)

  Background:
    * def Globals = Java.type('utils.Globals')
    * configure headers = { 'x-channel': 'POSTMAN' }
    * def pin = '123456'
    * def montoDeposito = 1000
    * def montoTransferencia = 450.00

  @escenario1
  Scenario: 1 - Registro de usuarios y asignacion de saldo
    * def emisor = { phone: '#(Globals.randomCelular())', fullName: 'Emisor QA', email: 'emisor.qa@test.com', pin: '#(pin)' }
    * def receptor = { phone: '#(Globals.randomCelular())', fullName: 'Receptor QA', email: 'receptor.qa@test.com', pin: '#(pin)' }

    # --- Registrar Emisor (si ya existe responde 409 y el escenario cae) ---
    Given url authUrl
    And path '/auth/v1/register'
    And request emisor
    When method post
    Then status 201
    And match response.user.status == 'ACTIVE'

    # --- Registrar Receptor ---
    Given url authUrl
    And path '/auth/v1/register'
    And request receptor
    When method post
    Then status 201
    And match response.user.status == 'ACTIVE'

    # --- Login Emisor (necesario para recargar saldo) ---
    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(emisor.phone)', pin: '#(pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    * def emisorId = response.user.id
    * def tokenEmisor = response.token

    # --- Saldo antes de la recarga ---
    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    * def saldoPrevio = response.balance

    # --- Asignar saldo suficiente y validar ---
    Given url walletUrl
    And path '/wallet/v1/deposit'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request { amount: '#(montoDeposito)' }
    When method post
    Then status 200
    And match response.success == true
    And match response.newBalance == saldoPrevio + montoDeposito

    # --- Guardar saldo actual del Emisor ---
    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    * def saldoEmisorInicial = response.balance
    * match saldoEmisorInicial == saldoPrevio + montoDeposito

    # --- Login Receptor y guardar su saldo actual ---
    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(receptor.phone)', pin: '#(pin)' }
    When method post
    Then status 200
    * def receptorId = response.user.id
    * def tokenReceptor = response.token

    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    * def saldoReceptorInicial = response.balance

    # --- Variables globales para los demas escenarios ---
    * Globals.set('emisor', emisor)
    * Globals.set('receptor', receptor)
    * Globals.set('emisorId', emisorId)
    * Globals.set('receptorId', receptorId)
    * Globals.set('saldoEmisorInicial', saldoEmisorInicial)
    * Globals.set('saldoReceptorInicial', saldoReceptorInicial)

  @escenario2
  Scenario: 2 - Transferencia del Emisor al Receptor
    * def emisor = Globals.get('emisor')
    * def receptorId = Globals.get('receptorId')
    * def saldoInicial = Globals.get('saldoEmisorInicial')

    # --- Login Emisor y guardar token ---
    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(emisor.phone)', pin: '#(pin)' }
    When method post
    Then status 200
    * def tokenEmisor = response.token
    * Globals.set('tokenEmisor', tokenEmisor)

    # --- Categoria de gasto para la transferencia ---
    Given url walletUrl
    And path '/wallet/v1/categories'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    * def gastos = karate.filter(response, function(c){ return c.type == 'EXPENSE' })
    * match gastos == '#[_ > 0]'
    * def categoryId = gastos[0].id

    # --- Transferencia ---
    Given url transactionUrl
    And path '/transaction/v1/transfer'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request { recipientId: '#(receptorId)', amount: '#(montoTransferencia)', description: 'Pago de Servicios', categoryId: '#(categoryId)' }
    When method post
    Then status 200
    And match response.status == 'COMPLETED'
    And match response.transactionId == '#string'
    And match response.referenceCode == '#string'

    # --- Guardar codigo de la transaccion ---
    * def transactionId = response.transactionId
    * def referenceCode = response.referenceCode
    * Globals.set('transactionId', transactionId)
    * Globals.set('referenceCode', referenceCode)

    # --- Consulta de saldo y validacion de la disminucion ---
    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    * match response.balance == saldoInicial - montoTransferencia

  @escenario3
  Scenario: 3 - Validacion de la transferencia en el Receptor
    * def receptor = Globals.get('receptor')
    * def saldoInicial = Globals.get('saldoReceptorInicial')
    * def transactionId = Globals.get('transactionId')
    * def referenceCode = Globals.get('referenceCode')

    # --- Login Receptor y guardar token ---
    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(receptor.phone)', pin: '#(pin)' }
    When method post
    Then status 200
    * def tokenReceptor = response.token
    * Globals.set('tokenReceptor', tokenReceptor)

    # --- Saldo del Receptor e incremento ---
    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    * match response.balance == saldoInicial + montoTransferencia

    # --- Transacciones del Receptor y validacion del codigo ---
    Given url walletUrl
    And path historyPath
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    * def lista = response.transactions ? response.transactions : response
    * def encontradas = karate.filter(lista, function(t){ return t.id == transactionId || t.transactionId == transactionId || t.referenceCode == referenceCode })
    * match encontradas == '#[1]'
