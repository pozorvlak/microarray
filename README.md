Some poor bastard posted [this script](http://pastebin.com/Ce9PTtFd) to
[/r/perl](http://www.reddit.com/r/perl/comments/qf9do/why_is_this_perl_code_painfully_slow/), asking for help improving its performance. They received a lot of
advice: some good, some terrible, most irrelevant. Since it looks like they're
new to Perl, I thought it might be helpful to clean up the code step-by-step.

You can browse the changes I've made through the GitHub website, but it will be
easier to make a checkout and browse it with the Gitk history viewer (or GitX
if you're on OS X). To make a checkout, use the following command:

    git clone git://github.com/pozorvlak/microarray.git

The program now depends on some library modules from CPAN (Perl's killer
feature). To install these, and their dependencies, do the following:

1. Install cpanminus, using one or other of these commands:

        curl -L http://cpanmin.us | perl - --self-upgrade
        wget -O - http://cpanmin.us | perl - --self-upgrade

2. Use cpanminus to fetch the dependencies specified in Makefile.PL

        ~/perl5/bin/cpanm .

That's it! You'll note that cpanminus also runs the tests for all the modules
it fetches, and the tests (OK, test) for this distribution (in t/).

You may also be interested in the following articles, in which Mark Jason
Dominus applies similar cleanups to some beginners' Perl scripts.

http://www.perl.com/pub/2000/04/raceinfo.html   
http://www.perl.com/pub/2000/06/commify.html   
http://perl.plover.com/yak/flags/   

Have fun!
