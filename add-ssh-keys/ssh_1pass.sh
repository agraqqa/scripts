#!/bin/sh

op item get "$(basename "$TMPL420KEY")" --vault "$OP_VAULT" --field password
