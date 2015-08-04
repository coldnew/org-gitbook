;;; ox-gitbook-md.el --- Export org-mode to Gitbook markdown.

;; Copyright (c) 2015 Yen-Chin, Lee. (coldnew) <coldnew.tw@gmail.com>
;;
;; Author: coldnew <coldnew.tw@gmail.com>
;; Keywords:
;; X-URL:
;; Version: 0.1
;; Package-Requires: ((org "8.0") (cl-lib "0.5") (f "0.17.2") (noflet "0.0.11"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;; Code:

(eval-when-compile (require 'cl-lib))

(require 'f)
(require 'ox-md)
(require 'ox-publish)


;;;; Backend

(org-export-define-derived-backend 'gitbook-md 'md
  :translate-alist
  '(
    ;; Fix for multibyte language
    (paragraph . org-gitbook-md-paragraph)
    ;; Fix for pelican metadata
    ;;    (template . org-pelican-md-template)
    ;; Fix link path to suite for pelican
    ;;    (link . org-pelican-md-link)
    ;; Make compatible with gitbook
    (src-block . org-gitbook-md-src-block)
    )
  ;;  :options-alist org-pelican--options-alist
  )



;;;; Paragraph

(defun org-gitbook-md-paragraph (paragraph contents info)
  "Transcode PARAGRAPH element into Markdown format.
CONTENTS is the paragraph contents.  INFO is a plist used as
a communication channel."
  ;; Send modify data to org-md-paragraph
  ;;(org-pelican--paragraph 'org-md-paragraph paragraph contents info)
  (let* (;; Fix multibyte language like chinese will be automatically add
         ;; some space since org-mode will transpose auto-fill-mode's space
         ;; to newline char.
         (fix-regexp "[[:multibyte:]]")
         (fix-contents
          (replace-regexp-in-string
           (concat "\\(" fix-regexp "\\) *\n *\\(" fix-regexp "\\)") "\\1\\2" contents))

         ;; Unfill paragraph to make contents look more better
         (unfill-contents
          (with-temp-buffer
            (insert fix-contents)
            (replace-regexp "\\([^\n]\\)\n\\([^ *\n]\\)" "\\1 \\2" nil (point-min) (point-max))
            (buffer-string))))

    (org-md-paragraph paragraph unfill-contents info)))


;;;; Example Block and Src Block

;;;; Src Block

(defun org-gitbook-md-src-block (src-block contents info)
  "Transcode a SRC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
  (let ((lang (org-element-property :language src-block)))
    (format "    :::%s\n%s\n"
            lang
            (org-md-example-block src-block contents info))))


(provide 'ox-gitbook-md)
;;; ox-gitbook-md.el ends here.