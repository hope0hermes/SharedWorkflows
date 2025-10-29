"""Tests that pass."""

from test_project.good_code import calculate_sum, greet, Calculator


def test_calculate_sum() -> None:
    """Test that sum calculation works."""
    assert calculate_sum([1, 2, 3]) == 6
    assert calculate_sum([]) == 0
    assert calculate_sum([-1, 1]) == 0


def test_greet() -> None:
    """Test greeting function."""
    assert greet("World") == "Hello, World!"
    assert greet("Alice") == "Hello, Alice!"


def test_calculator_add() -> None:
    """Test calculator addition."""
    calc = Calculator()
    assert calc.add(5) == 5
    assert calc.add(3) == 8


def test_calculator_reset() -> None:
    """Test calculator reset."""
    calc = Calculator()
    calc.add(10)
    calc.reset()
    assert calc.result == 0
