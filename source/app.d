import std.exception;
import std.file : remove, FileException;
import std.stdio;
import std.string : stripRight;

import til.nodes;


CommandsMap fileCommands;


class TilFile : Item
{
    string path;
    File handler;
    string mode;
    this(string path)
    {
        this.path = path;
        this.mode = "c";
        this.commands = fileCommands;
    }

    void open(string mode)
    {
        handler = File(path, mode);
        this.mode = mode;
    }
    void close()
    {
        if (handler.isOpen)
        {
            handler.close();
        }
        this.mode = "c";
    }

    override Context next(Context context)
    {
        if (mode == "c")
        {
            return context.error(
                "The file `" ~ path ~ "` is closed",
                ErrorCode.RuntimeError,
                "file"
            );
        }

        if (handler.eof)
        {
            context.exitCode = ExitCode.Break;
            return context;
        }
        else
        {
            context = this.runCommand("read.line", context);

            if (handler.eof)
            {
                context.exitCode = ExitCode.Break;
            }
            else
            {
                context.exitCode = ExitCode.Continue;
            }
            return context;
        }
    }
    override string toString()
    {
        return path ~ " (" ~ mode ~ ")";
    }
}

static this()
{
    fileCommands["open"] = new Command((string path, Context context)
    {
        auto file = cast(TilFile)context.pop();
        if (!file.handler.isOpen)
        {
            try
            {
                file.open("r");
            }
            catch (ErrnoException ex)
            {
                return context.error(to!string(ex.message), ex.errno, "file");
            }
        }
        return context;
    });
    fileCommands["open.read"] = new Command((string path, Context context)
    {
        auto file = cast(TilFile)context.peek();
        try
        {
            file.open("r");
        }
        catch (ErrnoException ex)
        {
            return context.error(to!string(ex.message), ex.errno, "file");
        }
        return context;
    });
    fileCommands["open.write"] = new Command((string path, Context context)
    {
        auto file = cast(TilFile)context.peek();
        try
        {
            file.open("w");
        }
        catch (ErrnoException ex)
        {
            return context.error(to!string(ex.message), ex.errno, "file");
        }
        return context;
    });
    fileCommands["open.append"] = new Command((string path, Context context)
    {
        auto file = cast(TilFile)context.peek();
        try
        {
            file.open("a");
        }
        catch (ErrnoException ex)
        {
            return context.error(to!string(ex.message), ex.errno, "file");
        }
        return context;
    });
    fileCommands["seek"] = new Command((string path, Context context)
    {
        auto file = context.pop!TilFile();
        auto position = context.pop!long();
        file.handler.seek(position);
        return context;
    });
    fileCommands["write"] = new Command((string path, Context context)
    {
        auto file = context.pop!TilFile();
        auto data = context.pop!ByteVector();
        file.handler.rawWrite(data.values);
        return context;
    });
    fileCommands["size"] = new Command((string path, Context context)
    {
        auto file = context.pop!TilFile();
        return context.push(file.handler.size);
    });
    fileCommands["sync"] = new Command((string path, Context context)
    {
        auto file = context.pop!TilFile();
        file.handler.sync();
        return context;
    });
    fileCommands["read.all"] = new Command((string path, Context context)
    {
        auto file = context.pop!TilFile();
        auto size = file.handler.size;
        if (size == ulong.max)
        {
            size = 1024;
        }
        byte[] data;

        while (!file.handler.eof)
        {
            data ~= file.handler.rawRead(new byte[size]);
        }
        return context.push(new ByteVector(data));
    });
    fileCommands["read.some"] = new Command((string path, Context context)
    {
        auto file = context.pop!TilFile();
        auto size = context.pop!long();

        byte[] data = file.handler.rawRead(new byte[size]);
        return context.push(new ByteVector(data));
    });
    fileCommands["read.line"] = new Command((string path, Context context)
    {
        auto file = context.pop!TilFile();
        auto size = file.handler.size;
        string line = file.handler.readln().stripRight("\n");
        return context.push(line);
    });
    fileCommands["close"] = new Command((string path, Context context)
    {
        auto file = cast(TilFile)context.pop();
        file.close();
        return context;
    });
    fileCommands["rm"] = new Command((string path, Context context)
    {
        string filepath = context.pop!string();
        try
        {
            filepath.remove();
        }
        catch (FileException ex)
        {
            return context.error(to!string(ex.message), ErrorCode.Unknown, "file");
        }
        return context;
    });
}

extern (C) CommandsMap getCommands(Escopo escopo)
{
    CommandsMap commands;

    commands[null] = new Command((string path, Context context)
    {
        // file "/var/log/messages" | as systemlog
        string filepath = context.pop!string();
        TilFile file;
        try
        {
            file = new TilFile(filepath);
        }
        catch (Exception ex)
        {
            return context.error(to!string(ex.message), ErrorCode.Unknown, "file");
        }
        return context.push(file);
    });

    return commands;
}
