Command Builder
===============

**Command Builder** builds call to some command runnable from shell 
command line from its arguments. Here is real example of call to 
`jpegoptim`:

    require "command-builder"
    cmd = CommandBuilder::new(:jpegoptim)
    
    cmd.arg(:m, 2)
    cmd << :preserve
    cmd << "image.jpg"
    
    cmd.to_s    # will return 'jpegoptim -m 2 --preserve image.jpg'
    
Value escaping and assignments are supported automatically of sure, 
so call:
    cmd.arg(:dest, './it\'s "my" folder')
    
…will be interpreted as `jpegoptim --dest="it's \"my\" folder"`. It also
takes spaces into the account.

### Flexibility

Syntax described above is supported by default, but you can achieve for
example an Windows like syntax:
    jpegoptim /m:2 -dest "directory"
    
…simply by assigning:
    cmd.separators = ["/", ":", "-", " "]
    
For illustration, the default one is `["-", " ", "--", "="]`.

    
Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-change`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-change`).
5. Create an [Issue][2] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.


Copyright
---------

Copyright &copy; 2011 [Martin Kozák][3]. See `LICENSE.txt` for
further details.

[2]: http://github.com/martinkozak/command-builder/issues
[3]: http://www.martinkozak.net/
