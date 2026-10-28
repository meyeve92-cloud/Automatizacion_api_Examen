@admin
Feature: Flujo Administrador

  Background:
    * def Globals = Java.type('utils.Globals')
    * configure headers = { 'x-channel': 'ADMIN' }

  Scenario: Validar la transaccion de la operacion
    * def referenceCode = Globals.get('referenceCode')
    * def emisorId = Globals.get('emisorId')
    * def receptorId = Globals.get('receptorId')
    * match referenceCode == '#string'

    Given url adminUrl
    And path '/admin/v1/login'
    And request { username: '#(adminUser)', password: '#(adminPassword)' }
    When method post
    Then status 200
    And match response.token == '#string'
    * def tokenAdmin = response.token

    Given url adminUrl
    And path '/admin/v1/transactions'
    And header Authorization = 'Bearer ' + tokenAdmin
    When method get
    Then status 200
    * def lista = response.transactions ? response.transactions : response
    * def movimientos = karate.filter(lista, function(t){ return t.referenceCode == referenceCode })
    * match movimientos == '#[2]'

    * def egreso = karate.filter(movimientos, function(t){ return t.type == 'EXPENSE' })
    * match egreso == '#[1]'
    * match egreso[0].userId == emisorId
    * match egreso[0].amount == 450
    * match egreso[0].description contains 'Pago de Servicios'

    * def ingreso = karate.filter(movimientos, function(t){ return t.type == 'INCOME' })
    * match ingreso == '#[1]'
    * match ingreso[0].userId == receptorId
    * match ingreso[0].amount == 450
    * match ingreso[0].description contains 'Pago de Servicios'