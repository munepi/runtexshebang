# runtexshebang: Lua script running LaTeX document files with TeX-style shebang

Lua script running LaTeX document files with a TeX-style shebang (`%#!`)

## What is a TeX-style shebang (`%#!`)

In short, a TeX-style shebang (`%#!`) is a special kind of TeX comment 
that you include in your TeX/LaTeX document file to tell the operating system's 
shell how to run the file for the rest of the file: 

``` latex
%#!lualatex foo.tex
\documentclass{article}
\begin{document}
Hello, {\LaTeX} World!

Happy {\TeX}ing.
\end{document}
```

If you are using a TeX-style shebang, it must appear on the line that 
matched 20 lines or less in your script, and it has to start with 
a TeX comment symbol followed by a hash sign (#) and an exclamation mark (!), 
colloquially known as the bang, hence the name shebang for TeX/LaTeX. 


## Getting started

### 1. Install `runtexshebang.lua` in your TeX Live system

``` shell
cp runtexshebang.lua /some/where/TEXMFDIST_or_TEXMFLOCAL/scripts/runtexshebang/runtexshebang.lua

cd TEXLIVE_BIN_DIRECTORY
ln -s ../../TEXMFDIST_or_TEXMFLOCAL/scripts/runtexshebang/runtexshebang.lua runtexshebang
```

### 2. Make a sample file with a TeX-style shebang.

Make the following LaTeX document. 

``` latex
%#!lualatex foo.tex
\documentclass{article}
\begin{document}
Hello, {\LaTeX} World!

Happy {\TeX}ing.
\end{document}
```

### 3. Run the sample file.

``` shell
runtexshebang foo.tex
```

Then, it will run `lualatex foo.tex` and will get `foo.pdf`.


## Examples

### TeXworks

### Visual Studio Code

### TeX Shop




Enjoy Happy TeXing!


## License

This program is licensed under the terms of the MIT License.

--------------------

Munehiro Yamamoto
https://github.com/munepi
