Feature: The DSL for benchmarking within YARD documentation
  In order to provide benchmarking within YARDoc
  A developer uses DSL

# -----------------------------------------------------------
# --------------------   Callers   --------------------------
# -----------------------------------------------------------

  Scenario: ☎ is the method to create new instance of a class with suggested params if needed
    Given I have a class with contructor requiring parameters
    When I call a ☎ method on it
    Then I have an instance of the class

  Scenario: ☏ is the method to be called on an instance of the class with suggested params if needed
    Given I have an instance method of the class requiring parameters
    When I call a ☏ method for it
    Then I have params suggested and the method called

# -----------------------------------------------------------
# --------------------   Measures   -------------------------
# -----------------------------------------------------------

  Scenario: The benchmarks set are to be processed with call to ::Kernel::⌛ method
    Given I marked some methods as benchmarkable
    When I call a ⌛ method
    Then I yield all the benchmarks
