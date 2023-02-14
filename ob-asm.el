;;; ob-asm.el --- Org-babel functions for arm-64 assembly evaluation

;; Copyright (C) 2012 Hibl, Anton

;; Author: Anton Hibl <antonhibl11@gmail.com>
;; Keywords: languages
;; Homepage: http://github.com/antonhibl/ob-asm
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating arm 64 assembly code.  Not fully developed
;; as of yet.  Feel free to contribute a PR with improvements.

;;; Requirements:

;; - You must have an ARM64 assembler like `gas' or `as' installed. Also ensure
;;   a valid linker such as `ld' is also installed.
;;
;; - `asm-mode' is also recommended for syntax highlighting and
;;   formatting. Not this particularly needs it, it just assumes you
;;   have it.

;;; TODO:

;; - Provide better error feedback.
;;
;; - Fix Syntax Highlighting

;;; Code:
(require 'org)
(require 'ob)
(require 'ob-eval)
(require 'ob-ref)


;; optionally define a file extension for this language
(add-to-list 'org-babel-tangle-lang-exts '("asm" . "asm"))

(defvar org-babel-default-header-args:asm '())

(defvar ob-asm-assemble-command "clang"
  "The command to use to assemble the arm-64 assembly code.")

;; This macro checks if the given value is a list and returns it as is or
;; wrapped in a list if it's not a list.
(defmacro ob-asm-as-list (val)
  "Macro to check if value is in a list, return it in the list if not.
Argument VAL value to check against list."
  (list 'if (list 'listp val) val (list 'list val)))

;; handle assembling, linking, compiling, and executing source blocks
(defun ob-asm-assemble-then-execute (filepath &rest params)
  "Handle assembling and executing source blocks based on tangle ID.
Argument FILEPATH file to assemble from, must specify tangle file.
Optional PARAMS: :target, :assembler, :linker, :compiler, :debug."
  (let ((filename (file-name-sans-extension filepath))
        (target (or (cdr (assoc :target params))
                    (file-name-sans-extension filepath)))
        (assembler (or (cdr (assoc :assembler params))
                       "as"))
        (linker (or (cdr (assoc :linker params))
                    "ld"))
        (compiler (or (cdr (assoc :compiler params))
                      "clang"))
        (debug (if (cdr (assoc :debug params)) t nil)))
    (condition-case err
        (if debug
            (progn
              (message (shell-command-to-string (format "%s -o %s.o %s" assembler target filepath)))
              (message (shell-command-to-string (format "%s -o %s %s.o" linker
  filename (format "%s.o" target))))
              (message (shell-command-to-string (format "./%s" filename))))
          (progn
            (message (shell-command-to-string (format "%s -o %s %s" compiler filename filepath)))
            (message (shell-command-to-string (format "./%s" filename)))))
      (error
       (message "%s" (error-message-string err))))))

(defun org-babel-execute:asm (body params)
  "Execute assembly code using an external assembler.
BODY contains the assembly code.
PARAMS contains any additional parameters."
  (let* ((tangle-file (cdr (assoc :tangle params)))
         (target (or (cdr (assoc :target params))
                     (file-name-sans-extension tangle-file)))
         (assembler (or (cdr (assoc :assembler params))
                        "as"))
         (linker (or (cdr (assoc :linker params))
                     "ld"))
         (compiler (or (cdr (assoc :compiler params))
                       "clang"))
         (debug (if (cdr (assoc :debug params)) t nil)))
    (with-temp-file tangle-file
      (insert body))
    (ob-asm-assemble-then-execute tangle-file
                                  :target target
                                  :assembler assembler
                                  :linker linker
                                  :compiler compiler
                                  :debug debug)))

;; This function should be used to assign any variables in params in
;; the context of the session environment.
(defun org-babel-prep-session:asm (session params)
  "This function does nothing as arm-64 assembly is an assembled language.
Argument SESSION irrelevant for arm-64.
Argument PARAMS parameters for org-babel."
  (error
   "Arm-64 assembly is an assembled language -- no support for sessions"))

(provide 'ob-asm)
;;; ob-asm.el ends here
