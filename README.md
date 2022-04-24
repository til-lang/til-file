# til-file

## Install

Use [til-pkg](https://github.com/til-lang/til-pkg) to install this package
**very** easily:

```bash
$ til install file
```

## Usage

```tcl
file "/tmp/til-file-test.txt" | as path

scope "make sure the file doesn't exist" {
    proc on.error (e) {
        return
    }
    rm $path
}

scope "try to read from the inexistent file" {
    proc on.error (e) {
        print "on.error (expected): $e / " <$e class>
        return
    }
    open.read $path | autoclose | as f
    read.all $f | print
}

scope "write some bytes into a new file" {
    print "open.write $path"
    open.write $path | autoclose | as f
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

# Remove the file:
rm $path
```
