"""Tests that fail intentionally."""

import pytest


def test_failing_assertion() -> None:
    """This test will fail."""
    assert 1 + 1 == 3, "Math is broken!"


def test_failing_comparison() -> None:
    """This test will also fail."""
    result = [1, 2, 3]
    expected = [1, 2, 4]
    assert result == expected


def test_exception_not_raised() -> None:
    """This test expects an exception that won't be raised."""
    with pytest.raises(ValueError):
        # This should raise ValueError but doesn't
        _ = int("123")


def test_with_low_coverage() -> None:
    """This test exists but doesn't cover much code."""
    x = 1
    assert x > 0
