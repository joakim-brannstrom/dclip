/**
Copyright: Copyright (c) 2017, Joakim Brännström. All rights reserved.
License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
Author: Joakim Brännström (joakim.brannstrom@gmx.com)
*/
module dclip;

import std.path;
import std.stdio;
import std.file;
import std.algorithm;
import std.exception;

immutable clipBufferFile = "~/.dclip";
string errmsg;

nothrow int pbcopy(string[] args) {
    char[] buf;
    buf.length = 1024;

    try {
        auto fout = File(clipBufferFile.expandTilde, "w");

        while (stdin.readln(buf)) {
            fout.write(buf);
        }

        return 0;
    } catch (ErrnoException ex) {
        errmsg = "Unable to write to: " ~ clipBufferFile;
    } catch (Exception ex) {
        errmsg = "Unable close file: " ~ clipBufferFile;
    }

    return 1;
}

nothrow int pbpaste(string[] args) {
    char[] buf;
    buf.length = 1024;

    try {
        auto fin = File(clipBufferFile.expandTilde);

        while (fin.readln(buf)) {
            stdout.write(buf);
        }

        return 0;
    } catch (ErrnoException ex) {
        errmsg = "Unable to read from: " ~ clipBufferFile;
    } catch (Exception ex) {
        errmsg = "Unable close file: " ~ clipBufferFile;
    }

    return 1;
}

int setup(string arg0) {
    immutable original = arg0.expandTilde.absolutePath;
    immutable base = original.dirName;
    immutable pbcopy_ = buildPath(base, "pbcopy");
    immutable pbpaste_ = buildPath(base, "pbpaste");

    foreach (p; [pbcopy_, pbpaste_].filter!(a => !exists(a))) {
        symlink(original, p);
    }

    return 0;
}

int main(string[] args) {
    int exit_status = 1;
    alias Command = int function(string[] args);

    Command[string] commands;
    commands["pbcopy"] = &pbcopy;
    commands["pbpaste"] = &pbpaste;

    if (auto c = args[0].baseName in commands) {
        exit_status = (*c)(args);
    } else if (args.length == 2 && args[1] == "setup") {
        exit_status = setup(args[0]);
    } else {
        writefln("Usage: %s setup", args[0].baseName);
    }

    if (exit_status != 0) {
        stderr.writeln(errmsg);
    }

    return exit_status;
}
