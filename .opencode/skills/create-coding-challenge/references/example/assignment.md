# Assignment
Support.ai needs a robust message parser that can handle email inputs, which are received as strings, or chat inputs, which are received as arrays of strings.

Complete the `parseCustomerMessage` function. It receives an unknown input and returns a `CustomerMessage`:

1. If the input is a string:
  - source should be "email"
  - content should be the input string

2. If the input is an array:
  - source should be "chat"
  - content should be the strings in the input .join()ed together with a newline character (\n)

3. Otherwise:
  - Source should be the string "unknown"
  - Content should be an empty string
