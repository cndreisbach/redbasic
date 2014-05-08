```
__________           ._____________    _____    _________.____________  
\______   \ ____   __| _/\______   \  /  _  \  /   _____/|   \_   ___ \
 |       _// __ \ / __ |  |    |  _/ /  /_\  \ \_____  \ |   /    \  \/
 |    |   \  ___// /_/ |  |    |   \/    |    \/        \|   \     \____
 |____|_  /\___  >____ |  |______  /\____|__  /_______  /|___|\______  /
        \/     \/     \/         \/         \/        \/             \/
```

# RedBASIC

RedBASIC is an implementation of [Dartmouth BASIC][] version 4, as specified in the [BASIC 4th Edition Manual, Jan 1968][manual]. Current status: can run the first program in the manual.

[Dartmouth BASIC]: http://en.wikipedia.org/wiki/Dartmouth_BASIC
[manual]: http://bitsavers.trailing-edge.com/pdf/dartmouth/BASIC_4th_Edition_Jan68.pdf

## Installation

Add this line to your application's Gemfile:

    gem 'redbasic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redbasic

## Usage

Run `redbasic`.

## TODO

* Implement `FOR/NEXT`
  * Disallow cross-nested loops
* Implement function calls and the default functions
  * SIN
  * COS
  * TAN
  * COT
  * ATN
  * EXP
  * LOG
  * ABS
  * SQR
* Implement other functions
  * INT
  * RND
  * SGN
  * NUM
  * DET
* Implement user-defined functions
