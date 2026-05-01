Feature: Invalid credit card payment
  As a paying customer
  I want to be notified of failed transactions
  
  Scenario: Invalid credit card number
    Given I visit a payment link
    When I enter an invalid credit card number
    Then an error message should be displayed indicating the incorrect credit card number

  Scenario: Declined credit card
    Given I visit a payment link
    And I enter a valid credit card number
    And I submitted the payment form
    And the transaction has been declined
    Then an error message should be displayed to the customer
