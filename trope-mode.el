;;; trope-mode.el --- Major mode to edit TV Tropes format ".trp" files -*- lexical-binding:t -*-

;; Copyright (C) 2024 Sean Vo
;; Author: Sean Vo <triattack238@gmail.com>
;; Version: 0.1.0
;; Created: 18 Dec 2024
;; Package-Requires: ((emacs "29.1"))
;; Keywords: TV Tropes, trope, wp
;; URL: https://github.com/TriAttack238/trope-mode

;; This file is not a part of GNU Emacs

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

;; A major mode for writing the unnamed markup language used for the
;; website TV Tropes. Files should be marked with ".trp" or ".trope"
;; extensions.

;;; Code:

(require 'rx)


;;; Configuration

;;; Constants

(defconst trope-mode-version "0.1.0"
  "TV Tropes mode version number.")

;;; Syntax Table
(defconst trope-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; % both begins and ends comments by itself, and two starts a comment
    (modify-syntax-entry ?% "! 12" table)
    ;; newline ends a comment
    (modify-syntax-entry ?\n ">" table)

    ;; Return Syntax Table
    table))

;;; Key Maps

;; KeyMap for trope-mode
(defvar-keymap trope-mode-keymap
  :parent text-mode-map
  :doc "Keymap for Tv Tropes markup text mode"
  
  "C-c ; i" #'trope-mode-italicize-region
  "C-c ; b" #'trope-mode-bold-region
  "C-c ; m" #'trope-mode-monospace-region

  "C-c ' f" #'trope-mode-create-folder
  "C-c ' n" #'trope-mode-create-note
  "C-c ' q" #'trope-mode-create-quoteblock
  "C-c ' l" #'trope-mode-create-labelnote)

;;; Text Manipulation

;; Emphasis
(defun trope-mode-add-to-region (start end char repeat)
  "Insert CHAR on either side of the region defined by START and END.

If REPEAT is greater than 1, add the character multiple times.
Assumes that START is less than END."
  (save-excursion
    (progn
      (goto-char end)
      (insert-char char repeat t)
      (goto-char start)
      (insert-char char repeat t))))

(defun trope-mode-italicize-region (start end)
  "Italicize the selected region.
Meant to be used interactively, or assuming that START is less than END."
  (interactive "*r")
  (let ((char-to-add ?')
	(times 2))
    (trope-mode-add-to-region start end char-to-add times)))

(defun trope-mode-monospace-region (start end)
  "Monospace the selected region.

Meant to be used interactively, or assuming that START is less than END."
  (interactive "*r")
  (let ((char-to-add ?@)
	(times 2))
    (trope-mode-add-to-region start end char-to-add times)))

(defun trope-mode-bold-region (start end)
  "Bold the selected region.

Meant to be used interactively, or assuming that START is less than END."
  (interactive "*r")
  (let ((char-to-add ?')
	(times 3))
    (trope-mode-add-to-region start end char-to-add times)))

;; Insert text constructs for labels (notes, labelnotes, quoteblocks, folders)

(defun trope-mode-create-label (type name seperator)
  "Add boxed label construct in the current buffer.

Meant as a helper function to create labels depending on the
value of the string TYPE (note, folder, ect.).  If the string is
not nil, add ':NAME' to the beginning label.  The SEPERATOR
character is printed twice between the beginning and end."
  (save-excursion ;;Should the point stay at its original position?
    (let ((start-block)
	  (name-inner)
	  (end-block))
      (setq name-inner (when name
			(concat ":" name)))
      (setq start-block (concat "[[" type name-inner "]]"))
      (setq end-block (concat "[[/" type "]]"))
      (insert start-block (make-string 2 seperator) end-block))))

(defun trope-mode-create-note ()
  "Create a beginning and end note block after the point seperated by 2 spaces."
  (interactive "*")
  (trope-mode-create-label "note" nil ?\s))

(defun trope-mode-create-labelnote (name)
  "Create a beginning and end labelnote block with NAME after the point."
  (interactive "*sName of labelnote: ")
  (trope-mode-create-label "labelnote" name ?\s))

(defun trope-mode-create-quoteblock ()
  "Create a beginning and end labelnote block after the point.

Quote blocks only render on the TV Tropes forums, not the main wiki."
  (interactive "*")
  (trope-mode-create-label "quoteblock" nil ?\s))

(defun trope-mode-create-folder (name)
  "Create a beginning and end folder block after the point with NAME."
  (interactive "*sName of folder: ")
  (trope-mode-create-label "folder" name ?\n))


;; TODO: Add specific font face for headings (!, !!, and !!!)

;; Create custom faces for headings

(defface trope-mode-header-face-base
  '((t :foreground "firebrick" :weight extra-bold))
  "Base face for headers."
  :group 'trope-mode)


;; Add specific font face for PotHoles and links

(defface trope-mode-link-face
  '((t :inherit button))
  "Face for Potholes and links."
  :group 'trope-mode)

;; Add specific font face for notes, quotes, and folders

(defface trope-mode-label-face-base
  '((t :foreground "dark cyan" :weight bold))
  "Base face for headers."
  :group 'trope-mode)

;; Create default list
(defconst trope-mode-font-lock-defaults
  '((
    ;; Any text between [=this escape sequence=] on the same line. The "t" makes sure it overrides other keywords.
    ("\\[=.*=\\]" 0 'default t)

    ;; Headers
    ("^!\\{1,3\\}.+$" 0 'trope-mode-header-face-base)

    ;; Links
    ;; Pothole and external link
				      ("\\[\\{2\\}\\(\\([[:alpha:]]\\|/\\|{\\{2\\}\\([[:alpha:]]+\\)?}\\{2\\}\\)+\\|http[s]?:.*\\) \\(?:[[:alpha:]]\\|[[:blank:]]\\)+\\]\\{2\\}" 0 'trope-mode-link-face)

    ;; Internal Wikiword Link with CamelCase
    ("\\(\\([[:upper:]][a-z]+\\)+/\\)?\\([[:upper:]][a-z]+\\)\\{2,\\}" 0 'trope-mode-link-face)

    ;; Internal Wikiword Link with {{Bracket}}
    ("\\([[:upper:]][a-z]+\\)?\\(/\\|\\.\\)?{\\{2\\}\\([[:alpha:]]+\\)?}\\{2\\}" 0 'trope-mode-link-face)

    ;; Notes, quoteblocks, folders
    ("\\[\\{2\\}\\/?\\(?:note\\|quoteblock\\|index\\|labelnote:?.*?\\|folder:?.*?\\)\\]\\{2\\}" 0 'trope-mode-label-face-base)

    ;; Emphasis
    ;; @@monospace@@
    ("@\\{2\\}.*@\\{2\\}" 0 'fixed-pitch append)

    ;; ''Italic''
    ("\\b'\\{2\\}\\('''\\)?[^']*\\('''\\)?'\\{2\\}\\b" 0 'italic append)
				      
    ;; '''Bold'''
    ("'\\{3\\}[^']*'\\{3\\}" 0 'bold append))))

;;; Exposed Functionality

;;;###autoload
(define-derived-mode trope-mode
  text-mode "Trope Mode"
  "Major mode for the TV Tropes formatting language."
  (setq font-lock-defaults trope-mode-font-lock-defaults)
  (font-lock-ensure)
  (use-local-map trope-mode-keymap)
  :syntax-table trope-mode-syntax-table)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(?:trp\\|trope\\)" . trope-mode))

(provide 'trope-mode)

;;; trope-mode.el ends here

