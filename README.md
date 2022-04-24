
# ddclient-nsis
Windows ddclient installer

### What does it do ? 

ddclient periodically sends your IP address to a dynamic DNS server, so that you can refer to your machine with a DNS name instead of an IP address.

This project wraps that up in a Windows installer which hopefully makes setting that up a slightly simpler process.

For more information, see http://www.randomnoun.com/wp/2013/08/19/a-dynamic-dns-client-for-windows/

### Download

A compiled version of the latest ddclient can be found at http://www.randomnoun.com/wpf/ddclient-1.8.0.exe
or from within the dist folder of this project.

### Compiling

If you want to hack away on this thing, you'll need to install a few things first:

* Strawberry perl
   * and then `cpan install pp`
* Java
   * and Maven
   * which isn't all that necessary, but I'm a Java developer at heart so I'm using java build tools
* NSIS 2.x
* and run `mvn build` and see what breaks
* You'll probably have to update some paths in the `pom.xml` or in `src\main\perl\make-ddclient-exe.bat`


### License

GNU General Public Licence v2