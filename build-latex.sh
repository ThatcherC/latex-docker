#!/bin/bash

# LaTeX build setup script - creates compile directory and latexmkrc if needed
# Created by asking Claude to condense the 'Latex Make' section in 
# https://github.com/blang/latex-docker/blob/42d2c532a09a00938331512fd2b539f9944c400c/README.md#latex-make
# down to one idempotent bash file
# and then some hand-editing from there

set -e  # Exit on any error

# Create compile directory if it doesn't exist
mkdir -p compile

# Check if latexmkrc exists, create it if not
# using the example given at https://github.com/blang/latex-docker/blob/master/README.md#latex-make
if [[ ! -f latexmkrc ]]; then
    echo "Creating latexmkrc..."
    cat > latexmkrc << 'EOF'
# Example: Make glossaries
add_cus_dep( 'glo', 'gls', 0, 'makeglo2gls' );
sub makeglo2gls {
    system("makeindex -s \"$_[0].ist\" -t \"$_[0].glg\" -o \"$_[0].gls\" \"$_[0].glo\"" );
}
EOF
    echo "latexmkrc created successfully."
fi

# Docker settings
IMAGE=thatcherc/latex:ubuntu
DOCKERRUN="docker run --rm -i --user='$(id -u):$(id -g)' --net=none -v '$PWD':/data '$IMAGE'"

# Run the latex build
eval $DOCKERRUN latexmk -cd -f -jobname=output -outdir=./compile -auxdir=./compile -interaction=batchmode -pdf ./main.tex
