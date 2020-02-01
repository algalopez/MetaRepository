Encryption algortith used in Ken Foller's book: The key to Rebecca

**Description:**
1. The receiver must know the book and the key(as a birthday date) used to encrypt/decrypt
2. Add the last 2 digits of the current year and the birthday day to calculate the book's starting page (ex: Current year=2020, birthday day=5 => page=20+5)
3. Remove every nth letter from the start, where the n corresponds with the birthday month (ex: May = 5)
4. Iterate for every letter in the message:
    1. Find the current letter in the text
    2. Count the position of the letter from the start of the iteration
    3. Translate that count to a new letter (ex: 1=A, 2=B, etc)
    4. Iterate again starting from the found letter
    
**Usage:**
- Set the birthday month, message and book text
- Execute: python RebeccaClient.py
