Feature: Applying shorthands and some new methods to standard library
  In order to make the coding a really delightful process
  A developer uses new aliases/shorthands/functions and enjoys

# -----------------------------------------------------------
# --------------------   Kernel   ---------------------------
# -----------------------------------------------------------

  Scenario: λ is the alias for lambda
    Given I define lambda with newly introduced λ alias
    When I call a codeblock defined with “λ”
    Then the code is being executed and returns proper value (squared param)
    
  Scenario: λ is the proper lambda (parameter count aware) alias for lambda
    Given I define lambda with newly introduced λ alias
    When I call a codeblock defined with “λ” with wrong amount of arguments
    Then I got ArgumentError as the result
    
  Scenario: Λ is the alias for proc
    Given I define proc with newly introduced Λ alias
    When I call a codeblock defined with “Λ”
    Then the code is being executed and returns proper value (squared param)
    
  Scenario: Λ is the proc not lambda (parameter count unaware) alias for proc
    Given I define proc with newly introduced Λ alias
    When I call a codeblock defined with “Λ” with wrong amount of arguments
    Then the code is being executed and returns proper value (squared param)

# -----------------------------------------------------------

  Scenario: Random values for the supported classes should be produced
    Given I define classset as default (String, Fixnum, Array, Hash)
    When I ask for a random value on a classset
    Then the random value should have one of the classes given
    
# -----------------------------------------------------------
# --------------------   Randoms   --------------------------
# -----------------------------------------------------------
  
  Scenario: Random value for the String class should be produced
    Given I am `using Yard::MonkeyPatches`
    When I call random of a size 1024 on a String instance
    Then the random value should be generated of type String and have length of 1024
  
  Scenario: Random value for the Fixnum class should be produced
    Given I am `using Yard::MonkeyPatches`
    When I call random on a Fixnum instance 1024
    Then the random value should be generated of type Fixnum and be less than 1024
  
  Scenario: Random value for the Array class should be produced
    Given I am `using Yard::MonkeyPatches`
    When I call random of a size 1024 on an Array instance
    Then the random value should be generated of type Array and have length of 1024
  
  Scenario: Random value for the Hash class should be produced
    Given I am `using Yard::MonkeyPatches`
    When I call random of a size 1024 on a Hash instance
    Then the random value should be generated of type Hash and have length of 1024
  