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

// pbcopy = xclip -i sel or xsel -i -b
// pbpaste = xclip -o sel or sel -o -b

int main(string[] args) {
    int exit_status = 1;
    alias Command = int function(string[] args);

    Command[string] program_groups;
    program_groups["pbcopy"] = &pbcopy;
    program_groups["pbpaste"] = &pbpaste;

    Command[string] command_groups;
    command_groups["setup"] = &setup;
    command_groups["open"] = &openClip;

    immutable prog = args[0].baseName;
    immutable arg1 = args.length == 2 ? args[1] : "";

    if (auto c = prog in program_groups) {
        exit_status = (*c)(args);
    } else if (auto c = arg1 in command_groups) {
        exit_status = (*c)(args);
    } else {
        printHelp(prog);
    }

    if (exit_status != 0) {
        stderr.writeln(errmsg);
    }

    return exit_status;
}

void printHelp(string prog) {
    writefln("Usage: %s <command group>", prog);
    writeln("command group:");
    writeln("  setup    create symlinks for pbcopy/pbpaste");
    writeln();
    writefln("Usage: <program group>");
    writeln("program group (via symlinks):");
    writeln("  pbcopy   copy stdin to buffer file");
    writeln("  pbpaste  stream buffer file to stdout");
}

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
        errmsg = "Unable to write to: " ~ clipBufferFile ~ "(" ~ ex.msg ~ ")";
    } catch (Exception ex) {
        errmsg = "Unable close file: " ~ clipBufferFile ~ "(" ~ ex.msg ~ ")";
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
        errmsg = "Unable to read from: " ~ clipBufferFile ~ "(" ~ ex.msg ~ ")";
    } catch (Exception ex) {
        errmsg = "Unable close file: " ~ clipBufferFile ~ "(" ~ ex.msg ~ ")";
    }

    return 1;
}

int setup(string[] args) {
    assert(args.length >= 2);

    immutable arg0 = args[0];
    immutable original = arg0.expandTilde.absolutePath;
    immutable base = original.dirName;
    immutable pbcopy_ = buildPath(base, "pbcopy");
    immutable pbpaste_ = buildPath(base, "pbpaste");

    foreach (p; [pbcopy_, pbpaste_].filter!(a => !exists(a))) {
        symlink(original, p);
    }

    return 0;
}

int openClip(string[] args) {
    import std.process;

    try {
        execute(["xdg-open", clipBufferFile.expandTilde]);
    } catch (Exception ex) {
        writeln("Unable to open the: ", clipBufferFile);
    }

    return 0;
}
