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
matched 20 lines or less in your LaTeX document, and it has to start with 
a TeX comment symbol (`%`) followed by a hash sign (`#`) and an exclamation mark (`!`), 
colloquially known as the bang, hence the name shebang for TeX/LaTeX. 


## Getting started

### 1. Install `runtexshebang.lua` in your TeX Live system.

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

Then, it will run `lualatex foo.tex`.


## Examples

### TeXworks

#### Settings

1. Open "Typesetting" tab in TeXworks Preferences.
2. Add the tool configuration "runtexshebang" in "Processing tools" as below.
        - Name: `runtexshebang`
        - Program: `runtexshebang`
        - Arguments: `$fullname`
        - ☑ View PDF after running (if necessary)

#### LaTeX document in the internal editor of TeXwork

`% !TEX program = ` is a magic comment of TeXworks.
You can set one processing tool as 
`% !TEX program = <your choice of tool configuration>`.

``` latex
% !TEX program = runtexshebang
%#! lualatex --synctex=1 foo
```


### LaTeX Workshop: Visual Studio Code

#### Settings

Nothing!

#### LaTeX document in Visual Studio Code

`% !TEX program = ` is a magic comment of LaTeX Workshop.
You need another magic comment to the target LaTeX document file as below. 

``` latex
% !TEX program = runtexshebang
% !TEX options = "%DOC%".tex
%#! lualatex --synctex=1 foo
```


### TeXShop

#### Settings

There the “Engine” settings for the command lines "TeX+dvipdfmx / TeX+dvips+distiller" as follows. 

* TeX: `runtexshebang`
* LaTeX: `runtexshebang`

#### LaTeX document in the internal editor of TeXShop

`% !TEX program = ` is a magic comment of TeXShop.

``` latex
% !TEX program = runtexshebang
%#! lualatex --synctex=1 foo
```


## Applications

### What does the PATH variable set in my editor?

``` latex
%#! echo $PATH
```

### How about general configuration information for the activated TeX Live version and its configuration in my editor?

``` latex
%#! tlmgr --conf
```

### Otherwise

You can run any command line on your OSs.
For example, you can use any build tools as follows: 
`make`, `rake`, `llmk`, `latexmk`, and so on.

``` latex
%#! make foo.pdf

% #! rake foo.pdf
% #! llmk
% #! latexmk foo
%% and so on.
```

You can typeset a LaTeX document file in a Docker container as below. 

``` latex
%#! docker run -i --rm --workdir /data --mount type=bind,src=$(pwd)/,dst=/data/   bar/foo     lualatex foo
```


## References

* [TeXworks、TeXShop、VSCodeでTeX-style shebangしてみた - Qiita](https://qiita.com/munepi/items/a30c68133cfffbf4d189) (in Japanese)



Enjoy Happy TeXing!


## License

This program is licensed under the terms of the MIT License.

--------------------

Munehiro Yamamoto
https://github.com/munepi
