Command Builder
===============

**command-builder** builds command runnable from shell by simple and
ellegant way. Also allows both synchronous executing or asynchronous
one using [EventMachine][1]. Here is an real example of call
to `jpegoptim`:

```ruby
require "command-builder"
cmd = CommandBuilder::new(:jpegoptim)

cmd.arg(:m, 2)
cmd << :preserve
cmd << "image.jpg"

cmd.to_s    # will return 'jpegoptim -m 2 --preserve image.jpg'
```

Value escaping and assignments are supported automatically of sure,
so call:

```ruby
cmd.arg(:dest, './it\'s "my" folder')
```

…will be interpreted as `jpegoptim --dest="it's \"my\" folder"`. It also
takes spaces into the account.

### Executing

Command can be executed directly by call:

    cmd.execute!               # for synchronous executing or...
    cmd.execute do |output|    # ...for asynchronous executing
        # ...
    end

Asynchronous executing requires [EventMachine][1] environment to be run.


### Flexibility

Syntax described above is supported by default, but you can achieve for
example an Windows like syntax:

    jpegoptim /m:2 -dest "directory"

…simply by assigning:

```ruby
cmd.separators = ["/", ":", "-", " "]
```

For illustration, the default one is `["-", " ", "--", "="]`.


Copyright
---------

Copyright &copy; 2011 &ndash; 2015 [Martin Poljak][3]. See `LICENSE.txt` for
further details.

[1]: http://rubyeventmachine.com/
[2]: http://github.com/martinkozak/command-builder/issues
[3]: http://www.martinpoljak.net/
