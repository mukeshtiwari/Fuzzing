(import random os tempfile subprocess)
(require [hy.contrib.loop [loop]])

(defclass Runner [object]

  (setv  PASS "PASS")
  (setv FAIL "FAIL")
  (setv UNRESOLVED "UNRESOLVED")

  (defn --init-- [self])

  (defn run [self inp]
    (, inp Runner.UNRESOLVED)))

(defclass PrintRunner [Runner]
    
  (defn run [self inp]
    (print inp)
    (, inp Runner.UNRESOLVED)))

(setv p (PrintRunner))
(print (.run p "some input"))

(defclass ProgramRunner [Runner]

  (defn --init-- [self program]
    (setv self.program program))

  (defn run-process [self &optional [inp ""]]
    (.run subprocess self.program 
            :input inp
            :stdout subprocess.PIPE
            :stderr subprocess.PIPE 
            :universal_newlines True))

  (defn run [self &optional [inp ""]]
     (setv result (.run-process self inp))
     (cond 
       [(= (. result returncode) 0) (, result self.PASS)]
       [(< (. result returncode) 0) (, result self.FAIL)]
       [True (, result self.UNRESOLVED)])))

  (defclass BinaryProgramRunner[ProgramRunner]
    (defn run-process [self &optional [inp ""]]
      (.run subprocess self.program 
              :input (inp.encode)
              :stdout subprocess.PIPE
              :stderr subprocess.PIPE)))

(setv cat (ProgramRunner "cat")) 
(print (.run cat "hello" ))

(defclass Fuzzer[object]

  (defn --init-- [self])

  (defn fuzz [self]
      "")
  
  (defn run[self :runner (Runner)]
      (.run runner (. self fuzz))

  (defn runs [self :runner (PrintRunner) :triales 10]
    (setv outcomes [])
    (lfor _ (range triales)
      




 
