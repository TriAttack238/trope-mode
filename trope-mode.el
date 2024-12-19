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

;;; Exposed Functionality

;;;###autoload
(define-derived-mode trope-mode
  text-mode "TV Tropes markup mode"
  "Major mode for the TV Tropes formatting language."
  :syntax-table trope-mode-syntax-table
  (font-lock-fontify-buffer)
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(?:trp\\|trope\\)". trope-mode))

(provide 'trope-mode)

;;; trope-mode.el ends here

