;;; ob-assembly.el --- Org-babel functions for arm-64 assembly evaluation

;; Copyright (C) 2012 Hibl, Anton

;; Author: Anton Hibl <antonhibl11@gmail.com>
;; Keywords: languages
;; Homepage: http://github.com/antonhibl/ob-assembly
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
;; as of yet.  Feel free to contribute a PR

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
(add-to-list 'org-babel-tangle-lang-exts '("assembly" . "assembly"))

(defvar org-babel-default-header-args:assembly '())

(defvar ob-assembly-assemble-command "as"
  "The command to use to assemble the arm-64 assembly code.")

(defvar ob-assembly-link-command "ld"
  "The command to use to link the arm-64 assembly code.")

;; This macro checks if the given value is a list and returns it as is or
;; wrapped in a list if it's not a list.
(defmacro ob-assembly-as-list (val)
  "Macro to check if value is in a list, return it in the list if not.
Argument VAL value to check against list."
  (list 'if (list 'listp val) val (list 'list val)))

(defun org-babel-execute:assembly (body params)
  "Execute a block of arm-64 assembly code with org-babel.
This function is
called by `org-babel-execute-src-block'
Argument BODY source block body.
Argument PARAMS source block parameters."
  (message "assembling arm-64 source code block")
  ;; 1. Assemble the source block using org-babel-temp-file function to create
  ;; a temporary file for the assembly code.
  (let ((assembled-file (org-babel-temp-file "arm-asm-")))
    (with-temp-file assembled-file
      (insert body)
      (shell-command (format "%s -o %s %s" ob-assembly-assemble-command
                             assembled-file assembled-file)))
    ;; 2. Link the object file generated from assembling the code with
    ;; org-babel-temp-file to create a temporary executable file.
    (let ((executable-file (org-babel-temp-file "arm-asm-")))
      (shell-command (format "%s -o %s %s" ob-assembly-link-command
                             executable-file assembled-file))
      ;; 3. Run the temporary executable file and return the output as results
      ;; for org-babel.
      (org-babel-eval (concat "./" executable-file) ""))))

;; This function should be used to assign any variables in params in
;; the context of the session environment.
(defun org-babel-prep-session:assembly (session params)
  "This function does nothing as arm-64 assembly is an assembled language.
Argument SESSION irrelevant for arm-64.
Argument PARAMS parameters for org-babel."
  (error "Arm-64 assembly is an assembled language -- no support for sessions"))

(provide 'ob-assembly)
;;; ob-assembly.el ends here
