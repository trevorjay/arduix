;;   (let ((quicklisp-init (merge-pathnames "Downloads/foolin/ardux/ql/setup.lisp"
;;                                          (user-homedir-pathname))))
;;     (when (probe-file quicklisp-init)
;;       (load quicklisp-init)))

;; (ql:quickload :net.didierverna.clon)
;; (ql:quickload :c-mera)
;; (ql:quickload :cm-c++)

;; (setf (readtable-case *readtable*) :invert)

;; (defpackage "ARDUX" (:use "COMMON-LISP"))
(in-package "ARDUX")

(let ((package (find-package "CMU-C++")))
  (rename-package package
		  (package-name package)
		  (adjoin "C"
			  (package-nicknames package)
			  :test #'string=)))

(defun string-print (tree)
  "Pretty prints c-mera ast to string"
  (let ((str (make-string-output-stream)))
    (let (
	  (ei (make-instance 'cm-c:else-if-traverser))
	  (ib (make-instance 'cm-c:if-blocker))
	  (db (make-instance 'cm-c:decl-blocker))
	  (rn (make-instance 'cm-c:renamer))
	  (pp (make-instance 'c-mera:pretty-printer :stream str)))
      (progn
					;(traverser nc tree 0)
	(c-mera:traverser ei tree 0)
	(c-mera:traverser ib tree 0)
	(c-mera:traverser db tree 0)
	(c-mera:traverser rn tree 0)
	(c-mera:traverser pp tree 0)
	(get-output-stream-string str)
	))))

'(in-package "CM-C++")
'(cm-reader)

(defmacro c-code-src (&rest body)
  `(define-symbol-macro c-code
       (string-print
	(c:progn ,@body))))

(define-symbol-macro a-oem 21)
(define-symbol-macro r-oem 8)
(define-symbol-macro t-oem 26)
(define-symbol-macro s-oem 20)
(define-symbol-macro e-oem 9)
(define-symbol-macro y-oem 7)
(define-symbol-macro i-oem 22)
(define-symbol-macro o-oem 4)

(define-symbol-macro hold (/ 200 1)) ;; / 8 on the TMK adapter

(c-code-src

 (c:include <Keyboard.h>)
 (c:include <hidboot.h>)

 (c:decl (
	  (unsigned long (c:set a 0))
	  (unsigned long (c:set r 0))
	  (unsigned long (c:set t 0))
	  (unsigned long (c:set s 0))
	  (unsigned long (c:set e 0))
	  (unsigned long (c:set y 0))
	  (unsigned long (c:set i 0))
	  (unsigned long (c:set o 0))
	  (unsigned long (c:set now 0))
	  (byte state)
	  (bool nav)
	  (bool mouse)
	  (bool lck)
	  (byte (c:set prev 0))))

 (c:function releaseAll () -> void
   (Keyboard.releaseAll)
   (c:if lck
	 (Keyboard.press (c:cast char 129))))

 (c:function press ((byte key)) -> void
   (c:if (c:and
	  (c:> key 127)
	  (c:< key 132))
	 (c:progn
	   (c:if (c:== key prev)
		 (releaseAll)
		 (Keyboard.press (c:cast char key)))
	   (c:set prev key)
	   (c:return)))

   (Keyboard.write (c:cast char key))
   (releaseAll)
   (c:set prev key)
   
   )

 (c:class KbdRptParser ((public KeyboardReportParser))
   (c:protected
     (c:function OnKeyDown ((uint8_t ignore) (uint8_t oem)) -> void
       (c:set now (millis))

       (c:switch oem
		 (a-oem (c:set a now) (c:break))
		 (r-oem (c:set r now) (c:break))
		 (t-oem (c:set t now) (c:break))
		 (s-oem (c:set s now) (c:break))
		 (e-oem (c:set e now) (c:break))
		 (y-oem (c:set y now) (c:break))
		 (i-oem (c:set i now) (c:break))
		 (o-oem (c:set o now) (c:break))))

     (c:function OnKeyUp ((uint8_t ignore) (uint8_t oem)) -> void
       (c:set now (millis))

       (c:set state 0)
       (c:if (c:< (c:- now a) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 4)))
	       (c:set a 0)))
       (c:if (c:< (c:- now r) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 5)))
	       (c:set r 0)))
       (c:if (c:< (c:- now t) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 6)))
	       (c:set t 0)))
       (c:if (c:< (c:- now s) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 7)))
	       (c:set s 0)))
       (c:if (c:< (c:- now e) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 0)))
	       (c:set e 0)))
       (c:if (c:< (c:- now y) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 1)))
	       (c:set y 0)))
       (c:if (c:< (c:- now i) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 2)))
	       (c:set i 0)))
       (c:if (c:< (c:- now o) hold)
	     (c:progn
	       (c:set state (c:\| state (c:<< 1 3)))
	       (c:set o 0)))

       (c:switch oem
		 (a-oem (c:set a 0) (c:break))
		 (r-oem (c:set r 0) (c:break))
		 (t-oem (c:set t 0) (c:break))
		 (s-oem (c:set s 0) (c:break))
		 (e-oem (c:set e 0) (c:break))
		 (y-oem (c:set y 0) (c:break))
		 (i-oem (c:set i 0) (c:break))
		 (o-oem (c:set o 0) (c:break)))

       (c:comment "z" :prefix "//")
       (c:if (c:== state 240) 
	     (c:progn 
	       (press 122) 
	       (c:return)))
       (c:comment "shift" :prefix "//")
       (c:if (c:== state 225) 
	     (c:progn 
	       (press 129) 
	       (c:return)))
       (c:comment "tab" :prefix "//")
       (c:if (c:== state 120) 
	     (c:progn 
	       (press 179) 
	       (c:return)))
       (c:comment "caps lock" :prefix "//")
       (c:if (c:== state 30) 
	     (c:progn 
	       (press 193) 
	       (c:return)))
       (c:comment "space" :prefix "//")
       (c:if (c:== state 15) 
	     (c:progn 
	       (press 32) 
	       (c:return)))
       (c:comment "x" :prefix "//")
       (c:if (c:== state 224) 
	     (c:progn 
	       (press 120) 
	       (c:return)))
       (c:comment "q" :prefix "//")
       (c:if (c:== state 208) 
	     (c:progn 
	       (press 113) 
	       (c:return)))
       (c:comment "d" :prefix "//")
       (c:if (c:== state 112) 
	     (c:progn 
	       (press 100) 
	       (c:return)))
       '(c:comment "mouse" :prefix "//")
       '(c:if (c:== state 82)
	     (c:progn
	       (c:set mouse (c:! mouse))
	       (c:if mouse
		     (Mouse.begin)
		     (Mouse.end))
	       (c:return)))
       (c:comment "esc" :prefix "//")
       (c:if (c:== state 56) 
	     (c:progn 
	       (press 177) 
	       (c:return)))
       (c:comment "nav" :prefix "//")
       (c:if (c:== state 37) 
	     (c:progn 
	       (c:set nav (c:! nav))
	       (c:return)))
       (c:comment "apos" :prefix "//")
       (c:if (c:== state 22)
	     (c:progn
	       (press 39)
	       (c:return)))
       (c:comment "m" :prefix "//")
       (c:if (c:== state 14) 
	     (c:progn 
	       (press 109) 
	       (c:return)))
       (c:comment "p" :prefix "//")
       (c:if (c:== state 13) 
	     (c:progn 
	       (press 112) 
	       (c:return)))
       (c:comment "l" :prefix "//")
       (c:if (c:== state 7) 
	     (c:progn 
	       (press 108) 
	       (c:return)))
       (c:comment "j" :prefix "//")
       (c:if (c:== state 192) 
	     (c:progn 
	       (press 106) 
	       (c:return)))
       (c:comment "v" :prefix "//")
       (c:if (c:== state 160) 
	     (c:progn 
	       (press 118) 
	       (c:return)))
       (c:comment "w" :prefix "//")
       (c:if (c:== state 144) 
	     (c:progn 
	       (press 119) 
	       (c:return)))
       (c:comment "alt" :prefix "//")
       (c:if (c:== state 132) 
	     (c:progn 
	       (press 130) 
	       (c:return)))
       (c:comment "gui" :prefix "//")
       (c:if (c:== state 130) 
	     (c:progn 
	       (press 131) 
	       (c:return)))
       (c:comment "control" :prefix "//")
       (c:if (c:== state 129) 
	     (c:progn
	       (press 128) 
	       (c:return)))
       (c:comment "8" :prefix "//")
       (c:if (c:and
	      (c:== state 96)
	      (c:!= s 0)
	      (c:> (c:- now s) hold)) 
	     (c:progn 
	       (press 56) 
	       (c:return)))
       (c:comment "g" :prefix "//")
       (c:if (c:== state 96) 
	     (c:progn 
	       (press 103) 
	       (c:return)))
       (c:comment "bang" :prefix "//")
       (c:if (c:== state 68) 
	     (c:progn 
	       (press 33) 
	       (c:return)))
       (c:comment "7" :prefix "//")
       (c:if (c:and
	      (c:== state 48)
	      (c:!= s 0)
	      (c:> (c:- now s) hold))
	     (c:progn 
	       (press 55) 
	       (c:return)))
       (c:comment "f" :prefix "//")
       (c:if (c:== state 48) 
	     (c:progn 
	       (press 102) 
	       (c:return)))
       (c:comment "delete" :prefix "//")
       (c:if (c:== state 36) 
	     (c:progn 
	       (press 212) 
	       (c:return)))
       (c:comment "shift lock" :prefix "//")
       (c:if (c:== state 34) 
	     (c:progn
	       (c:set lck (c:! lck))
	       (c:if lck
		     (press 129)
		     (Keyboard.release 129))
	       (c:return)))
       (c:comment "backspace" :prefix "//")
       (c:if (c:== state 33) 
	     (c:progn 
	       (press 178) 
	       (c:return)))
       (c:comment "forward slash" :prefix "//")
       (c:if (c:== state 24) 
	     (c:progn 
	       (press 47) 
	       (c:return)))
       (c:comment "comma" :prefix "//")
       (c:if (c:== state 20) 
	     (c:progn 
	       (press 44) 
	       (c:return)))
       (c:comment "period" :prefix "//")
       (c:if (c:== state 18) 
	     (c:progn 
	       (press 46) 
	       (c:return)))
       (c:comment "enter" :prefix "//")
       (c:if (c:== state 17) 
	     (c:progn 
	       (press 176) 
	       (c:return)))
       (c:comment "n" :prefix "//")
       (c:if (c:== state 12) 
	     (c:progn 
	       (press 110) 
	       (c:return)))
       (c:comment "k" :prefix "//")
       (c:if (c:== state 10) 
	     (c:progn 
	       (press 107) 
	       (c:return)))
       (c:comment "b" :prefix "//")
       (c:if (c:== state 9) 
	     (c:progn 
	       (press 98) 
	       (c:return)))
       (c:comment "0" :prefix "//")
       (c:if (c:and
	      (c:== state 6)
	      (c:!= s 0)
	      (c:> (c:- now s) hold)) 
	     (c:progn 
	       (press 48) 
	       (c:return)))
       (c:comment "u" :prefix "//")
       (c:if (c:== state 6) 
	     (c:progn 
	       (press 117) 
	       (c:return)))
       (c:comment "h" :prefix "//")
       (c:if (c:== state 5) 
	     (c:progn 
	       (press 104) 
	       (c:return)))
       (c:comment "9" :prefix "//")
       (c:if (c:and
	      (c:== state 3)
	      (c:!= s 0)
	      (c:> (c:- now s) hold)) 
	     (c:progn 
	       (press 57) 
	       (c:return)))
       (c:comment "c" :prefix "//")
       (c:if (c:== state 3) 
	     (c:progn 
	       (press 99) 
	       (c:return)))
       (c:comment "page up" :prefix "//")
       (c:if (c:and
	      (c:== state 128)
	      nav) 
	     (c:progn 
	       (press 211) 
	       (c:return)))
       (c:comment "backtick" :prefix "//")
       (c:if (c:and
	      (c:== state 128)
	      (c:!= e 0)
	      (c:> (c:- now e) hold)) 
	     (c:progn 
	       (press 96) 
	       (c:return)))
       (c:comment "open curly" :prefix "//")
       (c:if (c:and
	      (c:== state 128)
	      (c:!= a 0)
	      (c:> (c:- now a) hold)) 
	     (c:progn 
	       (press 123) 
	       (c:return)))
       (c:comment "s" :prefix "//")
       (c:if (c:== state 128) 
	     (c:progn 
	       (press 115) 
	       (c:return)))
       (c:comment "home" :prefix "//")
       (c:if (c:and
	      (c:== state 64)
	      nav) 
	     (c:progn 
	       (press 210) 
	       (c:return)))
       (c:comment "3" :prefix "//")
       (c:if (c:and
	      (c:== state 64)
	      (c:!= s 0)
	      (c:> (c:- now s) hold)) 
	     (c:progn 
	       (press 51) 
	       (c:return)))
       (c:comment "semicolon" :prefix "//")
       (c:if (c:and
	      (c:== state 64)
	      (c:!= e 0)
	      (c:> (c:- now e) hold)) 
	     (c:progn 
	       (press 59) 
	       (c:return)))
       (c:comment "open para" :prefix "//")
       (c:if (c:and
	      (c:== state 64)
	      (c:!= a 0)
	      (c:> (c:- now a) hold)) 
	     (c:progn 
	       (press 40) 
	       (c:return)))
       (c:comment "t" :prefix "//")
       (c:if (c:== state 64) 
	     (c:progn 
	       (press 116) 
	       (c:return)))
       (c:comment "up" :prefix "//")
       (c:if (c:and
	      (c:== state 32)
	      nav) 
	     (c:progn 
	       (press 218) 
	       (c:return)))
       (c:comment "2" :prefix "//")
       (c:if (c:and
	      (c:== state 32)
	      (c:!= s 0)
	      (c:> (c:- now s) hold)) 
	     (c:progn 
	       (press 50) 
	       (c:return)))
       (c:comment "backslash" :prefix "//")
       (c:if (c:and
	      (c:== state 32)
	      (c:!= e 0)
	      (c:> (c:- now e) hold)) 
	     (c:progn 
	       (press 92) 
	       (c:return)))
       (c:comment "close para" :prefix "//")
       (c:if (c:and
	      (c:== state 32)
	      (c:!= a 0)
	      (c:> (c:- now a) hold)) 
	     (c:progn 
	       (press 41) 
	       (c:return)))
       (c:comment "r" :prefix "//")
       (c:if (c:== state 32) 
	     (c:progn 
	       (press 114) 
	       (c:return)))
       (c:comment "end" :prefix "//")
       (c:if (c:and
	      (c:== state 16)
	      nav)
	     (c:progn 
	       (press 213) 
	       (c:return)))
       (c:comment "1" :prefix "//")
       (c:if (c:and
	      (c:== state 16)
	      (c:!= s 0)
	      (c:> (c:- now s) hold)) 
	     (c:progn 
	       (press 49) 
	       (c:return)))
       (c:comment "bang" :prefix "//")
       (c:if (c:and
	      (c:== state 16)
	      (c:!= e 0)
	      (c:> (c:- now e) hold)) 
	     (c:progn 
	       (press 33) 
	       (c:return)))
       (c:comment "a" :prefix "//")
       (c:if (c:== state 16) 
	     (c:progn 
	       (press 97) 
	       (c:return)))
       (c:comment "page down" :prefix "//")
       (c:if (c:and
	      (c:== state 8)
	      nav) 
	     (c:progn 
	       (press 214) 
	       (c:return)))
       (c:comment "equals" :prefix "//")
       (c:if (c:and
	      (c:== state 8)
	      (c:!= e 0)
	      (c:> (c:- now e) hold)) 
	     (c:progn 
	       (press 61) 
	       (c:return)))
       (c:comment "close curly" :prefix "//")
       (c:if (c:and
	      (c:== state 8)
	      (c:!= a 0)
	      (c:> (c:- now a) hold)) 
	     (c:progn 
	       (press 125) 
	       (c:return)))
       (c:comment "o" :prefix "//")
       (c:if (c:== state 8)
	     (c:progn 
	       (press 111) 
	       (c:return)))
       (c:comment "left" :prefix "//")
       (c:if (c:and
	      (c:== state 4)
	      nav) 
	     (c:progn 
	       (press 216) 
	       (c:return)))
       (c:comment "6" :prefix "//")
       (c:if (c:and
	      (c:== state 4)
	      (c:!= s 0)
	      (c:> (c:- now s) hold))
	     (c:progn
	       (press 54)
	       (c:return)))
       (c:comment "minus" :prefix "//")
       (c:if (c:and
	      (c:== state 4)
	      (c:!= e 0)
	      (c:> (c:- now e) hold)) 
	     (c:progn 
	       (press 45) 
	       (c:return)))
       (c:comment "open square" :prefix "//")
       (c:if (c:and
	      (c:== state 4)
	      (c:!= a 0)
	      (c:> (c:- now a) hold)) 
	     (c:progn 
	       (press 91) 
	       (c:return)))
       (c:comment "i" :prefix "//")
       (c:if (c:== state 4)
	     (c:progn
	       (press 105)
	       (c:return)))
       (c:comment "down" :prefix "//")
       (c:if (c:and
	      (c:== state 2)
	      nav) 
	     (c:progn 
	       (press 217) 
	       (c:return)))
       (c:comment "5" :prefix "//")
       (c:if (c:and
	      (c:== state 2)
	      (c:!= s 0)
	      (c:> (c:- now s) hold))
	     (c:progn
	       (press 53)
	       (c:return)))
       (c:comment "question" :prefix "//")
       (c:if (c:and
	      (c:== state 2)
	      (c:!= e 0)
	      (c:> (c:- now e) hold)) 
	     (c:progn 
	       (press 63) 
	       (c:return)))
       (c:comment "close square" :prefix "//")
       (c:if (c:and
	      (c:== state 2)
	      (c:!= a 0)
	      (c:> (c:- now a) hold)) 
	     (c:progn 
	       (press 93) 
	       (c:return)))
       (c:comment "y" :prefix "//")
       (c:if (c:== state 2) 
	     (c:progn 
	       (press 121) 
	       (c:return)))
       (c:comment "right" :prefix "//")
       (c:if (c:and
	      (c:== state 1)
	      nav) 
	     (c:progn 
	       (press 215) 
	       (c:return)))
       (c:comment "4" :prefix "//")
       (c:if (c:and
	      (c:== state 1)
	      (c:!= s 0)
	      (c:> (c:- now s) hold))
	     (c:progn
	       (press 52)
	       (c:return)))
       (c:comment "e" :prefix "//")
       (c:if (c:== state 1) 
	     (c:progn 
	       (press 101) 
	       (c:return)))
       )))

 (c:decl ((USB Usb)
	  ((c:instantiate HIDBoot (USB_HID_PROTOCOL_KEYBOARD)) (HidKeyboard &Usb))
	  (KbdRptParser Prs)))

 (c:function setup () -> void
   (c:set lck false)
   (c:set nav false)
   (c:set mouse false)
   
   (Usb.Init) -1

   (HidKeyboard.SetReportParser 0 &Prs)

   (Keyboard.begin))

 (c:function loop () -> void (Usb.Task))
 
 )

(with-open-file
    (ino
     "arduix.ino"
     :direction :output
     :if-does-not-exist :create
     :if-exists :supersede)
  (format ino "~a" c-code))
