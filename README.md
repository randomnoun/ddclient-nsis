
# ddclient-nsis
Windows ddclient installer

### What does it do ? 

ddclient periodically sends your IP address to a dynamic DNS server, so that you can refer to your machine with a DNS name instead of an IP address.

This project wraps that up in a Windows installer which hopefully makes setting that up a slightly simpler process.

For more information, see [the blog post](http://www.randomnoun.com/wp/2013/08/19/a-dynamic-dns-client-for-windows/).

### Download

The installer can be downloaded from the [github releases page](https://github.com/randomnoun/ddclient-nsis/releases)
or from within the dist folder of this project.

### Compiling

Prerequisites:

* Strawberry perl
   * and then `cpan install pp`
* Java
   * and Maven
* NSIS 2.x
* and run `mvn package` and see what breaks
* You'll probably have to update some paths in the `pom.xml` or in `src\main\perl\make-ddclient-exe.bat`


### License

GNU General Public Licence v2