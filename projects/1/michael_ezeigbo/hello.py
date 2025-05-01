import sys


def greet(name, count):
    for _ in range(count):
        print(f"Hello {name}")


if len(sys.argv) != 3:
    print("Usage: python hello.py <name> <number>")
    sys.exit(1)


name = sys.argv[1]


try:
    number = int(sys.argv[2])
    if number < 1:
        raise ValueError("The number must be a positive integer.")
except ValueError as e:
    print(f"Invalid input for number: {e}")
    sys.exit(1)


greet(name, number)
