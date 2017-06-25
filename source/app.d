/**
Copyright: Copyright (c) 2017, Joakim Brännström. All rights reserved.
License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
Author: Joakim Brännström (joakim.brannstrom@gmx.com)
*/
module dclip;

import std.path;
import std.stdio;

int pbcopy(string[] args) {
    return 0;
}

int pbpaste(string[] args) {
    return 0;
}

int main(string[] args) {
    alias Command = int function(string[] args);

    Command[string] commands;
    commands["pbcopy"] = &pbcopy;
    commands["pbpaste"] = &pbpaste;

    if (auto c = args[0].baseName in commands) {
        return (*c)(args);
    } else {
        writeln("Unknown command: ", args[0].baseName);
    }

    return 1;
}
