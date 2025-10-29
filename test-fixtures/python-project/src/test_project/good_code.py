"""Good Python code that passes all linting checks."""

from typing import List


def calculate_sum(numbers: List[int]) -> int:
    """Calculate the sum of a list of numbers.

    Args:
        numbers: List of integers to sum.

    Returns:
        The sum of all numbers.
    """
    return sum(numbers)


def greet(name: str) -> str:
    """Generate a greeting message.

    Args:
        name: The name to greet.

    Returns:
        A greeting message.
    """
    return f"Hello, {name}!"


class Calculator:
    """A simple calculator class."""

    def __init__(self) -> None:
        """Initialize the calculator."""
        self.result: int = 0

    def add(self, value: int) -> int:
        """Add a value to the current result.

        Args:
            value: The value to add.

        Returns:
            The new result.
        """
        self.result += value
        return self.result

    def reset(self) -> None:
        """Reset the calculator to zero."""
        self.result = 0
