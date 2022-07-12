# gpgfinder

Find and add GPG signatures from keyservers from an exported addressbook using GPG
itself.

# Usage

`./gpgfinder.sh -f /path/to/vcf_file.vcf`

Matches and non-matches are written to `match_yes.txt` and `match_no.txt` respectively in the script directory.

## Keyservers queried

In reverse order:

* keys.openpgp.org
* keys.mailvelope.com
* keyserver.ubuntu.com
* pgp.mit.edu

## Discussion

I'm aware that this is not best practices. 

Yet I currently have no idea who - if anyone - in my address book has a GPG key, 
or has registered one with a keyserver. 

And if they *have* registered with a keyserver, shouldn't I... well, *use* that?

So that's what originally inspired this tool.
