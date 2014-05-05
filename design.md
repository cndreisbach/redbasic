## Two-pass interpreter

### First pass

* Read all DATA statements and store in temporary DATA space
* (future) check all FORs for NEXTs
* (future) check for vars used without LET or READ
* (future) check for dangling statements (no END)

### Second pass

* Interpret