(import random os tempfile subprocess)
(require [hy.contrib.loop [loop]])


(defn fuzzer [&optional [max-length 100] [char-start 32] [char-range 32]]
  (->>
    (.randrange random 0 (+ 1 max-length))
      ((fn [x] (lfor _ (range x)
        (->
          (.randrange random char-start (+ char-start char-range))
            chr))))
      (.join "")))


;(print (fuzzer 100 32 32))
;(print (fuzzer 1000 (ord "a") 26))
;(print (fuzzer))

(defn prepare-fuzz []
  (do
    (setv basename "input.txt")
    (setv tempdir (.mkdtemp tempfile))
    (setv FILE (.join os.path tempdir basename))
    (setv data (fuzzer))
    (with [outf (open FILE "w")]
        (.write outf data))))


;; How Can I make it more abstract
;; Also, it's good idea to avoid os.system call
(defn fuzz-unix-command [command]
  (lfor _ (range 100)
    (as->
     ;(fuzzer 100 (ord "0") 10) it ;; This would never crash
     (fuzzer) it  ;; This would may crash
     (.system os (+ "echo " it " + " it " | " command)))))

;; Using subprocess
(defn fuzz-bc [command]
  (lfor _ (range 100)
    (as-> 
      ;(fuzzer 100 (ord "0") 10) it ;; This would never crash
      (fuzzer) it  ;; This would may crash
      (.run subprocess ["echo" it "+" it "|" command]))))


;; However, this would generate a random garbage data, and 
;; and it might lead to parse error 
;;(fuzz-unix-command "bc")
;;(fuzz-bc "bc")


(defn fuzz-unix-from-file [command]
  (setv basename "input.txt")
  (setv tempdir (.mkdtemp tempfile))
  (setv FILE (.join os.path tempdir basename))
  (setv runs [])
  (lfor _ (range 10)
   (do
    (setv data (fuzzer))
    (with [ofile (open FILE "w")]
      (.write ofile data))
    (as->
      (.run subprocess [command FILE] 
            :stdin subprocess.DEVNULL 
            :stdout subprocess.PIPE
            :stderr subprocess.PIPE 
            :universal_newlines True) it
      (.append runs (, data it)))))
      (setv strerror
         (map (fn [x] (. (get x 1) stderr))
                 runs))
      (print (list strerror)))
  

;;(fuzz-unix-from-file "bc")

  
(defn write-c-program []
  (with [outf (open "program.c" "w")]
    (.write outf "
      #include <stdlib.h>
      #include <string.h>

      int main(int argc, char** argv) {
        /* Create an array with 100 bytes, initialized with 42 */
        char *buf = malloc(100);
        memset(buf, 42, 100);

        /* Read the N-th element, with N being the first command-line argument */
        int index = atoi(argv[1]);
        char val = buf[index];

        /* Clean up memory so we don't leak */
        free(buf);
      return val; 
      }")))

;;(write-c-program)

;; heart beat simulation
(setv secrets (+ "<space for reply>" (fuzzer 100) "<secret-certificate>" (fuzzer 100)
                 "<secret-key>" (fuzzer 100) "<other-secrets>"))

(setv uninitialized-memory-marker "deadbeef")

;; Tail call optimization
(defn append-secret-with-uninitialized-memory [secr uninitialized]
  (loop [[acc secr]]
    (cond 
      [(> (len acc) 2048) secr]
      [True (recur (+ acc uninitialized))])))


(setv all-memory (append-secret-with-uninitialized-memory secrets uninitialized-memory-marker))

;(print all-memory)
;(print (list (+ "hello" (str (drop 10 all-memory)))))

(defn heart-beat [reply length memory]
  (setv mem (+ reply (str (drop (len reply) memory))))
  (take length mem))

(print (list (heart-beat "potato" 6 all-memory)))
(print (list (heart-beat "bird" 4 all-memory)))
(print (list (heart-beat "bird" 500 all-memory)))

