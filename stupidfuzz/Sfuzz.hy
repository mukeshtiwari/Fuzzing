(import os socket random)

(defn rand-bytes [prefix postfix n]
   (+ prefix (.urandom os n) postfix))

(print (rand-bytes b"i" b"j" 10))


(defn fuzz-it [sockt]
   (do
     (->>
       (.randrange random 16 100) ; generate a number between 16 and 100
       (rand-bytes b"" b"")  ; create random bytes of data pretending to be http packet
       (.send sockt)  ; send the data across the socket
       (.recv sockt 4096)))) ; we don't care about receiving the request and most of the time we
                             ; would not receive the request because I am sending a malformed
                             ; packet. The only 



(defn genunine-http-packet [sockt]
    (.send sockt "GET / HTTP/1.1\r\nHost: www.google.com\r\n\r\n")
    (.recv sockt 4096))

(defn connect-to-target [target port]
   (do
     (setv sockt (.socket socket (. socket AF_INET) (. socket SOCK_STREAM)))
     (.connect sockt (, target port))
     (fuzz-it sockt)
     (genunine-http-packet sockt) 
     ;(.close sockt)
)) 

(print (connect-to-target "www.google.com" 80))
      
