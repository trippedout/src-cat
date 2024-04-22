# SrcCat

```bash
 _._     _,-'""`-._
 (,-.`._,'(       |\`-/|
     `-.-' \ )-`( , o o) 
           `-    \`_`"'-
```

A simple script that downloads a github repository and grabs all the text files of a given directory, recursively.

This is a helper script meant to concatenate code docs[^1] into a single file for ingestion into an LLM, such as ChatGPT or Claude Opus.

[^1]: Not tested with actual code yet, just documentation.

### Usage

Download the script (or create a new one locally and copy paste into it) and run it:

```bash
$ ./src-cat.sh 
# paste in a github url, which can be deeplinked to a folder of docs
$ Enter the GitHub repository URL: https://github.com/wevm/frog/tree/main/site/pages
# SrcCat will generate a filename based on the given path and name of the repo 
$ Enter the output file name (default: frog-site-pages.txt): 

$ Concatenation complete. Output file: frog-site-pages.txt
```

The repo is deleted from your /tmp directory and the newly created file can be used with your favorite LLM.

### Issues
Doesn't seem to play nicely with user/branch urls, so stick to main for now