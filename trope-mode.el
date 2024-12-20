;;; trope-mode.el --- Major mode to edit TV Tropes format ".trp" files -*- lexical-binding:t -*-

;; Copyright (C) 2024 Sean Vo
;; Author: Sean Vo <triattack238@gmail.com>
;; Version: 0.0.1
;; Created: 18 Dec 2024
;; package-requires ((emacs "29.1"))
;; Keywords: TV Tropes, trope
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

;; See the README.org file for details.

;;; Code:

(require 'rx)

;;; Configuration


;;; Constants

(defconst trope-mode-version "0.0.1"
  "TV Tropes mode version number.")

;;; Syntax Table
(defconst trope-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; % both begins and ends comments by itself, and two starts a comment
    (modify-syntax-entry ?% "! 12" table)
    ;; newline ends a comment
    (modify-syntax-entry ?\n ">" table)

    ;; Return Syntax Table
    table)
  )

;; Add specific font face for headings (!, !!, and !!!)

;; Create custom faces for headings

(defface trope-mode-header-face-base
  '((t :inherit font-lock-function-name-face :foreground "firebrick" :weight extra-bold))
  "Base face for headers."
  :group 'trope-mode
  )

;; Add faces to regular expressions
;; TODO: give each header level its own face at compile time

(add-hook 'trope-mode-hook
	  (lambda ()
	    (font-lock-add-keywords nil
				    '(("^!\\{1,3\\}.+$" . 'trope-mode-header-face-base))
				    
	      )
	    )
	  )



;;; Add specific font face for notes, quotes, and folders

(defface trope-mode-label-face-base
  '((t :inherit font-lock-function-name-face :foreground "dark cyan" :weight extra-bold))
  "Base face for headers."
  :group 'trope-mode
  )

;; Add faces to regular expressions

(add-hook 'trope-mode-hook
	  (lambda ()
	    (font-lock-add-keywords nil
				    '(("\\[\\{2\\}\\/?\\(?:note\\|quoteblock\\|labelnote:?.*?\\|folder:?.*?\\)\\]\\{2\\}" . 'trope-mode-label-face-base))
				    
	      )
	    )
	  )

;;; Exposed Functionality

;;;###autoload
(define-derived-mode trope-mode
  text-mode "Trope Mode"
  "Major mode for the TV Tropes formatting language."
  :syntax-table trope-mode-syntax-table
  (font-lock-fontify-buffer)
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(?:trp\\|trope\\)". trope-mode))

(provide 'trope-mode)

;;; trope-mode.el ends here

