;;; my-org.el --- Write journal in emacs org-mode  -*- lexical-binding: t; -*-

(defun my-org-getRandom ()
  (interactive)
  (with-current-buffer (find-file-noselect my/my-org-file)
    (let 
      (catch 'counter
	(org-map-entries '(lambda ()
			    (when (= counter id)
			      (setq point (point))
			      (setq my-org
				    (cons (nth 4 (org-heading-components))
					  (org-entry-get point "URL")))
			      (funcall interprogram-cut-function (cdr my-org))
			      (minibuffer-message (car my-org))
			      (throw 'counter counter))
			    (setq counter (1+ counter)))
			 "LEVEL>1"))
      (goto-char point)
      (org-set-tags)
      (save-buffer)
      (kill-buffer))))

(defun my-org-getRandomEntry (pMin pMax level)
  (my-org--gotoRndPos pMin pMax)
  (my-org--getCurrentLvl))


(defsubst my-org--getCurrentLvl ()
  )


(defsubst my-org--gotoRndPos (pMin pMax)
  (let ((rndPos (+ pMin (random pMax))))
    (goto-char rndPos)))



(setq org-html-html5-fancy t
      org-html-doctype "html5")

(require 'org-id)
;; https://writequit.org/articles/emacs-org-mode-generate-ids.html
(setq org-id-link-to-org-use-id nil)
;; TODO http://emacs.stackexchange.com/questions/10771/how-to-use-my-custom-layout-for-generating-html-files-from-org-files-instead-of
(defun my-org-export-all ()
  "Export all subtrees that are *not* tagged with :noexport: to
separate files.

Note that subtrees must have the :EXPORT_FILE_NAME: property set
to a unique value for this to work properly."
  (interactive)
  (save-window-excursion
    (org-map-entries (lambda ()
                       (let* ((heading (nth 4 (org-heading-components)))
                              (title (format "<!-- title: %s -->" heading))
                              (file (org-entry-get (point) "EXPORT_FILE_NAME"))
                              (org-html-footnotes-section "<div id=\"footnotes\" %s>\n<hr/><h2 class=\"footnotes\">Referenzen: </h2>\n<div id=\"text-footnotes\">\n%s\n</div>\n</div>")
                              (org-html-html5-fancy t))
                         (when file
                           (unless (file-exists-p file)
                             (let ((dir (file-name-directory file)))
                               (unless (file-exists-p dir)
                                 (make-directory dir))))
                           (with-current-buffer (org-html-export-as-html nil t nil t)
                             (message title)
                             (insert title)
                             (newline)
                             (write-file file)
                             (kill-buffer))) 
                         )) "-noexport")))
(provide 'my-org)

;;; my-org.el ends here