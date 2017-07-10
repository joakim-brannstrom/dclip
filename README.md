# dclip

Super simple clipboard handler for vim/neovim. Useful when it is desired to not
go via the clipboard of an X11 server.

# Getting Started

dclip depend on the following packages:
 * [D compiler](https://dlang.org/download.html) (dmd 2.072+, ldc 1.1.0+)

Download the D compiler of your choice, extract it and add to your PATH shell
variable.
```sh
# example with an extracted DMD
export PATH=/path/to/dmd/linux/bin64/:$PATH
```

Once the dependencies are installed it is time to download the source code and
build the binaries.
```sh
cd dclip
dub build
```

Done!
Copy the files from dclip/build to wherever you want them

# Vim/Neovim

To see which clipboard program that is used execute this command inside vim:
```vim
:CheckHealth
```

To force vim to use dclip add this to your vimrc:
```vim
"Clipboard setup {{{
if has("clipboard")
    set clipboard=unnamed " copy to/from system clipboard

    " if has("unnamedplus")
    "     set clipboard +=unnamedplus
    " endif
endif

if executable("pbcopy")
    function! ClipboardYank()
        call system('pbcopy', @@)
    endfunction
    function! ClipboardPaste()
        let @@ = system('pbpaste')
    endfunction

    vnoremap <silent> <leader>y y:call ClipboardYank()<cr>
    nnoremap <silent> <leader>p :call ClipboardPaste()<cr>p
    nnoremap <silent> <leader>dclip :call system('dclip open')<cr>
endif
"}}}
```

# TODO

Integrate xsel/xclip.
