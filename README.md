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
    open.read $path | autoclose | as f
    read.all $f | print
}

scope "write some bytes into a new file" {
    print "open.write $path"
    open.write $path | autoclose | as f
    print "f:$f"
    range 10 | foreach n { byte_vector $n | write $f }
}

scope "append some bytes into file" {
    print "open.append $path"
    open.append $path | autoclose | as f
    range 11 20 | foreach n { byte_vector $n | write $f }
}

scope "read the contents from file" {
    print "open.read $path"
    open.read $path | autoclose | as f
    read.all $f | print "content:"
}
```
