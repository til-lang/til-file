# til-file

## Build

1. `make`

## Usage

```tcl
file "/tmp/til-file-test.txt" | as path

scope "make sure the file doesn't exist" {
    proc on.error (e) {
        print "on.error (1): $e"
    }
    rm $path
}

scope "try to read from the inexistent file" {
    proc on.error (e) {
        print "on.error (2): $e / " <$e class>
        return
    }
    with f [open.read $path]
    read.lines $f | foreach line { print $line }
}

scope "write some lines into a new file" {
    print "open.write $path"
    with f [open.write $path]
    print "f:$f"
    range 10 | foreach n { byte_vector $n | write $f }
}

scope "append some lines into file" {
    print "open.append $path"
    with f [open.append $path]
    range 11 20 | foreach n { byte_vector $n | write $f }
}

scope "read the contents from file" {
    print "open.read $path"
    with f [open.read $path]
    read.all $f | print "content:"
}
```
