# gpgfinder
Interface to find and add GPG signatures from keyservers


## Discussion

I'm aware that this is not best practices. I'm aware that a [keysigning party](http://www.cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html) is a far better way of getting trusted GPG/PGP keys. 

I'm also aware of the fact that, right now, they aren't happening.

Out of my entire address book, there were only two matches... and the closest of those folks lives four hours away from me.

I had no idea who - if anyone - in my address book had registered their GPG key with a keyserver.  

That's what originally inspired this tool.


CSV.AWK is taken from [this public domain script](http://lorance.freeshell.org/csv/).

Dependencies

AWK  
Bash (possibly other SH variants; I haven't tested)  
wget (curl functionality is commented out but is in code)  

file   (GNU coreutils)  
iconv (GNU coreutils, I think)  
