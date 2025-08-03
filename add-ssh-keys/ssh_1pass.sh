#!/bin/sh

op item get "$(basename "$TMPL420KEY")" --account "$OP_ACCOUNT" --vault "$OP_VAULT" --field password --reveal
