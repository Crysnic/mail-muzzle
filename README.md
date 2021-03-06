mail-muzzle
===========

##Creating a self-signed SSL Certificate
 1. Change directory to ***apps/muz/priv/ssl***.

     `$ cd apps/muz/priv/ssl`

 2. Delete all the files in this directory.

     `$ rm server.*`

 3. Generate a Private Key. At this point you will need to specify any pass phrase and confirm it. I
is we need to create a certificate, but in the future we will get rid of it.

     `$ openssl genrsa -des3 -out server.key 1024`

 4. Generate a Certificate Signing Request.When generating a CSR, you will 
be asked to answer a few questions. It isimportant in the Common Name 
field to specify your fully qualified domain name to be protected by SSL.
For example, if your website address is **https://somecoolsite.dp.ua**,
enter in the Common Name field **somecoolsite.dp.ua**.

    ~~~
    $ openssl req -new -key server.key -out server.csr
    
    Country Name (2 letter code) [GB]:UA
    State or Province Name (full name) [Berkshire]:Dnepropetrovsk
    Locality Name (eg, city) [Newbury]:Dnepropetrovsk Region
    Organization Name (eg, company) [My Company Ltd]:Vovar Development
    Organizational Unit Name (eg, section) []:Information Technology
    Common Name (eg, your name or your server's hostname) []:somecoolsite.dp.ua
    Email Address []:vovar@ipv6.dp.ua
    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:
    ~~~

 5. Remove Passphrase from Key

    ~~~
    $ cp server.key server.key.org
    $ openssl rsa -in server.key.org -out server.key
    ~~~

 6. Generating a Self-Signed Certificate

     `$ openssl x509 -req -days 3650 -in server.csr -signkey
     server.key -out server.crt`

##Setting

1. Open rel/files/sys.config
2. Set the port:

    ~~~
    Example:
    
    {port, 9999} %% Change the default port 9999
    
    {port, 3468} %% on the 3468
    ~~~

3. IP is specified as follows 

    ~~~
    {ip, {127, 0, 0, 1}} %% IP  127.0.0.1
    ~~~

4. Path to certification files specified in the following lines

    ~~~
    {certfile, "ssl/server.crt"} %% path to certification file 
    {keyfile, "ssl/server.key"} %% path to server key
    ~~~
