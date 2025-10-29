"""Bad Python code with intentional linting issues."""

# Missing imports
# Missing type hints
# Bad formatting
# Missing docstrings

def bad_function(x,y):  # Missing spaces, no types, no docstring
    result=x+y  # Missing spaces around operators
    return result

class BadClass:  # Missing docstring
    def __init__(self,value):  # Missing space after comma, no types
        self.value=value  # Missing spaces

    def process(self,data):  # No types, no docstring
        unused_variable = 10  # Unused variable
        return data*2

# Unused import (if we had one)
import json  # noqa: F401

# Line too long (over 100 characters) --------------------------------------------------------------------

def another_bad_function():
    x = 1
    return x  # Unnecessary variable

# Missing final newline