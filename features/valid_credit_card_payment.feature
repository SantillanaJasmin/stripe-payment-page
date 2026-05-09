Feature: Valid credit card payment
  As a paying customer
  I want to pay a transaction using credit cards

  Scenario: Check items to be paid
    Given I visit a payment link
    Then it should display the items to be paid
    And it should display the fields to capture credit card details

  Scenario: Calculate surcharge based on the credit card's issuing country
    Given I visit a payment link
    When I enter a valid credit card number
    Then a credit card surcharge must be calculated
    And the surcharge should be added to the total amount paid
  
  Scenario: Confirm payment with valid details
    Given I visit a payment link
    And I enter a valid credit card number
    And I submitted the payment form
    And the card has been successfully charged with the indicated amount
    Then a confirmation page should be displayed
  
  Scenario: Revisit a paid payment link
    Given I visit a payment link
    And it has already been paid
    Then a message should be displayed indicating it has been paid

